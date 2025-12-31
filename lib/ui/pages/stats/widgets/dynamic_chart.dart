// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/entradas_humor.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/shared/widgets/gradient_card.dart';
import '../stats.model.dart';

class DynamicChart extends StatelessWidget {
  final List<EntradasHumorRow> entries;
  final StatsPeriod period;

  const DynamicChart({super.key, required this.entries, required this.period});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _buildEmptyState(context);
    }

    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.only(right: 16, left: 8, top: 16, bottom: 8),
        child: SizedBox(height: 250, child: _buildChart(context)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 48,
              color: theme.secondaryText.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Sem dados para este período',
              style: theme.bodyMedium.override(color: theme.secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    switch (period) {
      case StatsPeriod.daily:
        return _buildDailyChart(context);
      case StatsPeriod.weekly:
        return _buildWeeklyChart(context);
      case StatsPeriod.monthly:
        return _buildMonthlyChart(context);
      case StatsPeriod.annual:
        return _buildAnnualChart(context);
    }
  }

  Widget _buildDailyChart(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    // Group by hour
    final Map<int, List<int>> hourlyMoods = {};
    for (var entry in entries) {
      hourlyMoods.putIfAbsent(entry.criadoEm.hour, () => []);
      hourlyMoods[entry.criadoEm.hour]!.add(entry.nota);
    }

    final List<FlSpot> spots = [];
    hourlyMoods.forEach((hour, moods) {
      final avg = moods.reduce((a, b) => a + b) / moods.length;
      spots.add(FlSpot(hour.toDouble(), avg));
    });
    spots.sort((a, b) => a.x.compareTo(b.x));

    return LineChart(
      LineChartData(
        minY: 1,
        maxY: 5,
        minX: 0,
        maxX: 23,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 4,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}h', style: theme.labelSmall);
              },
            ),
          ),
          leftTitles: _buildMoodAxisTitles(),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: theme.primary.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    // Group by weekday (1=Mon, 7=Sun)
    final Map<int, List<int>> dayMoods = {};
    for (var entry in entries) {
      dayMoods.putIfAbsent(entry.criadoEm.weekday, () => []);
      dayMoods[entry.criadoEm.weekday]!.add(entry.nota);
    }

    final List<FlSpot> spots = [];
    dayMoods.forEach((day, moods) {
      final avg = moods.reduce((a, b) => a + b) / moods.length;
      spots.add(FlSpot((day - 1).toDouble(), avg)); // 0-6 index
    });
    spots.sort((a, b) => a.x.compareTo(b.x));

    final weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    return LineChart(
      LineChartData(
        minY: 1,
        maxY: 5,
        minX: 0,
        maxX: 6,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < 7) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      weekDays[value.toInt()],
                      style: theme.labelSmall,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: _buildMoodAxisTitles(),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.secondary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: theme.secondary.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    // Group by day of month
    final Map<int, List<int>> dayMoods = {};
    for (var entry in entries) {
      dayMoods.putIfAbsent(entry.criadoEm.day, () => []);
      dayMoods[entry.criadoEm.day]!.add(entry.nota);
    }

    final List<FlSpot> spots = [];
    dayMoods.forEach((day, moods) {
      final avg = moods.reduce((a, b) => a + b) / moods.length;
      spots.add(FlSpot(day.toDouble(), avg));
    });
    spots.sort((a, b) => a.x.compareTo(b.x));

    final daysInMonth = DateTime(
      DateTime.now().year,
      DateTime.now().month + 1,
      0,
    ).day;

    return LineChart(
      LineChartData(
        minY: 1,
        maxY: 5,
        minX: 1,
        maxX: daysInMonth.toDouble(),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(), style: theme.labelSmall);
              },
            ),
          ),
          leftTitles: _buildMoodAxisTitles(),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF4CAF50),
            barWidth: 2,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnualChart(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    // Group by month
    final Map<int, List<int>> monthMoods = {};
    for (var entry in entries) {
      monthMoods.putIfAbsent(entry.criadoEm.month, () => []);
      monthMoods[entry.criadoEm.month]!.add(entry.nota);
    }

    final List<BarChartGroupData> barGroups = [];
    for (int i = 1; i <= 12; i++) {
      if (monthMoods.containsKey(i)) {
        final moods = monthMoods[i]!;
        final avg = moods.reduce((a, b) => a + b) / moods.length;
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: avg,
                color: theme.primary,
                width: 12,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }
    }

    final months = [
      '',
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 5,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 1 && value.toInt() <= 12) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      months[value.toInt()].substring(0, 1),
                      style: theme.labelSmall,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: _buildMoodAxisTitles(),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barGroups: barGroups,
      ),
    );
  }

  AxisTitles _buildMoodAxisTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: 1,
        getTitlesWidget: (value, meta) {
          const emojis = ['😢', '😟', '😐', '🙂', '😄'];
          if (value.toInt() >= 1 && value.toInt() <= 5) {
            return Text(
              emojis[value.toInt() - 1],
              style: const TextStyle(fontSize: 12),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
