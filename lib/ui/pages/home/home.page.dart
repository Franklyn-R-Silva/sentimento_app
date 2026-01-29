// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/backend/services/data_refresh_service.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/pages/home/widgets/daily_quote_widget.dart';
import 'package:sentimento_app/ui/pages/home/widgets/home_add_mood_sheet.dart';
import 'package:sentimento_app/ui/pages/home/widgets/home_empty_state.dart';
import 'package:sentimento_app/ui/pages/home/widgets/home_header.dart';
import 'package:sentimento_app/ui/pages/home/widgets/mood_card.dart';
import 'package:sentimento_app/ui/pages/home/widgets/mood_streak.dart';
import 'package:sentimento_app/ui/pages/home/widgets/weekly_chart.dart';
import 'package:sentimento_app/ui/shared/widgets/gradient_card.dart';
import 'home.model.dart';

export 'home.model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static const String routeName = 'HomePage';
  static const String routePath = '/home';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget>
    with AutomaticKeepAliveClientMixin {
  late HomeModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());
    _model.loadData();
    DataRefreshService.instance.addListener(_onDataRefresh);
  }

  Future<void> _loadData() async {
    await _model.loadData();
  }

  @override
  void dispose() {
    DataRefreshService.instance.removeListener(_onDataRefresh);
    _model.dispose();
    super.dispose();
  }

  void _onDataRefresh() {
    if (mounted) {
      _model.loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure KeepAlive works
    Logger().t('HomePage: build called');

    return ChangeNotifierProvider<HomeModel>.value(
      value: _model,
      child: Consumer<HomeModel>(
        builder: (context, model, child) {
          final theme = FlutterFlowTheme.of(context);

          return Scaffold(
            key: scaffoldKey,
            backgroundColor: theme.primaryBackground,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showAddMoodSheet(context),
              backgroundColor: theme.primary,
              elevation: 8,
              heroTag: 'home_add_mood_fab',
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Registrar',
                style: theme.labelMedium.override(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: SafeArea(
              child: model.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: theme.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with greeting
                              HomeHeader(recentEntries: model.recentEntries)
                                  .animate()
                                  .fade(duration: 400.ms)
                                  .slideY(begin: -0.2, end: 0),

                              const SizedBox(height: 24),

                              // Daily Quote
                              const DailyQuoteWidget()
                                  .animate()
                                  .fade(delay: 50.ms)
                                  .slideX(begin: -0.1, end: 0),

                              const SizedBox(height: 24),

                              // Streak widget
                              MoodStreak(
                                    streakDays: model.currentStreak,
                                    longestStreak: model.longestStreak,
                                  )
                                  .animate()
                                  .fade(delay: 100.ms)
                                  .slideX(begin: 0.1, end: 0),

                              const SizedBox(height: 24),

                              // Weekly chart section
                              Text('Sua Semana', style: theme.titleMedium),
                              const SizedBox(height: 12),
                              GradientCard(
                                    margin: EdgeInsets.zero,
                                    child: WeeklyChart(
                                      entries: model.weeklyEntries,
                                    ),
                                  )
                                  .animate()
                                  .fade(delay: 150.ms)
                                  .scale(
                                    alignment: Alignment.bottomCenter,
                                    begin: const Offset(0.9, 0.9),
                                  ),

                              const SizedBox(height: 24),

                              // Recent entries
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Entradas Recentes',
                                    style: theme.titleMedium,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Navigate to journal - handled by bottom nav
                                    },
                                    child: Text(
                                      'Ver todas',
                                      style: theme.labelMedium.override(
                                        color: theme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ).animate().fade().slideY(
                                begin: 0.5,
                                end: 0,
                                delay: 200.ms,
                              ),
                              const SizedBox(height: 8),

                              if (model.recentEntries.isEmpty)
                                const HomeEmptyState().animate().fade().scale()
                              else
                                ...model.recentEntries
                                    .take(5)
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) =>
                                          MoodCard(
                                                entry: entry.value,
                                                onTap: () {},
                                              )
                                              .animate(
                                                delay: (100 * entry.key).ms,
                                              )
                                              .fade()
                                              .slideX(begin: 0.2, end: 0),
                                    ),

                              const SizedBox(height: 100), // Space for FAB
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  void _showAddMoodSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HomeAddMoodSheet(
        onSave: (mood, note, tags) {
          if (_model.isAddingEntry) return;
          Navigator.pop(context);
          _model.addEntry(context, mood, note, tags);
        },
      ),
    );
  }
}
