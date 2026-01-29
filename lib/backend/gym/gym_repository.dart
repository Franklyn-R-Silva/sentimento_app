import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentimento_app/backend/tables/gym_exercises.dart';
import 'package:sentimento_app/backend/tables/gym_logs.dart';

class GymRepository {
  final _table = GymExercisesTable();
  final _logsTable = GymLogsTable();

  // Singleton pattern
  static final GymRepository _instance = GymRepository._internal();
  factory GymRepository() => _instance;
  GymRepository._internal();

  /// Fetches all exercises ordered by day and index
  Future<List<GymExercisesRow>> getAllExercises() async {
    return await _table.queryRows(
      queryFn: (q) => q.order('order_index', ascending: true),
    );
  }

  /// Fetches exercises for a specific day
  Future<List<GymExercisesRow>> getExercisesByDay(String day) async {
    return await _table.queryRows(
      queryFn: (q) =>
          q.eq('day_of_week', day).order('order_index', ascending: true),
    );
  }

  /// Updates a specific field for an exercise
  Future<void> updateField(String id, String field, dynamic value) async {
    await _table.update(
      data: {field: value},
      matchingRows: (t) => t.eq('id', id),
    );
  }

  /// Deletes an exercise
  Future<void> deleteExercise(String id) async {
    await _table.delete(matchingRows: (t) => t.eq('id', id));
  }

  /// Moves an exercise to a new day
  Future<void> moveExercise(String id, String targetDay) async {
    await updateField(id, 'day_of_week', targetDay);
  }

  /// Reorders exercises within a day
  Future<void> reorderExercises(List<GymExercisesRow> exercises) async {
    for (int i = 0; i < exercises.length; i++) {
      await _table.update(
        data: {'order_index': i},
        matchingRows: (t) => t.eq('id', exercises[i].id),
      );
    }
  }

  /// Shifts all exercises from startDay forward
  Future<void> shiftSchedule(String startDay) async {
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

    // First, collect all exercises that need to be shifted
    final exercisesToShift = <String, String>{}; // id -> new day

    for (int i = days.length - 1; i >= startIndex; i--) {
      final currentDay = days[i];
      final nextDayIndex = (i + 1) % days.length;
      final nextDay = days[nextDayIndex];

      final exercises = await getExercisesByDay(currentDay);
      for (final exercise in exercises) {
        exercisesToShift[exercise.id] = nextDay;
      }
    }

    // Then, apply all updates (prevents recursive overwrite)
    for (final entry in exercisesToShift.entries) {
      await _table.update(
        data: {'day_of_week': entry.value},
        matchingRows: (t) => t.eq('id', entry.key),
      );
    }
  }

  // =============== LOGS (History) ===============

  /// Logs a workout entry
  Future<void> logWorkout({
    required String exerciseId,
    required String exerciseName,
    double? weight,
    int? reps,
    int? series,
    String? notes,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    await _logsTable.insert({
      'user_id': userId ?? '',
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'weight': weight,
      'reps': reps,
      'series': series,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Gets workout history for an exercise
  Future<List<GymLogsRow>> getExerciseHistory(
    String exerciseId, {
    int limit = 10,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    return await _logsTable.queryRows(
      queryFn: (q) => q
          .eq('user_id', userId ?? '')
          .eq('exercise_id', exerciseId)
          .order('created_at', ascending: false)
          .limit(limit),
    );
  }

  /// Gets all workout logs for a date range
  Future<List<GymLogsRow>> getLogsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    return await _logsTable.queryRows(
      queryFn: (q) => q
          .eq('user_id', userId ?? '')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String())
          .order('created_at', ascending: false),
    );
  }

  /// Gets stats for the current week
  Future<Map<String, dynamic>> getWeeklyStats() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final logs = await getLogsByDateRange(weekStart, now);

    double totalWeight = 0;
    int totalSets = 0;
    Set<String> daysWorked = {};

    for (final log in logs) {
      totalWeight += (log.weight ?? 0) * (log.reps ?? 0) * (log.series ?? 1);
      totalSets += log.series ?? 1;
      daysWorked.add(log.displayDate);
    }

    return {
      'totalVolume': totalWeight,
      'totalSets': totalSets,
      'daysWorked': daysWorked.length,
      'logsCount': logs.length,
    };
  }
}
