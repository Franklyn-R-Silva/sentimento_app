import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentimento_app/backend/tables/gym_exercises.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/ui/pages/gym/gym_focus_model.dart';
import 'package:sentimento_app/ui/pages/gym/widgets/gym_rest_timer.dart';
import 'package:sentimento_app/ui/pages/gym/widgets/gym_exercise_carousel.dart';

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          title: Consumer<GymFocusModel>(
            builder: (context, model, _) => Text(
              '${model.currentIndex + 1} / ${model.exercises.length}',
              style: theme.titleMedium.override(
                fontFamily: 'Outfit',
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            Consumer<GymFocusModel>(
              builder: (context, model, _) => IconButton(
                icon: Icon(
                  model.currentExercise.isCompleted
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: model.currentExercise.isCompleted
                      ? Colors.green
                      : Colors.white,
                  size: 28,
                ),
                onPressed: () => model.toggleComplete(),
              ),
            ),
          ],
        ),
        body: Consumer<GymFocusModel>(
          builder: (context, model, _) => Column(
            children: [
              // Progress Bar (shows completed exercises)
              LinearProgressIndicator(
                value:
                    model.progress, // Use completed/total instead of position
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  model.progress >= 1.0 ? Colors.green : theme.primary,
                ),
                minHeight: 4,
              ),

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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GymRestTimer(
                  defaultSeconds: model.currentExercise.restTime ?? 60,
                ),
              ),

              // Navigation Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Previous Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: model.currentIndex > 0
                            ? () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Anterior'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Next/Finish Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (model.currentIndex < model.exercises.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            // Finished all exercises
                            _showCompletionDialog(context, model);
                          }
                        },
                        icon: Icon(
                          model.currentIndex < model.exercises.length - 1
                              ? Icons.arrow_forward
                              : Icons.celebration,
                        ),
                        label: Text(
                          model.currentIndex < model.exercises.length - 1
                              ? 'Próximo'
                              : 'Finalizar! 🎉',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Exercise Name
          Text(
            exercise.name,
            style: theme.headlineLarge.override(
              fontFamily: 'Outfit',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Category & Muscle Group
          if (exercise.category != null || exercise.muscleGroup != null)
            Wrap(
              spacing: 8,
              children: [
                if (exercise.category != null)
                  Chip(
                    label: Text(exercise.category!),
                    backgroundColor: theme.primary.withOpacity(0.2),
                    labelStyle: TextStyle(color: theme.primary),
                  ),
                if (exercise.muscleGroup != null)
                  Chip(
                    label: Text(exercise.muscleGroup!),
                    backgroundColor: theme.secondary.withOpacity(0.2),
                    labelStyle: TextStyle(color: theme.secondary),
                  ),
              ],
            ),
          const SizedBox(height: 24),

          // Image Carousel
          if (imageUrls.isNotEmpty)
            SizedBox(
              height: 250,
              child: GymExerciseCarousel(imageUrls: imageUrls),
            ),
          const SizedBox(height: 24),

          // Exercise Details (Big & Bold)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDetailColumn(
                  'Séries',
                  '${exercise.sets ?? exercise.exerciseSeries ?? "-"}',
                  theme,
                ),
                _buildDivider(),
                _buildDetailColumn(
                  'Reps',
                  exercise.reps ?? '${exercise.exerciseQty ?? "-"}',
                  theme,
                ),
                _buildDivider(),
                _buildDetailColumn(
                  'Peso',
                  '${exercise.weight ?? "-"} kg',
                  theme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Description
          if (exercise.description != null && exercise.description!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                exercise.description!,
                style: theme.bodyMedium.override(
                  fontFamily: 'Outfit',
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(
    String label,
    String value,
    FlutterFlowTheme theme,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: theme.headlineMedium.override(
            fontFamily: 'Outfit',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.bodySmall.override(
            fontFamily: 'Outfit',
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.white24);
  }

  void _showCompletionDialog(BuildContext context, GymFocusModel model) {
    final completed = model.exercises.where((e) => e.isCompleted).length;
    final total = model.exercises.length;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(children: [Text('🎉 '), Text('Treino Finalizado!')]),
        content: Text(
          'Você completou $completed de $total exercícios.\n\nExcelente trabalho!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }
}
