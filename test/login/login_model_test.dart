// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:sentimento_app/auth/supabase_auth/supabase_user_provider.dart';
import 'package:sentimento_app/ui/pages/login/login.model.dart';
import '../mocks/mocks.dart';

void main() {
  late LoginModel model;
  late MockSupabaseAuthManager mockAuthManager;

  setUpAll(() {
    registerFallbackValue(const Text(''));
    registerFallbackValue(const SnackBar(content: Text('')));
    registerFallbackValue(FakeBuildContext());
  });

  setUp(() {
    mockAuthManager = MockSupabaseAuthManager();
    model = LoginModel(authManager: mockAuthManager);
    model.emailAddressController = TextEditingController();
    model.passwordController = TextEditingController();
    model.usernameController = TextEditingController();
  });

  group('LoginModel Tests', () {
    test('login should return null (success) when successful', () async {
      when(
        () => mockAuthManager.signInWithEmail(any(), any()),
      ).thenAnswer((_) async => SentimentoAppSupabaseUser(MockUser()));

      model.emailAddressController!.text = 'test@test.com';
      model.passwordController!.text = 'password';

      final result = await model.login();
      expect(result, isNull);
    });

    test('isLoading should be toggled during login', () async {
      when(() => mockAuthManager.signInWithEmail(any(), any())).thenAnswer((
        _,
      ) async {
        expect(model.isBusy, true);
        return null;
      });

      model.emailAddressController!.text = 'test@test.com';
      model.passwordController!.text = 'password';

      await model.login();
      expect(model.isBusy, false);
    });
  });
}
