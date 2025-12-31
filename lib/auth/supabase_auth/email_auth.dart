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

  return res.user;
}
