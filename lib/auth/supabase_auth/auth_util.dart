// Project imports:
import 'package:sentimento_app/auth/supabase_auth/supabase_auth_manager.dart';
import 'package:sentimento_app/backend/supabase.dart';

export 'supabase_auth_manager.dart';

final _authManager = SupabaseAuthManager();
SupabaseAuthManager get authManager => _authManager;

String get currentUserEmail => currentUser?.email ?? '';

String get currentUserUid => currentUser?.uid ?? '';

String get currentUserDisplayName => currentUser?.displayName ?? '';

String get currentUserPhoto => currentUser?.photoUrl ?? '';

String get currentPhoneNumber => currentUser?.phoneNumber ?? '';

String get currentJwtToken => _currentJwtToken ?? '';

bool get currentUserEmailVerified => currentUser?.emailVerified ?? false;

// Dados do perfil do usuário
int? _currentUserMatricula;
String? _currentUserTipoPermissao;
String? _currentUserFullName;

int? get currentUserMatricula => _currentUserMatricula;
String? get currentUserTipoPermissao => _currentUserTipoPermissao;
String? get currentUserFullName => _currentUserFullName;

/// Carrega o perfil do usuário autenticado
Future<void> loadUserProfile() async {
  if (currentUserUid.isEmpty) {
    _currentUserMatricula = null;
    _currentUserTipoPermissao = null;
    _currentUserFullName = null;
    return;
  }

  try {
    final profiles = await AppProfilesTable().queryRows(
      queryFn: (final q) => q.eq('id', currentUserUid),
    );

    if (profiles.isNotEmpty) {
      final profile = profiles.first;
      _currentUserMatricula = profile.matricula;
      _currentUserTipoPermissao = profile.tipoPermissao;
      _currentUserFullName = profile.fullName;
    } else {
      _currentUserMatricula = null;
      _currentUserTipoPermissao = null;
      _currentUserFullName = null;
    }
  } catch (e) {
    _currentUserMatricula = null;
    _currentUserTipoPermissao = null;
    _currentUserFullName = null;
  }
}

/// Limpa os dados do perfil do usuário
void clearUserProfile() {
  _currentUserMatricula = null;
  _currentUserTipoPermissao = null;
  _currentUserFullName = null;
}

/// Create a Stream that listens to the current user's JWT Token.
String? _currentJwtToken;
final jwtTokenStream = SupaFlow.client.auth.onAuthStateChange
    .map((final authState) => _currentJwtToken = authState.session?.accessToken)
    .asBroadcastStream();
