// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:sentimento_app/auth/supabase_auth/auth_util.dart' as auth_util;
import 'package:sentimento_app/core/base_model.dart';
import 'package:sentimento_app/core/exceptions/app_exceptions.dart';

class LoginModel extends BaseModel {
  LoginModel({auth_util.SupabaseAuthManager? authManager})
    : _authManager = authManager;

  final auth_util.SupabaseAuthManager? _authManager;
  auth_util.SupabaseAuthManager get authManager =>
      _authManager ?? auth_util.authManager;

  final unfocusNode = FocusNode();

  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressController;

  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordController;

  // New fields for Create Account
  bool _isCreateAccount = false;
  bool get isCreateAccount => _isCreateAccount;
  set isCreateAccount(bool value) {
    _isCreateAccount = value;
    notifyListeners();
  }

  FocusNode? usernameFocusNode;
  TextEditingController? usernameController;

  bool _passwordVisibility = false;
  bool get passwordVisibility => _passwordVisibility;
  set passwordVisibility(bool value) {
    _passwordVisibility = value;
    notifyListeners();
  }

  // NOTE: isLoading is inherited from BaseModel as isBusy

  @override
  void initState(BuildContext context) {
    super.initState(context);
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    if (savedEmail != null && (emailAddressController?.text.isEmpty ?? true)) {
      emailAddressController?.text = savedEmail;
    }
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    emailAddressFocusNode?.dispose();
    emailAddressController?.dispose();

    passwordFocusNode?.dispose();
    passwordController?.dispose();

    usernameFocusNode?.dispose();
    usernameController?.dispose();
    super.dispose();
  }

  Future<bool> login() async {
    bool success = false;
    await runSafe(() async {
      if (emailAddressController!.text.isEmpty ||
          passwordController!.text.isEmpty) {
        throw ValidationException('Preencha todos os campos');
      }

      try {
        final user = await authManager.signInWithEmail(
          emailAddressController!.text,
          passwordController!.text,
        );

        if (user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_email', emailAddressController!.text);
          success = true;
        } else {
          throw AuthException('Erro ao realizar login');
        }
      } catch (e) {
        // Rethrow formatted exceptions or wrap generic ones
        if (e is Exception) {
          final msg = e.toString().contains('Invalid login credentials')
              ? 'Email ou senha incorretos'
              : e.toString();
          throw AuthException(msg);
        }
        rethrow;
      }
    });
    return success;
  }

  Future<bool> createAccount() async {
    bool success = false;
    await runSafe(() async {
      if (emailAddressController!.text.isEmpty ||
          passwordController!.text.isEmpty ||
          usernameController!.text.isEmpty) {
        throw ValidationException('Preencha todos os campos');
      }

      try {
        final user = await authManager.createAccountWithEmail(
          emailAddressController!.text,
          passwordController!.text,
          username: usernameController!.text,
        );

        if (user != null) {
          success = true;
        } else {
          throw AuthException('Erro ao criar conta');
        }
      } catch (e) {
        if (e.toString().contains('User already registered')) {
          throw AuthException('Email já cadastrado');
        }
        throw AuthException(e.toString());
      }
    });
    return success;
  }

  Future<bool> resetPassword() async {
    bool success = false;
    await runSafe(() async {
      if (emailAddressController!.text.isEmpty) {
        throw ValidationException('Informe seu email para recuperar a senha');
      }

      await authManager.resetPassword(
        email: emailAddressController!.text,
        context: context,
      );
      success = true;
    });
    return success;
  }
}
