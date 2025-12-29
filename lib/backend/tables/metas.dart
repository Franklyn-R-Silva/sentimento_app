import 'package:sentimento_app/backend/database.dart';
import 'package:sentimento_app/backend/supabase.dart';

class MetasTable extends SupabaseTable<MetasRow> {
  @override
  String get tableName => 'metas';

  @override
  MetasRow createRow(final Map<String, dynamic> data) => MetasRow(data);
}

class MetasRow extends SupabaseDataRow {
  MetasRow(super.data);

  @override
  SupabaseTable get table => MetasTable();

  String get id => getField<String>('id')!;
  set id(final String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(final String value) => setField<String>('user_id', value);

  String get titulo => getField<String>('titulo')!;
  set titulo(final String value) => setField<String>('titulo', value);

  String? get descricao => getField<String>('descricao');
  set descricao(final String? value) => setField<String>('descricao', value);

  String get categoria => getField<String>('categoria') ?? 'geral';
  set categoria(final String value) => setField<String>('categoria', value);

  String get tipo => getField<String>('tipo') ?? 'streak';
  set tipo(final String value) => setField<String>('tipo', value);

  int get metaValor => getField<int>('meta_valor') ?? 1;
  set metaValor(final int value) => setField<int>('meta_valor', value);

  int get valorAtual => getField<int>('valor_atual') ?? 0;
  set valorAtual(final int value) => setField<int>('valor_atual', value);

  String get icone => getField<String>('icone') ?? '🎯';
  set icone(final String value) => setField<String>('icone', value);

  String get cor => getField<String>('cor') ?? '#7C4DFF';
  set cor(final String value) => setField<String>('cor', value);

  String get frequencia => getField<String>('frequencia') ?? 'diaria';
  set frequencia(final String value) => setField<String>('frequencia', value);

  bool get ativo => getField<bool>('ativo') ?? true;
  set ativo(final bool value) => setField<bool>('ativo', value);

  bool get concluido => getField<bool>('concluido') ?? false;
  set concluido(final bool value) => setField<bool>('concluido', value);

  DateTime? get dataInicio => getField<DateTime>('data_inicio');
  set dataInicio(final DateTime? value) =>
      setField<DateTime>('data_inicio', value);

  DateTime? get dataFim => getField<DateTime>('data_fim');
  set dataFim(final DateTime? value) => setField<DateTime>('data_fim', value);

  DateTime get criadoEm => getField<DateTime>('criado_em')!;
  set criadoEm(final DateTime value) => setField<DateTime>('criado_em', value);

  // Helper para calcular progresso
  double get progresso =>
      metaValor > 0 ? (valorAtual / metaValor).clamp(0.0, 1.0) : 0.0;
}
