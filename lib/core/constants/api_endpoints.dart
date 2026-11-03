import 'env.dart';

class ApiEndPoints {
  static String get baseUrl => Env.baseUrl;
  static String get appToken => Env.appToken;

  static String get loginByUid => '${baseUrl}user/signInById';
  static String get signupUser => '${baseUrl}user/signup';
  static String get accounts => '${baseUrl}accounts';
  static String get forgotPassword => '${baseUrl}TODO/auth/forgot_password'; // TODO: replace with real path
  static String get products => '${baseUrl}products';
}
