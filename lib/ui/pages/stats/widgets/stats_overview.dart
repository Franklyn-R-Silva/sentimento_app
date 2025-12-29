import 'package:flutter/material.dart';
import 'package:sentimento_app/core/theme.dart';
import 'stats_card.dart';

class StatsOverview extends StatelessWidget {
  final double averageMood;
  final int totalEntries;
  final int currentStreak;

  const StatsOverview({
    super.key,
    required this.averageMood,
    required this.totalEntries,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Média de Humor',
                value: averageMood.toStringAsFixed(1),
                icon: Icons.trending_up_rounded,
                color: theme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Total de Registros',
                value: totalEntries.toString(),
                icon: Icons.edit_note_rounded,
                color: theme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StatCard(
          title: 'Sequência Atual',
          value: '$currentStreak dias 🔥',
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFFF6B35),
        ),
      ],
    );
  }
}
