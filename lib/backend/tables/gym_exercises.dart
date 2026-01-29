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

  String? get machinePhotoUrl => getField<String>('machine_photo_url');
  set machinePhotoUrl(final String? value) =>
      setField<String>('machine_photo_url', value);

  String? get dayOfWeek => getField<String>('day_of_week');
  set dayOfWeek(final String? value) => setField<String>('day_of_week', value);
}
