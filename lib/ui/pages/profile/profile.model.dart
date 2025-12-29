import 'package:flutter/material.dart';
import 'package:sentimento_app/auth/supabase_auth/auth_util.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileModel extends FlutterFlowModel<Widget> with ChangeNotifier {
  final unfocusNode = FocusNode();

  // Password Change
  FocusNode? changePasswordFocusNode;
  TextEditingController? changePasswordController;

  FocusNode? confirmPasswordFocusNode;
  TextEditingController? confirmPasswordController;

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;
  set isPasswordVisible(bool value) {
    _isPasswordVisible = value;
    notifyListeners();
  }

  String? _userName;
  String? get userName => _userName;

  String? _userEmail;
  String? get userEmail => _userEmail;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;
  set notificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    changePasswordFocusNode?.dispose();
    changePasswordController?.dispose();
    confirmPasswordFocusNode?.dispose();
    confirmPasswordController?.dispose();
    super.dispose();
  }

  void loadUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    _userEmail = user?.email;
    _userName =
        (user?.userMetadata?['name'] as String?) ??
        user?.email?.split('@').first ??
        'Usuário';
    notifyListeners();
  }

  Future<void> signOut(BuildContext context) async {
    await authManager.signOut();
  }

  Future<void> updatePassword(BuildContext context) async {
    final password = changePasswordController?.text;
    final confirmPassword = confirmPasswordController?.text;

    if (password == null || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Digite a nova senha')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('As senhas não conferem')));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A senha deve ter pelo menos 6 caracteres'),
        ),
      );
      return;
    }

    await authManager.updatePassword(newPassword: password, context: context);

    // Clear fields on success (optional, or close dialog)
    changePasswordController?.clear();
    confirmPasswordController?.clear();
  }
}
