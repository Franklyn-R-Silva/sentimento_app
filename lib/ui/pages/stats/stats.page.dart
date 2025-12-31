// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/backend/services/data_refresh_service.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/shared/widgets/app_card.dart';
import 'package:sentimento_app/ui/shared/widgets/app_section_header.dart';
import 'stats.model.dart';
import 'widgets/dynamic_chart.dart';
import 'widgets/stats_distribution_chart.dart';
import 'widgets/stats_mood_breakdown.dart';
import 'widgets/stats_overview.dart';

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
    DataRefreshService.instance.addListener(_onDataRefresh);
  }

  @override
  void dispose() {
    DataRefreshService.instance.removeListener(_onDataRefresh);
    _model.dispose();
    super.dispose();
  }

  void _onDataRefresh() {
    if (mounted) {
      _model.loadStats();
    }
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
              title: AutoSizeText(
                'Minha Evolução',
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
                        // Period Selector
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.alternate.withValues(alpha: 0.5),
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              _buildPeriodButton(
                                context,
                                'Dia',
                                StatsPeriod.daily,
                                model,
                              ),
                              _buildPeriodButton(
                                context,
                                'Semana',
                                StatsPeriod.weekly,
                                model,
                              ),
                              _buildPeriodButton(
                                context,
                                'Mês',
                                StatsPeriod.monthly,
                                model,
                              ),
                              _buildPeriodButton(
                                context,
                                'Ano',
                                StatsPeriod.annual,
                                model,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Dynamic Chart
                        const AppSectionHeader(title: 'Evolução do Humor'),
                        const SizedBox(height: 12),
                        AppCard(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DynamicChart(
                              entries: model.getFilteredEntries(),
                              period: model.selectedPeriod,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Overview cards
                        const AppSectionHeader(title: 'Visão Geral'),
                        const SizedBox(height: 12),
                        StatsOverview(
                          averageMood: model.averageMood,
                          totalEntries: model.totalEntries,
                          currentStreak: model.currentStreak,
                        ),

                        const SizedBox(height: 24),

                        // Mood average breakdown
                        const AppSectionHeader(title: 'Média por Humor'),
                        const SizedBox(height: 12),
                        AppCard(
                          child: StatsMoodBreakdown(
                            averageMood: model.averageMood,
                            totalEntries: model.totalEntries,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Distribution chart
                        const AppSectionHeader(title: 'Distribuição'),
                        const SizedBox(height: 12),
                        AppCard(
                          child: StatsDistributionChart(
                            moodDistribution: model.moodDistribution,
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodButton(
    BuildContext context,
    String label,
    StatsPeriod period,
    StatsModel model,
  ) {
    final theme = FlutterFlowTheme.of(context);
    final isSelected = model.selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: () => model.selectedPeriod = period,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.bodyMedium.override(
              color: isSelected ? Colors.white : theme.secondaryText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
