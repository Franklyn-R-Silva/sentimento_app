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
      // Determine new index? Usually append to end, so order_index can be max+1 or null (default sorting).
      // Ideally we fetch max order for target day, but for now let's just update day.
      await loadData(); // Reload to reflect changes
    } catch (e) {
      Logger().e('Error moving exercise: $e');
      rethrow;
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
      // Iterate backwards from the last day down to the start day
      // to avoid overwriting data we just moved.
      // Example: Shift 'Quarta' (Index 2).
      // 1. Move 'Domingo' (6) -> 'Segunda' (0) (Wrap)
      // 2. Move 'Sábado' (5) -> 'Domingo' (6)
      // ...
      // 3. Move 'Quarta' (2) -> 'Quinta' (3)

      for (int i = days.length - 1; i >= startIndex; i--) {
        final currentDay = days[i];
        final nextDayIndex = (i + 1) % days.length; // Wrap around to Monday
        final nextDay = days[nextDayIndex];

        // We need to verify if there are exercises to move to avoid unnecessary queries,
        // but a blind update is also fine if efficient.
        // However, Supabase update is precise.

        await GymExercisesTable().update(
          data: {'day_of_week': nextDay},
          matchingRows: (t) => t.eq('day_of_week', currentDay),
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

    // Persist to DB
    try {
      // Update order_index for all items in this day
      // Currently simple approach: update all. Can be optimized.
      for (int i = 0; i < exercises.length; i++) {
        final exercise = exercises[i];
        exercise.orderIndex = i;
        await GymExercisesTable().update(
          data: {'order_index': i},
          matchingRows: (t) => t.eq('id', exercise.id),
        );
      }
    } catch (e) {
      Logger().e('Error updating order: $e');
    }
  }
}
