import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sentimento_app/backend/tables/entradas_humor.dart';
import 'package:sentimento_app/core/theme.dart';

/// WeeklyChart - Gráfico semanal de humor
class WeeklyChart extends StatelessWidget {
  final List<EntradasHumorRow> entries;

  const WeeklyChart({super.key, required this.entries});

  static const List<String> _weekDays = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];

  List<FlSpot> _getSpots() {
    if (entries.isEmpty) return [];

    // Agrupa por dia da semana
    final Map<int, List<int>> dayMoods = {};

    for (var entry in entries) {
      final weekday = entry.criadoEm.weekday; // 1 = Monday, 7 = Sunday
      dayMoods.putIfAbsent(weekday, () => []);
      dayMoods[weekday]!.add(entry.nota);
    }

    // Calcula média por dia
    final List<FlSpot> spots = [];
    dayMoods.forEach((day, moods) {
      final avg = moods.reduce((a, b) => a + b) / moods.length;
      spots.add(FlSpot((day - 1).toDouble(), avg));
    });

    // Ordena por dia
    spots.sort((a, b) => a.x.compareTo(b.x));
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spots = _getSpots();

    if (spots.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart_rounded,
              size: 48,
              color: theme.secondaryText.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Sem dados esta semana',
              style: theme.bodyMedium.override(color: theme.secondaryText),
            ),
            const SizedBox(height: 4),
            Text(
              'Adicione seu primeiro registro!',
              style: theme.labelSmall.override(
                color: theme.secondaryText.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 16, top: 16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.alternate.withValues(alpha: 0.2),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final emojis = ['😢', '😟', '😐', '🙂', '😄'];
                  if (value.toInt() >= 1 && value.toInt() <= 5) {
                    return Text(
                      emojis[value.toInt() - 1],
                      style: const TextStyle(fontSize: 12),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < 7) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _weekDays[value.toInt()],
                        style: theme.labelSmall.override(
                          color: theme.secondaryText,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 1,
          maxY: 5,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              gradient: LinearGradient(
                colors: [theme.primary, theme.secondary],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: theme.primary,
                    strokeWidth: 2,
                    strokeColor: theme.secondaryBackground,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.primary.withValues(alpha: 0.3),
                    theme.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => theme.secondaryBackground,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final emojis = ['😢', '😟', '😐', '🙂', '😄'];
                  return LineTooltipItem(
                    emojis[(spot.y.round() - 1).clamp(0, 4)],
                    const TextStyle(fontSize: 24),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
