// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/backend/gym/gym_repository.dart';
import 'package:sentimento_app/backend/tables/gym_logs.dart';
import 'package:sentimento_app/core/theme.dart';

/// Widget that displays exercise history for a specific exercise
class GymExerciseHistory extends StatefulWidget {
  const GymExerciseHistory({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  final String exerciseId;
  final String exerciseName;

  @override
  State<GymExerciseHistory> createState() => _GymExerciseHistoryState();
}

class _GymExerciseHistoryState extends State<GymExerciseHistory> {
  final _repository = GymRepository();
  List<GymLogsRow> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _repository.getExerciseHistory(widget.exerciseId);
      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.alternate.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.history, color: theme.secondaryText, size: 20),
            const SizedBox(width: 8),
            Text(
              'Sem histórico ainda',
              style: theme.bodySmall.override(
                fontFamily: 'Outfit',
                color: theme.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_up, color: theme.tertiary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Histórico de Peso',
              style: theme.labelMedium.override(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (_history.isNotEmpty && _history.any((h) => h.weight != null))
              TextButton.icon(
                onPressed: () => _showWeightChartDialog(context, theme),
                icon: const Icon(Icons.show_chart, size: 16),
                label: const Text('Ver Gráfico'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _history.length,
            itemBuilder: (context, index) {
              final log = _history[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.alternate),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      log.displayDate,
                      style: theme.labelSmall.override(
                        fontFamily: 'Outfit',
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${log.weight ?? "-"}kg',
                      style: theme.titleSmall.override(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                    Text(
                      '${log.series ?? "-"}x${log.reps ?? "-"}',
                      style: theme.bodySmall.override(
                        fontFamily: 'Outfit',
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showWeightChartDialog(BuildContext context, FlutterFlowTheme theme) {
    final weights = _history
        .where((h) => h.weight != null)
        .toList()
        .reversed
        .toList(); // Oldest first for chart

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.show_chart, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Evolução - ${widget.exerciseName}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 300,
          height: 200,
          child: weights.length < 2
              ? Center(
                  child: Text(
                    'Precisa de pelo menos 2 registros para mostrar o gráfico',
                    style: theme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                )
              : GymWeightChart(logs: weights),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

/// Widget that shows weekly workout stats
class GymWeeklyStats extends StatefulWidget {
  const GymWeeklyStats({super.key});

  @override
  State<GymWeeklyStats> createState() => _GymWeeklyStatsState();
}

class _GymWeeklyStatsState extends State<GymWeeklyStats> {
  final _repository = GymRepository();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  // Cache for weekly stats (5 minute expiration)
  static Map<String, dynamic>? _cachedStats;
  static DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    // Check cache first
    if (_cachedStats != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      if (mounted) {
        setState(() {
          _stats = _cachedStats!;
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final stats = await _repository.getWeeklyStats();
      // Update cache
      _cachedStats = stats;
      _cacheTime = DateTime.now();

      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final totalVolume = (_stats['totalVolume'] as double? ?? 0).toStringAsFixed(
      0,
    );
    final totalSets = _stats['totalSets'] as int? ?? 0;
    final daysWorked = _stats['daysWorked'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primary.withValues(alpha: 0.15),
            theme.secondaryBackground.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: theme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Esta Semana',
                    style: theme.titleMedium.override(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Resumo de atividades', style: theme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                theme,
                icon: Icons.calendar_today_rounded,
                value: '$daysWorked',
                label: 'Dias',
                color: theme.tertiary,
              ),
              Container(
                height: 40,
                width: 1,
                color: theme.alternate.withValues(alpha: 0.5),
              ),
              _buildStatItem(
                theme,
                icon: Icons.repeat_rounded,
                value: '$totalSets',
                label: 'Séries',
                color: theme.secondary,
              ),
              Container(
                height: 40,
                width: 1,
                color: theme.alternate.withValues(alpha: 0.5),
              ),
              _buildStatItem(
                theme,
                icon: Icons.fitness_center_rounded,
                value: '${totalVolume}kg',
                label: 'Volume',
                color: theme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    FlutterFlowTheme theme, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.headlineSmall.override(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: theme.primaryText,
          ),
        ),
        Text(
          label,
          style: theme.bodySmall.override(
            fontFamily: 'Outfit',
            color: theme.secondaryText,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Full screen dialog for viewing detailed history stats
class GymStatsDialog extends StatelessWidget {
  const GymStatsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estatísticas',
                  style: theme.headlineSmall.override(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const GymWeeklyStats(),
          ],
        ),
      ),
    );
  }
}

/// Simple line chart for weight history
class GymWeightChart extends StatelessWidget {
  const GymWeightChart({super.key, required this.logs});

  final List<GymLogsRow> logs;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (logs.isEmpty) {
      return Center(
        child: Text(
          'Sem dados para o gráfico',
          style: theme.bodyMedium.override(
            fontFamily: 'Outfit',
            color: theme.secondaryText,
          ),
        ),
      );
    }

    final weights = logs.map((l) => l.weight ?? 0.0).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);

    // Add some padding to the range so points aren't on the absolute edge
    final range = maxWeight - minWeight;
    final displayMin = minWeight - (range > 0 ? range * 0.1 : 5);
    final displayMax = maxWeight + (range > 0 ? range * 0.1 : 5);

    return Column(
      children: [
        // Chart container
        Expanded(
          child: Row(
            children: [
              // Y-axis labels
              SizedBox(
                width: 32,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      maxWeight.toStringAsFixed(1),
                      style: theme.labelSmall.override(fontSize: 10),
                    ),
                    Text(
                      minWeight.toStringAsFixed(1),
                      style: theme.labelSmall.override(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Chart area
              Expanded(
                child: CustomPaint(
                  painter: _WeightChartPainter(
                    weights: weights,
                    minWeight: displayMin,
                    maxWeight: displayMax,
                    lineColor: theme.primary,
                    fillColor: theme.primary.withValues(alpha: 0.2),
                    dotColor: theme.secondaryBackground,
                    gridColor: theme.alternate.withValues(alpha: 0.5),
                  ),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // X-axis labels (Start and End Date)
        Padding(
          padding: const EdgeInsets.only(left: 44),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (logs.isNotEmpty)
                Text(
                  logs.first.displayDate,
                  style: theme.labelSmall.override(
                    fontSize: 10,
                    color: theme.secondaryText,
                  ),
                ),
              if (logs.length > 1)
                Text(
                  logs.last.displayDate,
                  style: theme.labelSmall.override(
                    fontSize: 10,
                    color: theme.secondaryText,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  _WeightChartPainter({
    required this.weights,
    required this.minWeight,
    required this.maxWeight,
    required this.lineColor,
    required this.fillColor,
    required this.dotColor,
    required this.gridColor,
  });

  final List<double> weights;
  final double minWeight;
  final double maxWeight;
  final Color lineColor;
  final Color fillColor;
  final Color dotColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.isEmpty) return;

    final range = maxWeight - minWeight;
    final paddedRange = range == 0 ? 1.0 : range;

    // 1. Draw minimal grid lines (Top and Bottom)
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw bottom line
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      gridPaint,
    );

    // 2. Compute points
    final points = <Offset>[];
    for (int i = 0; i < weights.length; i++) {
      final x = weights.length <= 1
          ? size.width / 2
          : size.width * i / (weights.length - 1);
      final normalizedY = (weights[i] - minWeight) / paddedRange;
      final y = size.height - (normalizedY * size.height);
      points.add(Offset(x, y));
    }

    // 3. Create Smooth Path (Spline)
    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];

        // Simple cubic bezier smoothing
        final cp1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final cp2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

        // Using cubicTo for smoother S-shape connection
        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
      }
    }

    // 4. Draw Gradient Fill area
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [fillColor, fillColor.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 5. Draw the Line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);

    // 6. Draw Dots (Outer Ring + Inner Circle)
    final dotFillPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final point in points) {
      canvas.drawCircle(point, 4, dotFillPaint);
      canvas.drawCircle(point, 4, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
