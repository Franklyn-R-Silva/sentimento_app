import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/shared/widgets/gradient_card.dart';
import 'package:sentimento_app/ui/shared/widgets/mood_indicator.dart';
import 'stats.model.dart';

export 'stats.model.dart';

class StatsPageWidget extends StatefulWidget {
  const StatsPageWidget({super.key});

  static const String routeName = 'Stats';
  static const String routePath = '/stats';

  @override
  State<StatsPageWidget> createState() => _StatsPageWidgetState();
}

class _StatsPageWidgetState extends State<StatsPageWidget> {
  late StatsModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StatsModel());
    _model.loadStats();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StatsModel>.value(
      value: _model,
      child: Consumer<StatsModel>(
        builder: (context, model, child) {
          final theme = FlutterFlowTheme.of(context);

          return Scaffold(
            backgroundColor: theme.primaryBackground,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Estatísticas',
                style: theme.headlineMedium.override(color: theme.primaryText),
              ),
              centerTitle: false,
            ),
            body: model.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overview cards
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Média de Humor',
                                value: model.averageMood.toStringAsFixed(1),
                                icon: Icons.trending_up_rounded,
                                color: theme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Total de Registros',
                                value: model.totalEntries.toString(),
                                icon: Icons.edit_note_rounded,
                                color: theme.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _StatCard(
                          title: 'Sequência Atual',
                          value: '${model.currentStreak} dias 🔥',
                          icon: Icons.local_fire_department_rounded,
                          color: const Color(0xFFFF6B35),
                        ),

                        const SizedBox(height: 24),

                        // Mood average indicator
                        Text('Seu Humor', style: theme.titleMedium),
                        const SizedBox(height: 16),
                        GradientCard(
                          moodLevel: model.averageMood.round(),
                          child: Row(
                            children: [
                              MoodIndicator(
                                value: model.averageMood / 5,
                                size: 100,
                                moodLevel: model.averageMood.round(),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Média Geral',
                                      style: theme.titleSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getMoodLabel(model.averageMood),
                                      style: theme.headlineSmall.override(
                                        color: theme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Baseado em ${model.totalEntries} registros',
                                      style: theme.labelSmall.override(
                                        color: theme.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Distribution chart
                        Text('Distribuição de Humor', style: theme.titleMedium),
                        const SizedBox(height: 16),
                        GradientCard(
                          child: SizedBox(
                            height: 200,
                            child: _buildDistributionChart(context, model),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  String _getMoodLabel(double mood) {
    if (mood < 1.5) return 'Muito Triste';
    if (mood < 2.5) return 'Triste';
    if (mood < 3.5) return 'Neutro';
    if (mood < 4.5) return 'Feliz';
    return 'Muito Feliz';
  }

  Widget _buildDistributionChart(BuildContext context, StatsModel model) {
    final theme = FlutterFlowTheme.of(context);
    final colors = [
      const Color(0xFFE53935),
      const Color(0xFFFF9800),
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      theme.primary,
    ];
    final emojis = ['😢', '😟', '😐', '🙂', '😄'];

    final total = model.moodDistribution.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return Center(
        child: Text(
          'Sem dados suficientes',
          style: theme.bodyMedium.override(color: theme.secondaryText),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: model.moodDistribution.entries.map((entry) {
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
            final count = model.moodDistribution[index + 1] ?? 0;
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.headlineSmall.override(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.labelSmall.override(color: theme.secondaryText),
          ),
        ],
      ),
    );
  }
}
