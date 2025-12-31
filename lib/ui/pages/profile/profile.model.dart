// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:sentimento_app/auth/supabase_auth/auth_util.dart';
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/core/base_model.dart';
import 'package:sentimento_app/core/exceptions/app_exceptions.dart' as app_ex;
import 'package:sentimento_app/services/toast_service.dart';

class ProfileModel extends BaseModel {
  final SupabaseClient? supabaseClient;
  final ImagePicker? imagePicker;
  ProfileModel({this.supabaseClient, this.imagePicker});

  SupabaseClient get _client => supabaseClient ?? SupaFlow.client;
  ImagePicker get _picker => imagePicker ?? ImagePicker();

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

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;
  set notificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  // NOTE: isUploading replaced by isBusy from BaseModel

  @override
  void initState(BuildContext context) {
    super.initState(context);
    loadUserData();
  }

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
    final user = _client.auth.currentUser;
    _userEmail = user?.email;
    _userName =
        (user?.userMetadata?['name'] as String?) ??
        (user?.userMetadata?['full_name'] as String?) ??
        user?.email?.split('@').first ??
        'Usuário';

    // Try to get avatar from metadata first
    _avatarUrl = user?.userMetadata?['avatar_url'] as String?;

    // Fetch profile data from app_profiles
    // We don't await this here to not block UI init, but we run it safe
    runSafe(() => _fetchProfileData(), showErrorToast: false);
  }

  Future<void> _fetchProfileData() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _client
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
      throw app_ex.NetworkException('Erro ao carregar perfil: $e');
    }
  }

  Future<void> uploadAvatarImage(BuildContext context) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (image == null) return;

    await runSafe(() async {
      final user = _client.auth.currentUser;
      if (user == null) throw app_ex.AuthException('Usuário não autenticado');

      final fileBytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = '${user.id}/$fileName';

      final contentType =
          fileExt.toLowerCase() == 'jpg' || fileExt.toLowerCase() == 'jpeg'
          ? 'image/jpeg'
          : 'image/$fileExt';

      await _client.storage
          .from('avatars')
          .uploadBinary(
            path,
            fileBytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );

      final publicUrl = _client.storage.from('avatars').getPublicUrl(path);

      await _client
          .from('app_profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', user.id);

      _avatarUrl = publicUrl;
      notifyListeners();

      ToastService.showSuccess('Foto de perfil atualizada!');
    });
  }

  Future<void> signOut(BuildContext context) async {
    await runSafe(() async {
      await authManager.signOut();
    });
  }

  Future<void> updatePassword(BuildContext context) async {
    final password = changePasswordController?.text;
    final confirmPassword = confirmPasswordController?.text;

    await runSafe(() async {
      if (password == null || password.isEmpty) {
        throw app_ex.ValidationException('Digite a nova senha');
      }

      if (password != confirmPassword) {
        throw app_ex.ValidationException('As senhas não conferem');
      }

      if (password.length < 6) {
        throw app_ex.ValidationException(
          'A senha deve ter pelo menos 6 caracteres',
        );
      }

      await authManager.updatePassword(newPassword: password, context: context);

      // Clear fields on success
      changePasswordController?.clear();
      confirmPasswordController?.clear();

      ToastService.showSuccess('Senha alterada com sucesso!');
    });
  }
}
