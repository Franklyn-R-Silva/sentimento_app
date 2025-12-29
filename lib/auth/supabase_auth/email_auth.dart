// Project imports:
import 'package:sentimento_app/backend/database.dart';

Future<User?> emailSignInFunc(final String email, final String password) async {
  final res = await SupaFlow.client.auth.signInWithPassword(
    email: email,
    password: password,
  );
  return res.user;
}

Future<User?> emailCreateAccountFunc(
  final String email,
  final String password, {
  final Map<String, dynamic>? data,
}) async {
  final res = await SupaFlow.client.auth.signUp(
    email: email,
    password: password,
    data: data,
  );

  // If the Supabase project is configured to not let users sign in until the
  // email has been confirmed, the user returned in the AuthResponse still has
  // all the user info. But since the user shouldn't be able to sign in without
  // their email verified, return a null User.
  return res.user?.lastSignInAt == null ? null : res.user;
}
