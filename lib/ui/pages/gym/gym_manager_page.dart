// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/gym_exercises.dart';
import 'package:sentimento_app/backend/tables/gym_workouts.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/core/util.dart';
import 'package:sentimento_app/ui/pages/gym/gym_manager_model.dart';
import 'package:sentimento_app/ui/pages/gym/gym_register_page.dart';
import 'package:sentimento_app/ui/pages/gym/widgets/gym_empty_state.dart';
import 'package:sentimento_app/ui/pages/gym/widgets/gym_exercise_card.dart';

class GymManagerPage extends StatefulWidget {
  const GymManagerPage({super.key});

  static String routeName = 'GymManager';
  static String routePath = '/gym/manager';

  @override
  State<GymManagerPage> createState() => _GymManagerPageState();
}

class _GymManagerPageState extends State<GymManagerPage> {
  late GymManagerModel _model;

  final List<String> days = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GymManagerModel());
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
      child: DefaultTabController(
        length: days.length,
        child: Consumer<GymManagerModel>(
          builder: (context, model, _) {
            final shortDays = days.map((d) => d.substring(0, 3)).toList();

            return Scaffold(
              backgroundColor: theme.primaryBackground,
              appBar: AppBar(
                backgroundColor: model.isSelectionMode
                    ? Colors.grey[800]
                    : theme.primary,
                automaticallyImplyLeading: !model.isSelectionMode,
                leading: model.isSelectionMode
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => model.clearSelection(),
                      )
                    : const BackButton(color: Colors.white),
                title: Text(
                  model.isSelectionMode
                      ? '${model.selectedCount} selecionado(s)'
                      : 'Gerenciar Treinos',
                  style: theme.headlineMedium.override(
                    fontFamily: 'Outfit',
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                actions: model.isSelectionMode
                    ? [
                        IconButton(
                          icon: const Icon(
                            Icons.drive_file_move_outlined,
                            color: Colors.white,
                          ),
                          tooltip: 'Mover selecionados',
                          onPressed: model.selectedCount > 0
                              ? () => _showMoveSelectedDialog(context, model)
                              : null,
                        ),
                      ]
                    : [
                        IconButton(
                          icon: const Icon(
                            Icons.checklist_rounded,
                            color: Colors.white,
                          ),
                          tooltip: 'Modo seleção',
                          onPressed: () => model.toggleSelectionMode(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: () => model.loadData(),
                        ),
                      ],
                centerTitle: false,
                elevation: 2,
                bottom: TabBar(
                  isScrollable: true,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xB3FFFFFF),
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelStyle: theme.titleSmall.override(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: shortDays.map((d) => Tab(text: d)).toList(),
                ),
              ),
              body: _buildBody(context, model, theme),
              floatingActionButton: model.isSelectionMode
                  ? null
                  : FloatingActionButton(
                      onPressed: () async {
                        await context.pushNamed(GymRegisterPage.routeName);
                        await model.loadData();
                      },
                      backgroundColor: theme.primary,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    GymManagerModel model,
    FlutterFlowTheme theme,
  ) {
    if (model.isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.primary));
    }

    return TabBarView(
      children: days.map((day) {
        final exercises = model.exercisesByDay[day] ?? [];

        if (exercises.isEmpty) {
          return GymEmptyState(
            message: 'Sem exercícios para $day',
            icon: Icons.fitness_center_outlined,
            actionLabel: 'Adicionar',
            onAction: () async {
              await context.pushNamed(GymRegisterPage.routeName);
              await model.loadData();
            },
          );
        }

        return _buildDayContent(context, model, day, exercises, theme);
      }).toList(),
    );
  }

  Widget _buildDayContent(
    BuildContext context,
    GymManagerModel model,
    String day,
    List<GymExercisesRow> exercises,
    FlutterFlowTheme theme,
  ) {
    return Column(
      children: [
        // Action buttons row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              // Move all exercises button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showMoveAllDialog(context, model, day, exercises.length),
                  icon: const Icon(Icons.drive_file_move, color: Colors.white),
                  label: Text(
                    'Mover Todos',
                    style: theme.titleSmall.override(
                      fontFamily: 'Outfit',
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Shift/postpone button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showShiftDayDialog(context, model, day),
                  icon: const Icon(
                    Icons.more_time_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Adiar Treino',
                    style: theme.titleSmall.override(
                      fontFamily: 'Outfit',
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Selection hint
        if (model.isSelectionMode)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => model.selectAll(day),
                  child: const Text('Selecionar todos'),
                ),
              ],
            ),
          ),
        // Exercise list
        Expanded(
          child: model.isSelectionMode
              ? ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    final previousExercise = index > 0
                        ? exercises[index - 1]
                        : null;

                    GymWorkoutsRow? workout;
                    bool showHeader = false;

                    if (exercise.workoutId != null) {
                      final found = model.workouts.where(
                        (w) => w.id == exercise.workoutId,
                      );
                      if (found.isNotEmpty) {
                        workout = found.first;
                        if (previousExercise == null ||
                            previousExercise.workoutId != exercise.workoutId) {
                          showHeader = true;
                        }
                      }
                    }

                    final isSelected = model.isExerciseSelected(exercise.id);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader && workout != null)
                          _buildWorkoutHeader(context, workout, theme),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () =>
                                model.toggleExerciseSelection(exercise.id),
                            child: Stack(
                              children: [
                                GymExerciseCard(
                                  exercise: exercise,
                                  workoutName: workout?.name,
                                  onRefresh: () => model.loadData(),
                                  isReorderable: false,
                                ),
                                if (isSelected)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.primary.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: theme.primary,
                                          width: 3,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 48,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: exercises.length,
                  onReorder: (oldIndex, newIndex) {
                    model.reorderExercises(day, oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    final previousExercise = index > 0
                        ? exercises[index - 1]
                        : null;

                    GymWorkoutsRow? workout;
                    bool showHeader = false;

                    if (exercise.workoutId != null) {
                      final found = model.workouts.where(
                        (w) => w.id == exercise.workoutId,
                      );
                      if (found.isNotEmpty) {
                        workout = found.first;
                        if (previousExercise == null ||
                            previousExercise.workoutId != exercise.workoutId) {
                          showHeader = true;
                        }
                      }
                    }

                    return Column(
                      key: ValueKey(exercise.id),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader && workout != null)
                          _buildWorkoutHeader(context, workout, theme),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GymExerciseCard(
                            exercise: exercise,
                            workoutName: workout?.name,
                            index: index,
                            onRefresh: () => model.loadData(),
                            onMoveToTop: () =>
                                model.moveToTop(day, exercise.id),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildWorkoutHeader(
    BuildContext context,
    GymWorkoutsRow workout,
    FlutterFlowTheme theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.tertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                workout.name,
                style: theme.titleMedium.override(
                  fontFamily: 'Outfit',
                  color: theme.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (workout.description != null && workout.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
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

  void _showMoveAllDialog(
    BuildContext context,
    GymManagerModel model,
    String sourceDay,
    int count,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mover Todos os Exercícios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mover $count exercício(s) de $sourceDay para:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: days
                  .where((d) => d != sourceDay)
                  .map(
                    (d) => ActionChip(
                      label: Text(d),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await model.moveAllExercises(sourceDay, d);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$count exercício(s) movido(s) para $d',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showMoveSelectedDialog(BuildContext context, GymManagerModel model) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mover Selecionados'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mover ${model.selectedCount} exercício(s) para:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: days
                  .map(
                    (d) => ActionChip(
                      label: Text(d),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final count = model.selectedCount;
                        await model.moveSelectedExercises(d);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$count exercício(s) movido(s) para $d',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showShiftDayDialog(
    BuildContext context,
    GymManagerModel model,
    String day,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adiar Treino'),
        content: Text(
          'Isso moverá todos os treinos de $day para o dia seguinte, e assim por diante.\n\nTem certeza?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sim, Adiar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await model.shiftDay(day);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agenda deslocada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
