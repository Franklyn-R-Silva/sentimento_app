// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:sentimento_app/auth/supabase_auth/auth_util.dart' as auth_util;
import 'package:sentimento_app/core/model.dart';

// Project imports:


class LoginModel extends FlutterFlowModel<Widget> with ChangeNotifier {
  LoginModel({auth_util.SupabaseAuthManager? authManager})
    : _authManager = authManager;

  final auth_util.SupabaseAuthManager? _authManager;
  auth_util.SupabaseAuthManager get authManager =>
      _authManager ?? auth_util.authManager;

  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressController;
  String? Function(BuildContext, String?)? emailAddressControllerValidator;
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
  String? Function(BuildContext, String?)? usernameControllerValidator;

  bool _passwordVisibility = false;
  bool get passwordVisibility => _passwordVisibility;
  set passwordVisibility(bool value) {
    _passwordVisibility = value;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String? Function(BuildContext, String?)? passwordControllerValidator;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
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

  /// Action blocks are added here.
  Future<String?> login() async {
    if (emailAddressController!.text.isEmpty ||
        passwordController!.text.isEmpty) {
      return 'Preencha todos os campos';
    }

    isLoading = true;
    try {
      final user = await authManager.signInWithEmail(
        emailAddressController!.text,
        passwordController!.text,
      );

      if (user != null) {
        // Save email on success
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', emailAddressController!.text);
        return null;
      } else {
        return 'Erro ao realizar login';
      }
    } on Exception catch (e) {
      // Clean up error message if it's an AuthException
      return e.toString().replaceAll('AuthException: ', '');
    } catch (e) {
      return 'Erro inesperado: $e';
    } finally {
      isLoading = false;
    }
  }

  Future<String?> createAccount() async {
    if (emailAddressController!.text.isEmpty ||
        passwordController!.text.isEmpty ||
        usernameController!.text.isEmpty) {
      return 'Preencha todos os campos';
    }

    isLoading = true;
    try {
      final user = await authManager.createAccountWithEmail(
        emailAddressController!.text,
        passwordController!.text,
        username: usernameController!.text,
      );
      // Successful creation (some flows return user, others might be async verfication)
      return user != null ? null : 'Erro ao criar conta';
    } on Exception catch (e) {
      return e.toString().replaceAll('AuthException: ', '');
    } catch (e) {
      return 'Erro inesperado: $e';
    } finally {
      isLoading = false;
    }
  }
}
