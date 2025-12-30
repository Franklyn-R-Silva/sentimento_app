import 'package:flutter/material.dart';
import 'package:sentimento_app/auth/supabase_auth/auth_util.dart' as auth_util;
import 'package:sentimento_app/core/model.dart';

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
  void initState(BuildContext context) {}

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
  Future<bool> login(BuildContext context) async {
    if (emailAddressController!.text.isEmpty ||
        passwordController!.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return false;
    }

    isLoading = true;
    try {
      final user = await authManager.signInWithEmail(
        context,
        emailAddressController!.text,
        passwordController!.text,
      );
      return user != null;
    } finally {
      isLoading = false;
    }
  }

  Future<bool> createAccount(BuildContext context) async {
    if (emailAddressController!.text.isEmpty ||
        passwordController!.text.isEmpty ||
        usernameController!.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return false;
    }

    isLoading = true;
    try {
      final user = await authManager.createAccountWithEmail(
        context,
        emailAddressController!.text,
        passwordController!.text,
        username: usernameController!.text,
      );
      return user != null;
    } finally {
      isLoading = false;
    }
  }
}
