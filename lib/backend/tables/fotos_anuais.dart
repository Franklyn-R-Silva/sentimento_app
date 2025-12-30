import 'package:sentimento_app/backend/database.dart';
import 'package:sentimento_app/backend/supabase.dart';

class FotosAnuaisTable extends SupabaseTable<FotosAnuaisRow> {
  @override
  String get tableName => 'fotos_anuais';

  @override
  FotosAnuaisRow createRow(final Map<String, dynamic> data) =>
      FotosAnuaisRow(data);
}

class FotosAnuaisRow extends SupabaseDataRow {
  FotosAnuaisRow(super.data);

  @override
  SupabaseTable get table => FotosAnuaisTable();

  String get id => getField<String>('id')!;
  set id(final String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(final String value) => setField<String>('user_id', value);

  String get imageUrl => getField<String>('image_url')!;
  set imageUrl(final String value) => setField<String>('image_url', value);

  String? get frase => getField<String>('frase');
  set frase(final String? value) => setField<String>('frase', value);

  int? get moodLevel => getField<int>('mood_level');
  set moodLevel(final int? value) => setField<int>('mood_level', value);

  List<String> get tags => getListField<String>('tags');
  set tags(final List<String> value) => setListField<String>('tags', value);

  DateTime get dataFoto => getField<DateTime>('data_foto')!;
  set dataFoto(final DateTime value) => setField<DateTime>('data_foto', value);

  DateTime get criadoEm => getField<DateTime>('criado_em')!;
  set criadoEm(final DateTime value) => setField<DateTime>('criado_em', value);
}
