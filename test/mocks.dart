import 'package:mocktail/mocktail.dart';
import 'package:sentimento_app/auth/auth_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockAuthManager extends Mock implements AuthManager {}

class MockUser extends Mock implements User {}
