// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:sentimento_app/backend/tables/gym_exercises.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/pages/gym/gym_focus_model.dart';
import 'package:sentimento_app/ui/pages/gym/widgets/gym_exercise_carousel.dart';
import 'package:sentimento_app/ui/pages/gym/widgets/gym_rest_timer.dart';
import 'package:sentimento_app/ui/pages/gym/widgets/gym_stats.dart';

class GymFocusPage extends StatefulWidget {
  const GymFocusPage({
    super.key,
    required this.exercises,
    this.initialIndex = 0,
  });

  static const routeName = 'GymFocus';
  static const routePath = '/gym/focus';

  final List<GymExercisesRow> exercises;
  final int initialIndex;

  @override
  State<GymFocusPage> createState() => _GymFocusPageState();
}

class _GymFocusPageState extends State<GymFocusPage> {
  late PageController _pageController;
  late GymFocusModel _model;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _model = GymFocusModel(
      exercises: widget.exercises,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return ChangeNotifierProvider.value(
      value: _model,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              ),
            ),
          ),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Consumer<GymFocusModel>(
            builder: (context, model, _) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                '${model.currentIndex + 1} / ${model.exercises.length}',
                style: theme.bodyMedium.override(
                  fontFamily: 'Outfit',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            Consumer<GymFocusModel>(
              builder: (context, model, _) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(
                    model.currentExercise.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                    color: model.currentExercise.isCompleted
                        ? Theme.of(context).primaryColor
                        : Colors.white.withOpacity(0.5),
                    size: 32,
                  ),
                  onPressed: () async {
                    try {
                      await model.toggleComplete();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao atualizar: $e'),
                            backgroundColor: theme.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        body: Consumer<GymFocusModel>(
          builder: (context, model, _) => Column(
            children: [
              SizedBox(
                height:
                    MediaQuery.of(context).padding.top + kToolbarHeight + 10,
              ),

              // Custom Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: model.progress > 0 ? model.progress : 0.01,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.primary, theme.tertiary],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primary.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Exercise PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: model.exercises.length,
                  onPageChanged: (index) => model.goToIndex(index),
                  itemBuilder: (context, index) {
                    final exercise = model.exercises[index];
                    return _buildExerciseView(context, exercise, theme);
                  },
                ),
              ),

              // Timer Widget
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GymRestTimer(
                  key: ValueKey('timer_${model.currentExercise.id}'),
                  defaultSeconds: model.currentExercise.restTime ?? 60,
                  onComplete: () async {
                    if (!model.currentExercise.isCompleted) {
                      try {
                        await model.toggleComplete();
                      } catch (e) {
                        // Error handling already in toggleComplete or upper
                      }
                    }
                  },
                ),
              ),

              // Navigation Buttons
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black,
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Previous Button
                    if (model.currentIndex > 0)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.fastOutSlowIn,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                      )
                    else
                      const Spacer(),

                    const SizedBox(width: 16),

                    // Next/Finish Button
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [theme.primary, theme.tertiary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (model.currentIndex <
                                model.exercises.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.fastOutSlowIn,
                              );
                            } else {
                              _showCompletionDialog(context, model);
                            }
                          },
                          icon: Icon(
                            model.currentIndex < model.exercises.length - 1
                                ? Icons.arrow_forward_rounded
                                : Icons.emoji_events_rounded,
                            color: Colors.white,
                          ),
                          label: Text(
                            model.currentIndex < model.exercises.length - 1
                                ? 'Próximo'
                                : 'Finalizar',
                            style: theme.titleSmall.override(
                              fontFamily: 'Outfit',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseView(
    BuildContext context,
    GymExercisesRow exercise,
    FlutterFlowTheme theme,
  ) {
    // Parse image URLs
    List<String> imageUrls = [];
    final url = exercise.machinePhotoUrl;
    if (url != null && url.isNotEmpty) {
      if (url.trim().startsWith('[')) {
        try {
          final clean = url.trim().substring(1, url.trim().length - 1);
          if (clean.isNotEmpty) {
            imageUrls = clean
                .split(',')
                .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ''))
                .toList();
          }
        } catch (_) {
          imageUrls = [url];
        }
      } else {
        imageUrls = [url];
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Workout Name Tag
          Consumer<GymFocusModel>(
            builder: (context, model, _) {
              final workoutId = exercise.workoutId;
              String? workoutName;
              if (workoutId != null) {
                final found = model.workouts.where((w) => w.id == workoutId);
                if (found.isNotEmpty) {
                  workoutName = found.first.name;
                }
              }

              if (workoutName == null) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  workoutName.toUpperCase(),
                  style: theme.labelSmall.override(
                    fontFamily: 'Outfit',
                    color: theme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              );
            },
          ),

          // Exercise Name
          Text(
            exercise.name,
            style: theme.headlineLarge.override(
              fontFamily: 'Outfit',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Tags Row
          if (exercise.category != null || exercise.muscleGroup != null)
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (exercise.category != null)
                  _buildTag(exercise.category!, theme.secondary, theme),
                if (exercise.muscleGroup != null)
                  _buildTag(exercise.muscleGroup!, theme.tertiary, theme),
              ],
            ),
          const SizedBox(height: 32),

          // Main Stats Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Sets
                _buildStatItem(
                  '${exercise.sets ?? exercise.exerciseSeries ?? "-"}',
                  'Séries',
                  FontAwesomeIcons.layerGroup,
                  theme.primary,
                  theme,
                ),
                _buildVerticalDivider(),

                // Reps or Time
                if (exercise.exerciseTime != null &&
                    exercise.exerciseTime!.isNotEmpty)
                  _buildStatItem(
                    exercise.exerciseTime!,
                    'Tempo',
                    Icons.timer_outlined,
                    theme.secondary,
                    theme,
                  )
                else
                  _buildStatItem(
                    exercise.reps ?? '${exercise.exerciseQty ?? "-"}',
                    'Reps',
                    Icons.repeat_rounded,
                    theme.secondary,
                    theme,
                  ),

                _buildVerticalDivider(),

                // Weight
                _buildStatItem(
                  '${exercise.weight ?? "-"}',
                  'kg',
                  FontAwesomeIcons.weightHanging,
                  theme.tertiary,
                  theme,
                ),
              ],
            ),
          ),

          // Secondary Stats Row (if has data)
          if ((exercise.elevation != null && exercise.elevation! > 0) ||
              (exercise.speed != null && exercise.speed! > 0)) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (exercise.elevation != null && exercise.elevation! > 0)
                    _buildSecondaryStat(
                      'Elevação',
                      '${exercise.elevation!}%',
                      Icons.trending_up,
                      theme,
                    ),
                  if ((exercise.elevation != null && exercise.elevation! > 0) &&
                      (exercise.speed != null && exercise.speed! > 0))
                    const SizedBox(width: 32),
                  if (exercise.speed != null && exercise.speed! > 0)
                    _buildSecondaryStat(
                      'Velocidade',
                      '${exercise.speed!}',
                      Icons.speed,
                      theme,
                    ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Image Carousel
          if (imageUrls.isNotEmpty)
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GymExerciseCarousel(imageUrls: imageUrls),
            ),

          // Description
          if (exercise.description != null && exercise.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Observações',
                    style: theme.labelMedium.override(
                      fontFamily: 'Outfit',
                      color: theme.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Text(
                      exercise.description!,
                      style: theme.bodyMedium.override(
                        fontFamily: 'Outfit',
                        color: Colors.white.withOpacity(0.8),
                        lineHeight: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // History Section
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Histórico',
              style: theme.titleMedium.override(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          GymExerciseHistory(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
          ),
          // Extra Space for scrolling past buttons
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color, FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: theme.bodySmall.override(
          fontFamily: 'Outfit',
          color: color.withOpacity(0.9),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
    FlutterFlowTheme theme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: theme.headlineMedium.override(
            fontFamily: 'Outfit',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: theme.labelSmall.override(
            fontFamily: 'Outfit',
            color: Colors.white38,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryStat(
    String label,
    String value,
    IconData icon,
    FlutterFlowTheme theme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.bodyLarge.override(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.labelSmall.override(
                fontFamily: 'Outfit',
                color: Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.1),
    );
  }

  void _showCompletionDialog(BuildContext context, GymFocusModel model) {
    final completed = model.exercises.where((e) => e.isCompleted).length;
    final total = model.exercises.length;
    final theme = FlutterFlowTheme.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 48,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Treino Finalizado!',
              style: theme.headlineMedium.override(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Você completou $completed de $total exercícios.\nExcelente trabalho!',
              style: theme.bodyLarge.override(
                fontFamily: 'Outfit',
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Voltar para o início'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
