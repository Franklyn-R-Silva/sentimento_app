// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:logger/logger.dart';

// Project imports:
import 'package:sentimento_app/backend/gym/gym_repository.dart';
import 'package:sentimento_app/backend/supabase.dart';

class GymFocusModel extends ChangeNotifier {
  GymFocusModel({required this.exercises, this.initialIndex = 0})
    : _currentIndex = initialIndex {
    _initCurrentExercise();
    loadWorkouts();
  }

  final List<GymExercisesRow> exercises;
  final int initialIndex;
  final _repository = GymRepository();
  List<GymWorkoutsRow> workouts = [];

  int _currentIndex;
  int get currentIndex => _currentIndex;

  GymExercisesRow get currentExercise => exercises[_currentIndex];

  void next() {
    if (_currentIndex < exercises.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previous() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  Future<void> loadWorkouts() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      workouts = await GymWorkoutsTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId),
      );
      notifyListeners();
    } catch (e) {
      Logger().e('Error loading workouts in focus mode: $e');
    }
  }

  Future<void> toggleComplete() async {
    final logger = Logger();
    final exercise = currentExercise;
    final newValue = !exercise.isCompleted;
    exercise.isCompleted = newValue;
    notifyListeners();

    try {
      await _repository.updateField(exercise.id, 'is_completed', newValue);

      // Log workout if completing
      if (newValue) {
        await _repository.logWorkout(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          weight: exercise.weight,
          reps: int.tryParse(exercise.reps ?? ''),
          series: exercise.sets ?? exercise.exerciseSeries,
          elevation: exercise.elevation,
          speed: exercise.speed,
        );
      }
    } catch (e) {
      // Revert on error
      exercise.isCompleted = !newValue;
      notifyListeners();
      logger.e('Error toggling exercise status: $e');
      rethrow;
    }
  }

  // Smart Focus Mode Features
  int currentSet = 1;
  int totalSets = 3; // Default, will be updated from exercise
  final TextEditingController weightController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  bool isResting = false;

  void _initCurrentExercise() {
    final exercise = currentExercise;
    currentSet = 1;
    totalSets = exercise.sets ?? exercise.exerciseSeries ?? 3;
    isResting = false;

    // Attempt to pre-fill from history
    _loadHistoryAndPrefill();
  }

  Future<void> _loadHistoryAndPrefill() async {
    try {
      final history = await _repository.getExerciseHistory(
        currentExercise.id,
        limit: 1,
      );
      if (history.isNotEmpty) {
        final lastLog = history.first;
        weightController.text =
            lastLog.weight?.toString() ??
            currentExercise.weight?.toString() ??
            '';
        repsController.text =
            lastLog.reps?.toString() ?? currentExercise.reps ?? '';
      } else {
        weightController.text = currentExercise.weight?.toString() ?? '';
        repsController.text = currentExercise.reps ?? '';
      }
      notifyListeners();
    } catch (e) {
      Logger().e('Error loading history for pre-fill: $e');
    }
  }

  void updateSetData(String weight, String reps) {
    // Optional: Validate or auto-save locally
    notifyListeners();
  }

  Future<void> finishSet() async {
    if (isResting) return;

    // Log the set (optional: detailed logging per set can be added later,
    // for now we log when the whole exercise is done or just track progress)

    if (currentSet < totalSets) {
      isResting = true;
      notifyListeners();
      // The UI will trigger the rest timer
    } else {
      // Exercise Completed
      await toggleComplete();
      // Move to next exercise if auto-advance is desired, or just show completed state
    }
  }

  void finishRest() {
    isResting = false;
    if (currentSet < totalSets) {
      currentSet++;
    }
    notifyListeners();
  }

  void goToIndex(int index) {
    if (index >= 0 && index < exercises.length) {
      _currentIndex = index;
      _initCurrentExercise();
      notifyListeners();
    }
  }

  void resetExercise() {
    currentSet = 1;
    isResting = false;
    currentExercise.isCompleted = false;
    notifyListeners();
  }

  // existing code...

  bool get isLastExercise => _currentIndex >= exercises.length - 1;
  bool get isFirstExercise => _currentIndex <= 0;

  int get completedCount => exercises.where((e) => e.isCompleted).length;
  double get progress =>
      exercises.isEmpty ? 0 : completedCount / exercises.length;

  @override
  void dispose() {
    weightController.dispose();
    repsController.dispose();
    super.dispose();
  }
}
