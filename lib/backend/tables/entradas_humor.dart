import 'package:sentimento_app/backend/database.dart';
import 'package:sentimento_app/backend/supabase.dart';

class EntradasHumorTable extends SupabaseTable<EntradasHumorRow> {
  @override
  String get tableName => 'entradas_humor';

  @override
  EntradasHumorRow createRow(final Map<String, dynamic> data) =>
      EntradasHumorRow(data);
}

class EntradasHumorRow extends SupabaseDataRow {
  EntradasHumorRow(super.data);

  @override
  SupabaseTable get table => EntradasHumorTable();

  String get id => getField<String>('id')!;
  set id(final String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(final String value) => setField<String>('user_id', value);

  int get nota => getField<int>('nota')!;
  set nota(final int value) => setField<int>('nota', value);

  String? get notaTexto => getField<String>('nota_texto');
  set notaTexto(final String? value) => setField<String>('nota_texto', value);

  List<String> get tags => getListField<String>('tags');
  set tags(final List<String> value) => setListField<String>('tags', value);

  DateTime get criadoEm => getField<DateTime>('created_at')!;
  set criadoEm(final DateTime value) => setField<DateTime>('created_at', value);
}
