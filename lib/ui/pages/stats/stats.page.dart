// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/backend/services/data_refresh_service.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/core/theme.dart';
import 'stats.model.dart';
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
                        StatsOverview(
                          averageMood: model.averageMood,
                          totalEntries: model.totalEntries,
                          currentStreak: model.currentStreak,
                        ),

                        const SizedBox(height: 24),

                        // Mood average indicator
                        StatsMoodBreakdown(
                          averageMood: model.averageMood,
                          totalEntries: model.totalEntries,
                        ),

                        const SizedBox(height: 24),

                        // Distribution chart
                        StatsDistributionChart(
                          moodDistribution: model.moodDistribution,
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
