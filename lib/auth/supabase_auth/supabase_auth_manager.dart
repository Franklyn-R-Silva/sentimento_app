// ignore_for_file: strict_raw_type

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:logger/logger.dart';

// Project imports:
import 'package:sentimento_app/auth/auth_manager.dart';
import 'package:sentimento_app/auth/supabase_auth/auth_util.dart';
import 'package:sentimento_app/auth/supabase_auth/email_auth.dart';
import 'package:sentimento_app/auth/supabase_auth/supabase_user_provider.dart';
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/core/nav/nav.dart';

// Project imports:

export '/auth/base_auth_user_provider.dart';

class SupabaseAuthManager extends AuthManager with EmailSignInManager {
  final logger = Logger();
  @override
  Future signOut() {
    clearUserProfile();
    return SupaFlow.client.auth.signOut();
  }

  @override
  Future deleteUser(final BuildContext context) async {
    try {
      if (!loggedIn) {
        logger.e('Error: delete user attempted with no logged in user!');
        return;
      }
      await currentUser?.delete();
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      }
    }
  }

  @override
  Future updateEmail({
    required final String email,
    required final BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        logger.e('Error: update email attempted with no logged in user!');
        return;
      }
      await currentUser?.updateEmail(email);
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      }
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email change confirmation email sent')),
      );
    }
  }

  @override
  Future updatePassword({
    required final String newPassword,
    required final BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        logger.e('Error: update password attempted with no logged in user!');
        return;
      }
      await currentUser?.updatePassword(newPassword);
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      }
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
    }
  }

  @override
  Future resetPassword({
    required final String email,
    required final BuildContext context,
    final String? redirectTo,
  }) async {
    try {
      await SupaFlow.client.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      }
      return null;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    }
  }

  @override
  Future<BaseAuthUser?> signInWithEmail(
    final String email,
    final String password,
  ) => _signInOrCreateAccount(() => emailSignInFunc(email, password));

  @override
  Future<BaseAuthUser?> createAccountWithEmail(
    final String email,
    final String password, {
    final String? username,
  }) async {
    try {
      if (username != null) {
        final exists = await checkUsernameExists(username);
        if (exists) {
          throw const AuthException('Login já existe');
        }
      }

      return _signInOrCreateAccount(
        () => emailCreateAccountFunc(
          email,
          password,
          data: username != null ? {'username': username} : null,
        ),
      );
    } catch (e) {
      if (e is AuthException) rethrow; // Rethrow known auth errors
      logger.e('Erro ao criar conta: $e');
      throw AuthException(e.toString()); // Wrap unknown errors
    }
  }

  Future<bool> checkUsernameExists(String username) async {
    try {
      final res = await SupaFlow.client
          .from('app_profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();
      return res != null;
    } catch (e) {
      logger.e('Erro ao verificar username: $e');
      return false; // Fail safe
    }
  }

  /// Tries to sign in or create an account using Supabase Auth.
  /// Returns the User object if sign in was successful.
  Future<BaseAuthUser?> _signInOrCreateAccount(
    final Future<User?> Function() signInFunc,
  ) async {
    try {
      logger.i('Tentando realizar login/criação de conta...');
      final user = await signInFunc();
      final authUser = user == null ? null : SentimentoAppSupabaseUser(user);

      if (authUser != null) {
        logger.i('Login realizado com sucesso! User UID: ${authUser.uid}');
        currentUser = authUser;
        AppStateNotifier.instance.update(authUser);
      } else {
        logger.w('Login retornado usuário nulo ou pendente de confirmação.');
      }
      return authUser;
    } on AuthException catch (e) {
      logger.e('Erro de Autenticação Supabase: ${e.message}');
      final errorMsg = e.message.contains('User already registered')
          ? 'Email já cadastrado'
          : e.message;
      throw AuthException(errorMsg);
    } catch (e) {
      logger.e('Erro desconhecido no login: $e');
      throw AuthException(e.toString());
    }
  }
}
