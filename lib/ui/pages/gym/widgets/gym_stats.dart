import 'package:flutter/material.dart';
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
          color: theme.alternate.withOpacity(0.3),
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
              'Histórico Recente',
              style: theme.labelMedium.override(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
              ),
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

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _repository.getWeeklyStats();
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
            theme.primary.withOpacity(0.1),
            theme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primary.withOpacity(0.3)),
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
