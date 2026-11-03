import 'env.dart';

class ApiEndPoints {
  static String get baseUrl => Env.baseUrl;
  static String get appToken => Env.appToken;

  // Auth now goes through Supabase Auth (see the `auth` feature), not a
  // REST endpoint here — no login/signup URLs in this class anymore.
  static String get accounts => '${baseUrl}accounts';
  static String get forgotPassword =>
      '${baseUrl}TODO/auth/forgot_password'; // TODO: replace with real path
  static String get products => '${baseUrl}products';
}
