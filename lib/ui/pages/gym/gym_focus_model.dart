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
    loadWorkouts();
  }

  final List<GymExercisesRow> exercises;
  final int initialIndex;
  final _repository = GymRepository();
  List<GymWorkoutsRow> workouts = [];

  int _currentIndex;
  int get currentIndex => _currentIndex;

  GymExercisesRow get currentExercise => exercises[_currentIndex];

  void goToIndex(int index) {
    if (index >= 0 && index < exercises.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

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

  bool get isLastExercise => _currentIndex >= exercises.length - 1;
  bool get isFirstExercise => _currentIndex <= 0;

  int get completedCount => exercises.where((e) => e.isCompleted).length;
  double get progress =>
      exercises.isEmpty ? 0 : completedCount / exercises.length;
}
