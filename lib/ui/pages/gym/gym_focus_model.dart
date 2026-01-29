import 'package:flutter/material.dart';
import 'package:sentimento_app/backend/tables/gym_exercises.dart';
import 'package:sentimento_app/backend/gym/gym_repository.dart';

class GymFocusModel extends ChangeNotifier {
  GymFocusModel({required this.exercises, this.initialIndex = 0})
    : _currentIndex = initialIndex;

  final List<GymExercisesRow> exercises;
  final int initialIndex;
  final _repository = GymRepository();

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

  Future<void> toggleComplete() async {
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
        );
      }
    } catch (e) {
      // Revert on error
      exercise.isCompleted = !newValue;
      notifyListeners();
    }
  }

  bool get isLastExercise => _currentIndex >= exercises.length - 1;
  bool get isFirstExercise => _currentIndex <= 0;

  int get completedCount => exercises.where((e) => e.isCompleted).length;
  double get progress =>
      exercises.isEmpty ? 0 : completedCount / exercises.length;
}
