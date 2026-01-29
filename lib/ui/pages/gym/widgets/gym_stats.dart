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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primary.withValues(alpha: 0.1),
            theme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: theme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Esta Semana',
                style: theme.titleMedium.override(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                theme,
                icon: Icons.fitness_center,
                value: '$daysWorked',
                label: 'Dias',
                color: theme.tertiary,
              ),
              _buildStatItem(
                theme,
                icon: Icons.repeat,
                value: '$totalSets',
                label: 'Séries',
                color: theme.secondary,
              ),
              _buildStatItem(
                theme,
                icon: Icons.scale,
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
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.headlineSmall.override(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.bodySmall.override(
            fontFamily: 'Outfit',
            color: theme.secondaryText,
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
      return const Center(child: Text('Sem dados'));
    }

    final weights = logs.map((l) => l.weight ?? 0.0).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final range = maxWeight - minWeight;

    return Column(
      children: [
        // Y-axis labels
        Expanded(
          child: Row(
            children: [
              // Y-axis
              SizedBox(
                width: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${maxWeight.toStringAsFixed(0)}kg',
                      style: theme.labelSmall,
                    ),
                    if (range > 0)
                      Text(
                        '${(minWeight + range / 2).toStringAsFixed(0)}kg',
                        style: theme.labelSmall,
                      ),
                    Text(
                      '${minWeight.toStringAsFixed(0)}kg',
                      style: theme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Chart area
              Expanded(
                child: CustomPaint(
                  painter: _WeightChartPainter(
                    weights: weights,
                    minWeight: minWeight,
                    maxWeight: maxWeight,
                    lineColor: theme.primary,
                    dotColor: theme.tertiary,
                    gridColor: theme.alternate,
                  ),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // X-axis labels (dates)
        Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (logs.isNotEmpty)
                Text(logs.first.displayDate, style: theme.labelSmall),
              if (logs.length > 1)
                Text(logs.last.displayDate, style: theme.labelSmall),
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
    required this.dotColor,
    required this.gridColor,
  });

  final List<double> weights;
  final double minWeight;
  final double maxWeight;
  final Color lineColor;
  final Color dotColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.isEmpty) return;

    final range = maxWeight - minWeight;
    final paddedRange = range == 0 ? 1.0 : range;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (int i = 0; i <= 2; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw line and points
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < weights.length; i++) {
      final x = weights.length == 1
          ? size.width / 2
          : size.width * i / (weights.length - 1);
      final normalizedY = (weights[i] - minWeight) / paddedRange;
      final y = size.height - (normalizedY * size.height);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // Draw dots
    for (final point in points) {
      canvas.drawCircle(point, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
