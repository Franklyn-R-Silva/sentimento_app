// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:logger/logger.dart';

// Project imports:
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
    Logger().t('WeeklyChart: build called with ${entries.length} entries');
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
      height: 240,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: theme.primaryText.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 20),
            child: Row(
              children: [
                Icon(Icons.show_chart_rounded, color: theme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Humor Semanal',
                  style: theme.titleMedium.override(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.alternate.withValues(alpha: 0.3),
                      strokeWidth: 1,
                      dashArray: [4, 4],
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
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final emojis = ['😢', '😟', '😐', '🙂', '😄'];
                        if (value.toInt() >= 1 && value.toInt() <= 5) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              emojis[value.toInt() - 1],
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.right,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < 7) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _weekDays[value.toInt()],
                              style: theme.labelSmall.override(
                                color: theme.secondaryText,
                                fontWeight: FontWeight.w600,
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
                minY: 0.5,
                maxY: 5.5,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    gradient: LinearGradient(
                      colors: [theme.primary, theme.tertiary],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: theme.primaryBackground,
                          strokeWidth: 3,
                          strokeColor: theme.primary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.primary.withValues(alpha: 0.25),
                          theme.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => theme.primary,
                    tooltipPadding: const EdgeInsets.all(8),
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
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
