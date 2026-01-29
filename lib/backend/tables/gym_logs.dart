// Project imports:
import 'package:sentimento_app/backend/database.dart';
import 'package:sentimento_app/backend/supabase.dart';

class GymLogsTable extends SupabaseTable<GymLogsRow> {
  @override
  String get tableName => 'gym_logs';

  @override
  GymLogsRow createRow(Map<String, dynamic> data) => GymLogsRow(data);
}

class GymLogsRow extends SupabaseDataRow {
  GymLogsRow(super.data);

  @override
  SupabaseTable get table => GymLogsTable();

  int? get id => getField<int>('id');
  String get userId => getField<String>('user_id') ?? '';
  String get exerciseId => getField<String>('exercise_id') ?? '';
  String? get exerciseName => getField<String>('exercise_name');
  double? get weight => getField<double>('weight');
  int? get reps => getField<int>('reps');
  int? get series => getField<int>('series');
  String? get notes => getField<String>('notes');
  DateTime get createdAt => getField<DateTime>('created_at') ?? DateTime.now();

  // Computed field for display
  String get displayDate {
    final d = createdAt;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  }
}
