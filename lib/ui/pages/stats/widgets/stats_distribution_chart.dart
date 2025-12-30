// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/shared/widgets/gradient_card.dart';

class StatsDistributionChart extends StatelessWidget {
  final Map<int, int> moodDistribution;

  const StatsDistributionChart({super.key, required this.moodDistribution});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final colors = [
      const Color(0xFFE53935),
      const Color(0xFFFF9800),
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      theme.primary,
    ];
    final emojis = ['😢', '😟', '😐', '🙂', '😄'];

    final total = moodDistribution.values.fold(0, (a, b) => a + b);

    Widget chartContent;
    if (total == 0) {
      chartContent = Center(
        child: Text(
          'Sem dados suficientes',
          style: theme.bodyMedium.override(color: theme.secondaryText),
        ),
      );
    } else {
      chartContent = Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: moodDistribution.entries.map((entry) {
                  final percentage = (entry.value / total) * 100;
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    color: colors[entry.key - 1],
                    radius: 50,
                    title: '${percentage.toStringAsFixed(0)}%',
                    titleStyle: theme.labelSmall.override(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(5, (index) {
              final count = moodDistribution[index + 1] ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(emojis[index], style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text('$count', style: theme.labelMedium),
                  ],
                ),
              );
            }),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Distribuição de Humor', style: theme.titleMedium),
        const SizedBox(height: 16),
        GradientCard(child: SizedBox(height: 200, child: chartContent)),
      ],
    );
  }
}
