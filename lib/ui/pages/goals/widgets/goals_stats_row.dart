// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';
import 'goals_stats_card.dart';

class GoalsStatsRow extends StatelessWidget {
  final int activeCount;
  final int completedCount;

  const GoalsStatsRow({
    super.key,
    required this.activeCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GoalsStatsCard(
              icon: Icons.track_changes_rounded,
              value: '$activeCount',
              label: 'Ativas',
              color: theme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GoalsStatsCard(
              icon: Icons.check_circle_rounded,
              value: '$completedCount',
              label: 'Concluídas',
              color: theme.success,
            ),
          ),
        ],
      ),
    );
  }
}
