import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sentimento_app/auth/auth_manager.dart';
import 'package:sentimento_app/auth/supabase_auth/supabase_auth_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockAuthManager extends Mock implements AuthManager {}

class MockSupabaseAuthManager extends Mock implements SupabaseAuthManager {}

class MockUser extends Mock implements User {}

class FakeBuildContext extends Fake implements BuildContext {}

class MockBuildContext extends Mock implements BuildContext {}
