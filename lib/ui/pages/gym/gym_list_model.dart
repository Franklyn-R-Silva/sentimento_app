// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:logger/logger.dart';

// Project imports:
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/backend/tables/gym_exercises.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:sentimento_app/core/util.dart';

class GymListModel extends FlutterFlowModel<Widget> with ChangeNotifier {
  final unfocusNode = FocusNode();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  List<GymExercisesRow> todaysExercises = [];

  // Progress tracking
  int get completedCount => todaysExercises.where((e) => e.isCompleted).length;
  bool get isAllComplete =>
      todaysExercises.isNotEmpty && completedCount == todaysExercises.length;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    final logger = Logger();
    logger.d('GymListModel: Starting loadData...');
    isLoading = true;

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        logger.w('GymListModel: No user ID found');
        return;
      }

      final today = DateTime.now();
      final dayOfWeek = _getDayOfWeek(today.weekday);

      final response = await GymExercisesTable().queryRows(
        queryFn: (q) => q
            .eq('user_id', userId)
            .eq('day_of_week', dayOfWeek)
            .order('order_index', ascending: true)
            .order('name', ascending: true),
      );

      todaysExercises = response;
      logger.d(
        'GymListModel: Fetched ${todaysExercises.length} exercises for $dayOfWeek',
      );

      notifyListeners();
    } catch (e) {
      logger.e('Error loading gym data: $e');
    } finally {
      isLoading = false;
    }
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Segunda';
      case DateTime.tuesday:
        return 'Terça';
      case DateTime.wednesday:
        return 'Quarta';
      case DateTime.thursday:
        return 'Quinta';
      case DateTime.friday:
        return 'Sexta';
      case DateTime.saturday:
        return 'Sábado';
      case DateTime.sunday:
        return 'Domingo';
      default:
        return 'Segunda';
    }
  }

  Future<void> resetDailyWorkout() async {
    final logger = Logger();
    try {
      isLoading = true;
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return;

      final today = DateTime.now();
      final dayOfWeek = _getDayOfWeek(today.weekday);

      // Update all exercises for today to not completed
      await GymExercisesTable().update(
        data: {'is_completed': false},
        matchingRows: (t) =>
            t.eq('user_id', userId).eq('day_of_week', dayOfWeek),
      );

      // Refresh local data
      await loadData();

      logger.i('Daily workout reset successfully');
    } catch (e) {
      logger.e('Error resetting workout: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> reorderExercises(int oldIndex, int newIndex) async {
    final logger = Logger();

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = todaysExercises.removeAt(oldIndex);
    todaysExercises.insert(newIndex, item);
    notifyListeners();

    // Persist to DB using parallel updates for better performance
    try {
      final updateFutures = <Future<void>>[];
      for (int i = 0; i < todaysExercises.length; i++) {
        final exercise = todaysExercises[i];
        exercise.orderIndex = i;
        updateFutures.add(
          GymExercisesTable().update(
            data: {'order_index': i},
            matchingRows: (t) => t.eq('id', exercise.id),
          ),
        );
      }
      await Future.wait(updateFutures);
      logger.d('Exercise order updated successfully');
    } catch (e) {
      logger.e('Error updating order: $e');
      // Reload data on error to restore correct state
      await loadData();
    }
  }
}
