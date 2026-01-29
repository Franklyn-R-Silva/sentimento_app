// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/gym_workouts.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/core/util.dart';
import 'package:sentimento_app/ui/pages/gym/gym_list_model.dart';
import 'package:sentimento_app/ui/pages/gym/widgets/gym_celebration.dart';
import 'package:sentimento_app/ui/pages/gym/widgets/gym_empty_state.dart';
import 'package:sentimento_app/ui/pages/gym/widgets/gym_exercise_card.dart';
import 'package:sentimento_app/ui/pages/gym/widgets/gym_stats.dart';

class GymListPage extends StatefulWidget {
  const GymListPage({super.key});

  static String routeName = 'GymList';
  static String routePath = '/gym';

  @override
  State<GymListPage> createState() => _GymListPageState();
}

class _GymListPageState extends State<GymListPage> {
  late GymListModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GymListModel());
    _model.loadData();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }
    final theme = FlutterFlowTheme.of(context);

    return ChangeNotifierProvider.value(
      value: _model,
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await context.pushNamedAuth('GymRegister', mounted);
            await _model.loadData();
          },
          backgroundColor: theme.primary,
          elevation: 8,
          tooltip: 'Novo Exercício',
          child: Icon(
            Icons.add_rounded,
            color: theme.primaryBackground,
            size: 24,
          ),
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        'Treino do Dia',
                        maxLines: 1,
                        style: theme.displaySmall.override(
                          fontFamily: 'Outfit',
                          color: theme.primaryText,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Focus Mode Play Button
                        Consumer<GymListModel>(
                          builder: (context, model, _) => IconButton(
                            icon: Icon(
                              Icons.play_circle_filled_rounded,
                              color: model.todaysExercises.isNotEmpty
                                  ? theme.tertiary
                                  : theme.alternate,
                              size: 28,
                            ),
                            tooltip: 'Modo Foco',
                            onPressed: model.todaysExercises.isNotEmpty
                                ? () async {
                                    await context.push(
                                      '/gym/focus',
                                      extra: model.todaysExercises,
                                    );
                                    await model.loadData();
                                  }
                                : null,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: theme.secondaryText, // Less prominent
                            size: 24,
                          ),
                          tooltip: 'Reiniciar Treino',
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Reiniciar Treino?'),
                                content: const Text(
                                  'Deseja marcar todos os exercícios de hoje como não concluídos?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Sim'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              await _model.resetDailyWorkout();
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.calendar_today_rounded,
                            color: theme.primary,
                            size: 24,
                          ),
                          onPressed: () async {
                            await context.pushNamedAuth('GymManager', mounted);
                            await _model.loadData();
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            FontAwesomeIcons.dumbbell,
                            color: theme.primary,
                            size: 20,
                          ),
                          tooltip: 'Estatísticas',
                          onPressed: () {
                            showDialog<void>(
                              context: context,
                              builder: (context) => const GymStatsDialog(),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<GymListModel>(
                  builder: (context, model, child) {
                    if (model.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(color: theme.primary),
                      );
                    }

                    if (model.todaysExercises.isEmpty) {
                      return GymEmptyState(
                        message: 'Nenhum treino cadastrado\npara hoje',
                        onAction: () async {
                          await context.pushNamedAuth('GymManager', mounted);
                          await model.loadData();
                        },
                        actionLabel: 'Gerenciar Treinos',
                      );
                    }

                    return GymCelebration(
                      isComplete: model.isAllComplete,
                      child: Column(
                        children: [
                          // Progress bar
                          GymProgressBar(
                            completed: model.completedCount,
                            total: model.todaysExercises.length,
                          ),
                          // Exercise list with pull to refresh
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () => model.loadData(),
                              color: theme.primary,
                              child: ReorderableListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(24),
                                itemCount: model.todaysExercises.length,
                                onReorder: (oldIndex, newIndex) {
                                  model.reorderExercises(oldIndex, newIndex);
                                },
                                itemBuilder: (context, index) {
                                  final exercise = model.todaysExercises[index];
                                  final previousExercise = index > 0
                                      ? model.todaysExercises[index - 1]
                                      : null;

                                  GymWorkoutsRow? workout;
                                  bool showHeader = false;

                                  if (exercise.workoutId != null) {
                                    final found = model.userWorkouts.where(
                                      (w) => w.id == exercise.workoutId,
                                    );
                                    if (found.isNotEmpty) {
                                      workout = found.first;
                                      if (previousExercise == null ||
                                          previousExercise.workoutId !=
                                              exercise.workoutId) {
                                        showHeader = true;
                                      }
                                    }
                                  }

                                  return Column(
                                    key: ValueKey(exercise.id),
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (showHeader && workout != null)
                                        _buildWorkoutHeader(
                                          context,
                                          workout,
                                          theme,
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: GymExerciseCard(
                                          exercise: exercise,
                                          index: index,
                                          onRefresh: () => model.loadData(),
                                          onMoveToTop: () =>
                                              model.moveToTop(exercise.id),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutHeader(
    BuildContext context,
    GymWorkoutsRow workout,
    FlutterFlowTheme theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: theme.tertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: theme.titleLarge.override(
                      fontFamily: 'Outfit',
                      color: theme.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (workout.muscleGroups != null &&
                      workout.muscleGroups!.isNotEmpty)
                    Text(
                      workout.muscleGroups!,
                      style: theme.labelMedium.override(
                        fontFamily: 'Outfit',
                        color: theme.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (workout.description != null && workout.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text(
                workout.description!,
                style: theme.bodySmall.override(
                  fontFamily: 'Outfit',
                  color: theme.secondaryText,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
