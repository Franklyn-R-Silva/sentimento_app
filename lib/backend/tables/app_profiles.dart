// Project imports:
import 'package:sentimento_app/backend/database.dart';
import 'package:sentimento_app/backend/supabase.dart';

class AppProfilesTable extends SupabaseTable<AppProfilesRow> {
  @override
  String get tableName => 'app_profiles';

  @override
  AppProfilesRow createRow(final Map<String, dynamic> data) =>
      AppProfilesRow(data);
}

class AppProfilesRow extends SupabaseDataRow {
  AppProfilesRow(super.data);

  @override
  SupabaseTable get table => AppProfilesTable();

  String get id => getField<String>('id')!;
  set id(final String value) => setField<String>('id', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(final DateTime? value) =>
      setField<DateTime>('updated_at', value);

  String? get username => getField<String>('username');
  set username(final String? value) => setField<String>('username', value);

  String? get fullName => getField<String>('full_name');
  set fullName(final String? value) => setField<String>('full_name', value);

  String? get avatarUrl => getField<String>('avatar_url');
  set avatarUrl(final String? value) => setField<String>('avatar_url', value);

  String? get website => getField<String>('website');
  set website(final String? value) => setField<String>('website', value);

  int? get matricula => getField<int>('matricula');
  set matricula(final int? value) => setField<int>('matricula', value);

  String? get tipoPermissao => getField<String>('tipo_permissao');
  set tipoPermissao(final String? value) =>
      setField<String>('tipo_permissao', value);
}
