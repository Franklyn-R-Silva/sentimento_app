// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/core/theme.dart';
import 'goals.model.dart';
import 'widgets/celebration_overlay.dart';
import 'widgets/goal_card.dart';
import 'widgets/goals_add_sheet.dart';
import 'widgets/goals_empty_state.dart';
import 'widgets/goals_header.dart';
import 'widgets/goals_stats_row.dart';

export 'goals.model.dart';

class GoalsPageWidget extends StatefulWidget {
  const GoalsPageWidget({super.key});

  static const String routeName = 'Goals';
  static const String routePath = '/goals';

  @override
  State<GoalsPageWidget> createState() => _GoalsPageWidgetState();
}

class _GoalsPageWidgetState extends State<GoalsPageWidget>
    with TickerProviderStateMixin {
  late GoalsModel _model;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GoalsModel());
    _model.loadMetas();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fabController.forward();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _showAddGoalSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalsAddSheet(
        onSave:
            ({
              required titulo,
              required metaValor,
              required icone,
              required cor,
              required frequencia,
              descricao,
            }) async {
              await _model.addMeta(
                titulo: titulo,
                descricao: descricao,
                metaValor: metaValor,
                icone: icone,
                cor: cor,
                frequencia: frequencia,
              );
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GoalsModel>.value(
      value: _model,
      child: Consumer<GoalsModel>(
        builder: (context, model, child) {
          final theme = FlutterFlowTheme.of(context);

          return Scaffold(
            backgroundColor: theme.primaryBackground,
            floatingActionButton: ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton.extended(
                onPressed: () => _showAddGoalSheet(context),
                backgroundColor: theme.primary,
                elevation: 8,
                heroTag: 'add_goal_fab',
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  'Nova Meta',
                  style: theme.labelMedium.override(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            body: Stack(
              children: [
                SafeArea(
                  child: model.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: model.loadMetas,
                          color: theme.primary,
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              // Header
                              const SliverToBoxAdapter(child: GoalsHeader()),

                              // Stats cards
                              SliverToBoxAdapter(
                                child: GoalsStatsRow(
                                  activeCount: model.metasAtivas.length,
                                  completedCount: model.metasConcluidas.length,
                                ),
                              ),

                              const SliverToBoxAdapter(
                                child: SizedBox(height: 24),
                              ),

                              // Active goals section
                              if (model.metasAtivas.isNotEmpty) ...[
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'Em andamento',
                                      style: theme.titleMedium,
                                    ),
                                  ),
                                ),
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 12),
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      final meta = model.metasAtivas[index];
                                      return GoalCard(
                                        meta: meta,
                                        index: index,
                                        onIncrement: () =>
                                            model.incrementProgress(meta),
                                        onDelete: () =>
                                            model.deleteMeta(meta.id),
                                      );
                                    }, childCount: model.metasAtivas.length),
                                  ),
                                ),
                              ],

                              // Completed goals section
                              if (model.metasConcluidas.isNotEmpty) ...[
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 16),
                                ),
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'Concluídas 🎉',
                                      style: theme.titleMedium,
                                    ),
                                  ),
                                ),
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 12),
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final meta =
                                            model.metasConcluidas[index];
                                        return GoalCard(
                                          meta: meta,
                                          index:
                                              index + model.metasAtivas.length,
                                        );
                                      },
                                      childCount: model.metasConcluidas.length,
                                    ),
                                  ),
                                ),
                              ],

                              // Empty state
                              if (model.metas.isEmpty)
                                const SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: GoalsEmptyState(),
                                ),

                              // Bottom padding for FAB
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 100),
                              ),
                            ],
                          ),
                        ),
                ),

                // Celebration overlay
                if (model.showCelebration)
                  CelebrationOverlay(
                    emoji: model.celebrationEmoji ?? '🎯',
                    onComplete: () => model.hideCelebration(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
