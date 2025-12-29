// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

export './database.dart';

String _kSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
String _kSupabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() => Supabase.initialize(
    url: _kSupabaseUrl,
    headers: {'X-Client-Info': 'flutterflow'},
    anonKey: _kSupabaseAnonKey,
    debug: false,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );
}
