import 'package:flutter/material.dart';
import 'package:sentimento_app/auth/supabase_auth/auth_util.dart';
import 'package:sentimento_app/core/model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileModel extends FlutterFlowModel<Widget> with ChangeNotifier {
  final unfocusNode = FocusNode();

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
}
