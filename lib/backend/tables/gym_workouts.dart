// Project imports:
import 'package:sentimento_app/backend/database.dart';
import 'package:sentimento_app/backend/supabase.dart';

class GymWorkoutsTable extends SupabaseTable<GymWorkoutsRow> {
  @override
  String get tableName => 'gym_workouts';

  @override
  GymWorkoutsRow createRow(final Map<String, dynamic> data) =>
      GymWorkoutsRow(data);
}

class GymWorkoutsRow extends SupabaseDataRow {
  GymWorkoutsRow(super.data);

  @override
  SupabaseTable get table => GymWorkoutsTable();

  String get id => getField<String>('id')!;
  set id(final String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(final DateTime value) =>
      setField<DateTime>('created_at', value);

  String get userId => getField<String>('user_id')!;
  set userId(final String value) => setField<String>('user_id', value);

  String get name => getField<String>('name')!;
  set name(final String value) => setField<String>('name', value);

  String? get muscleGroups => getField<String>('muscle_group');
  set muscleGroups(final String? value) =>
      setField<String>('muscle_group', value);

  String? get description => getField<String>('description');
  set description(final String? value) =>
      setField<String>('description', value);

  String? get dayOfWeek => getField<String>('day_of_week');
  set dayOfWeek(final String? value) => setField<String>('day_of_week', value);

  int? get orderIndex => getField<int>('order_index');
  set orderIndex(final int? value) => setField<int>('order_index', value);
}
