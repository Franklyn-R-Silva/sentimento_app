// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:sentimento_app/auth/supabase_auth/auth_util.dart';
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/core/model.dart';

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

  String? _avatarUrl;
  String? get avatarUrl => _avatarUrl;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

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

    // Fetch profile data from app_profiles for avatar_url
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await SupaFlow.client
          .from('app_profiles')
          .select('avatar_url, username, full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        if (data['avatar_url'] != null) {
          _avatarUrl = data['avatar_url'] as String;
        }
        if (data['username'] != null) {
          _userName = data['username'] as String;
        } else if (data['full_name'] != null) {
          _userName = data['full_name'] as String;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> uploadAvatarImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (image == null) return;

    _isUploading = true;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final fileBytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = '${user.id}/$fileName';

      // Upload to 'avatars' bucket
      await SupaFlow.client.storage
          .from('avatars')
          .uploadBinary(
            path,
            fileBytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: true,
            ),
          );

      // Get Public URL
      final publicUrl = SupaFlow.client.storage
          .from('avatars')
          .getPublicUrl(path);

      // Update app_profiles
      await SupaFlow.client
          .from('app_profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', user.id);

      _avatarUrl = publicUrl;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil atualizada!')),
        );
      }
    } catch (e) {
      debugPrint('Upload Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar imagem: $e')));
      }
    } finally {
      _isUploading = false;
      notifyListeners();
    }
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
