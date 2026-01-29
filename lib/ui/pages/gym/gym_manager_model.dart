// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:logger/logger.dart';

// Project imports:
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/backend/tables/gym_exercises.dart';
import 'package:sentimento_app/core/model.dart';

class GymManagerModel extends FlutterFlowModel<Widget> with ChangeNotifier {
  final unfocusNode = FocusNode();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Selection mode
  bool _isSelectionMode = false;
  bool get isSelectionMode => _isSelectionMode;

  final Set<String> _selectedExerciseIds = {};
  Set<String> get selectedExerciseIds => _selectedExerciseIds;

  int get selectedCount => _selectedExerciseIds.length;

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedExerciseIds.clear();
    }
    notifyListeners();
  }

  void toggleExerciseSelection(String exerciseId) {
    if (_selectedExerciseIds.contains(exerciseId)) {
      _selectedExerciseIds.remove(exerciseId);
    } else {
      _selectedExerciseIds.add(exerciseId);
    }
    notifyListeners();
  }

  bool isExerciseSelected(String exerciseId) =>
      _selectedExerciseIds.contains(exerciseId);

  void clearSelection() {
    _selectedExerciseIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  void selectAll(String day) {
    final exercises = exercisesByDay[day] ?? [];
    for (var e in exercises) {
      _selectedExerciseIds.add(e.id);
    }
    notifyListeners();
  }

  // Map to hold exercises grouped by day
  Map<String, List<GymExercisesRow>> exercisesByDay = {
    'Segunda': [],
    'Terça': [],
    'Quarta': [],
    'Quinta': [],
    'Sexta': [],
    'Sábado': [],
    'Domingo': [],
  };

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    final logger = Logger();
    isLoading = true;

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        logger.w('GymManagerModel: No user ID found');
        return;
      }

      final response = await GymExercisesTable().queryRows(
        queryFn: (q) => q
            .eq('user_id', userId)
            .order('order_index', ascending: true)
            .order('name', ascending: true),
      );

      // Clear existing data
      for (var day in exercisesByDay.keys) {
        exercisesByDay[day] = [];
      }

      // Group by day
      for (var exercise in response) {
        if (exercise.dayOfWeek != null &&
            exercisesByDay.containsKey(exercise.dayOfWeek)) {
          exercisesByDay[exercise.dayOfWeek]!.add(exercise);
        } else {
          // Handle cases where day might be null or invalid (optional)
          // For now, we ignore or put in 'Outros' if we had one
        }
      }

      notifyListeners();
    } catch (e) {
      logger.e('Error loading gym manager data: $e');
    } finally {
      isLoading = false;
    }
  } // loadData

  Future<void> moveExercise(GymExercisesRow exercise, String targetDay) async {
    try {
      await GymExercisesTable().update(
        data: {'day_of_week': targetDay},
        matchingRows: (t) => t.eq('id', exercise.id),
      );
      await loadData();
    } catch (e) {
      Logger().e('Error moving exercise: $e');
      rethrow;
    }
  }

  /// Move ALL exercises from sourceDay to targetDay
  Future<void> moveAllExercises(String sourceDay, String targetDay) async {
    if (sourceDay == targetDay) return;

    final exercises = exercisesByDay[sourceDay] ?? [];
    if (exercises.isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      final updateFutures = <Future<void>>[];
      for (var exercise in exercises) {
        updateFutures.add(
          GymExercisesTable().update(
            data: {'day_of_week': targetDay},
            matchingRows: (t) => t.eq('id', exercise.id),
          ),
        );
      }
      await Future.wait(updateFutures);
      await loadData();
    } catch (e) {
      Logger().e('Error moving all exercises: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Move only SELECTED exercises to targetDay
  Future<void> moveSelectedExercises(String targetDay) async {
    if (_selectedExerciseIds.isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      final updateFutures = <Future<void>>[];
      for (var exerciseId in _selectedExerciseIds) {
        updateFutures.add(
          GymExercisesTable().update(
            data: {'day_of_week': targetDay},
            matchingRows: (t) => t.eq('id', exerciseId),
          ),
        );
      }
      await Future.wait(updateFutures);
      clearSelection();
      await loadData();
    } catch (e) {
      Logger().e('Error moving selected exercises: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> shiftDay(String startDay) async {
    final days = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];

    final startIndex = days.indexOf(startDay);
    if (startIndex == -1) return;

    isLoading = true;
    notifyListeners();

    try {
      // First, collect ALL exercises from startDay to Sunday with their target days
      // We need to collect by ID to avoid the recursive overwrite problem
      final Map<String, String> exerciseUpdates = {}; // exerciseId -> targetDay

      for (int i = days.length - 1; i >= startIndex; i--) {
        final currentDay = days[i];
        final nextDayIndex = (i + 1) % days.length;
        final nextDay = days[nextDayIndex];

        // Get exercises for current day from our local state
        final exercisesForDay = exercisesByDay[currentDay] ?? [];
        for (var exercise in exercisesForDay) {
          exerciseUpdates[exercise.id] = nextDay;
        }
      }

      // Now apply all updates at once (by individual ID)
      for (var entry in exerciseUpdates.entries) {
        await GymExercisesTable().update(
          data: {'day_of_week': entry.value},
          matchingRows: (t) => t.eq('id', entry.key),
        );
      }

      await loadData();
    } catch (e) {
      Logger().e('Error shifting day: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reorderExercises(String day, int oldIndex, int newIndex) async {
    final exercises = exercisesByDay[day];
    if (exercises == null) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, item);
    notifyListeners();

    // Persist to DB using parallel updates for better performance
    try {
      final updateFutures = <Future<void>>[];
      for (int i = 0; i < exercises.length; i++) {
        final exercise = exercises[i];
        exercise.orderIndex = i;
        updateFutures.add(
          GymExercisesTable().update(
            data: {'order_index': i},
            matchingRows: (t) => t.eq('id', exercise.id),
          ),
        );
      }
      await Future.wait(updateFutures);
    } catch (e) {
      Logger().e('Error updating order: $e');
    }
  }
}
