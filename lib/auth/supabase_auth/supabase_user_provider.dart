// ignore_for_file: strict_raw_type

// Package imports:
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:sentimento_app/auth/base_auth_user_provider.dart';
import 'package:sentimento_app/backend/database.dart';

export '../base_auth_user_provider.dart';

class SentimentoAppSupabaseUser extends BaseAuthUser {
  SentimentoAppSupabaseUser(this.user);
  User? user;
  @override
  bool get loggedIn => user != null;

  @override
  AuthUserInfo get authUserInfo =>
      AuthUserInfo(uid: user?.id, email: user?.email, phoneNumber: user?.phone);

  @override
  Future? delete() =>
      throw UnsupportedError('The delete user operation is not yet supported.');

  @override
  Future? updateEmail(final String email) async {
    final response = await SupaFlow.client.auth.updateUser(
      UserAttributes(email: email),
    );
    if (response.user != null) {
      user = response.user;
    }
  }

  @override
  Future? updatePassword(final String newPassword) async {
    final response = await SupaFlow.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    if (response.user != null) {
      user = response.user;
    }
  }

  @override
  Future? sendEmailVerification() => throw UnsupportedError(
    'The send email verification operation is not yet supported.',
  );

  @override
  bool get emailVerified {
    // Reloads the user when checking in order to get the most up to date
    // email verified status.
    if (loggedIn && user!.emailConfirmedAt == null) {
      refreshUser();
    }
    return user?.emailConfirmedAt != null;
  }

  @override
  Future refreshUser() async {
    await SupaFlow.client.auth.refreshSession().then(
      (final _) => user = SupaFlow.client.auth.currentUser,
    );
  }
}

/// Generates a stream of the authenticated user.
/// [SupaFlow.client.auth.onAuthStateChange] does not yield any values until the
/// user is already authenticated. So we add a default null user to the stream,
/// if we need to interact with the [currentUser] before logging in.
Stream<BaseAuthUser> sentimentoAppSupabaseUserStream() {
  final user = SupaFlow.client.auth.currentUser;
  if (currentUser == null && user != null) {
    currentUser = SentimentoAppSupabaseUser(user);
  }

  final supabaseAuthStream = SupaFlow.client.auth.onAuthStateChange.debounce(
    (final authState) => authState.event == AuthChangeEvent.tokenRefreshed
        ? TimerStream(authState, const Duration(seconds: 1))
        : Stream.value(authState),
  );
  return (!loggedIn
          ? Stream<AuthState?>.value(null).concatWith([supabaseAuthStream])
          : supabaseAuthStream)
      .map<BaseAuthUser>((final authState) {
        final user =
            authState?.session?.user ?? SupaFlow.client.auth.currentUser;
        currentUser = SentimentoAppSupabaseUser(user);
        return currentUser!;
      });
}
