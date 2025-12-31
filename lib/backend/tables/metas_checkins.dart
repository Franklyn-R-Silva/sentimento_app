// Project imports:
import 'package:sentimento_app/backend/database.dart';
import 'package:sentimento_app/backend/supabase.dart';

class MetasCheckinsTable extends SupabaseTable<MetasCheckinRow> {
  @override
  String get tableName => 'metas_checkins';

  @override
  MetasCheckinRow createRow(final Map<String, dynamic> data) =>
      MetasCheckinRow(data);
}

class MetasCheckinRow extends SupabaseDataRow {
  MetasCheckinRow(super.data);

  @override
  SupabaseTable get table => MetasCheckinsTable();

  String get id => getField<String>('id')!;
  set id(final String value) => setField<String>('id', value);

  String get metaId => getField<String>('meta_id')!;
  set metaId(final String value) => setField<String>('meta_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(final String value) => setField<String>('user_id', value);

  DateTime get dataCheckin => getField<DateTime>('data_checkin')!;
  set dataCheckin(final DateTime value) =>
      setField<DateTime>('data_checkin', value);

  DateTime get criadoEm => getField<DateTime>('criado_em')!;
  set criadoEm(final DateTime value) => setField<DateTime>('criado_em', value);
}
