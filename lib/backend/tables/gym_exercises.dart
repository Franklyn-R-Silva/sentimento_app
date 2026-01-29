// Project imports:
import 'package:sentimento_app/backend/database.dart';
import 'package:sentimento_app/backend/supabase.dart';

class GymExercisesTable extends SupabaseTable<GymExercisesRow> {
  @override
  String get tableName => 'gym_exercises';

  @override
  GymExercisesRow createRow(final Map<String, dynamic> data) =>
      GymExercisesRow(data);
}

class GymExercisesRow extends SupabaseDataRow {
  GymExercisesRow(super.data);

  @override
  SupabaseTable get table => GymExercisesTable();

  String get id => getField<String>('id')!;
  set id(final String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(final DateTime value) =>
      setField<DateTime>('created_at', value);

  String get userId => getField<String>('user_id')!;
  set userId(final String value) => setField<String>('user_id', value);

  String get name => getField<String>('name')!;
  set name(final String value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(final String? value) =>
      setField<String>('description', value);

  int? get stretchingSeries => getField<int>('stretching_series');
  set stretchingSeries(final int? value) =>
      setField<int>('stretching_series', value);

  int? get stretchingQty => getField<int>('stretching_qty');
  set stretchingQty(final int? value) => setField<int>('stretching_qty', value);

  int? get exerciseSeries => getField<int>('exercise_series');
  set exerciseSeries(final int? value) =>
      setField<int>('exercise_series', value);

  int? get exerciseQty => getField<int>('exercise_qty');
  set exerciseQty(final int? value) => setField<int>('exercise_qty', value);

  String? get exerciseTime => getField<String>('exercise_time');
  set exerciseTime(final String? value) =>
      setField<String>('exercise_time', value);

  String? get stretchingName => getField<String>('stretching_name');
  set stretchingName(final String? value) =>
      setField<String>('stretching_name', value);

  String? get stretchingTime => getField<String>('stretching_time');
  set stretchingTime(final String? value) =>
      setField<String>('stretching_time', value);

  String? get machinePhotoUrl => getField<String>('machine_photo_url');
  set machinePhotoUrl(final String? value) =>
      setField<String>('machine_photo_url', value);

  String? get stretchingPhotoUrl => getField<String>('stretching_photo_url');
  set stretchingPhotoUrl(final String? value) =>
      setField<String>('stretching_photo_url', value);

  String? get dayOfWeek => getField<String>('day_of_week');
  set dayOfWeek(final String? value) => setField<String>('day_of_week', value);

  // New Fields
  String? get category => getField<String>('category');
  set category(final String? value) => setField<String>('category', value);

  String? get muscleGroup => getField<String>('muscle_group');
  set muscleGroup(final String? value) =>
      setField<String>('muscle_group', value);

  int? get sets => getField<int>('sets');
  set sets(final int? value) => setField<int>('sets', value);

  String? get reps => getField<String>('reps');
  set reps(final String? value) => setField<String>('reps', value);

  double? get weight => getField<double>('weight');
  set weight(final double? value) => setField<double>('weight', value);

  int? get restTime => getField<int>('rest_time');
  set restTime(final int? value) => setField<int>('rest_time', value);

  bool get isCompleted => getField<bool>('is_completed') ?? false;
  set isCompleted(final bool value) => setField<bool>('is_completed', value);

  int? get orderIndex => getField<int>('order_index');
  set orderIndex(final int? value) => setField<int>('order_index', value);
}
