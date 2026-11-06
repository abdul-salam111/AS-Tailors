class AppConstants {
  static const String appName = 'Flutter App';

  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;

  static const int pageSize = 20;
  static const int firstPage = 1;

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration splashDuration = Duration(seconds: 2);
  // ─── Auth ──────────────────────────────────────────────
  static const String signInBtn = 'SignIn';
  static const String youHaveLoggedInSuccessfully = 'You have logged in successfully!';
  static const String signIn = 'Sign In';
  static const String enterYourEmail = 'Enter your email';
  static const String enterYourPassword = 'Enter your password';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String signUpBtn = 'Sign Up';
  static const String signUp = 'Sign Up';
  static const String youHaveSignedUpSuccessfully = 'You have signed up successfully!';
  static const String name = 'Name';
  static const String enterYourName = 'Enter your name';
  static const String confirmPassword = 'Confirm Password';
  static const String enterYourConfirmPassword = 'Re-enter your password';
  static const String alreadyHaveAnAccount = 'Already have an account?';
  static const String dontHaveAnAccount = "Don't have an account?";

  // ─── Storage Keys ─────────────────────────────────────
  // Auth session keys were removed — Supabase Auth owns session storage.
  static const String keyIsDarkMode = 'isDarkMode';
  static const String keyLocale = 'locale';
  static const String keyMeasurementUnit = 'measurementUnit';

  // ─── Network Exceptions ────────────────────────────────
  static const String unexpectedError = 'An unexpected error occurred';
  static const String noInternetConnection = 'No internet connection';
  static const String unauthorizedRequest = 'Unauthorized request';
  static const String requestTimedOut = 'Request timed out';
  static const String errorFetchingData = 'Error fetching data';
  static const String invalidRequest = 'Invalid request';
  static const String resourceNotFound = 'Resource not found';
  static const String internalServerError = 'Internal server error';
  static const String serviceUnavailable = 'Service unavailable';
  static const String invalidInput = 'Invalid input';
  static const String accessForbidden = 'Access forbidden';
  static const String tooManyRequests = 'Too many requests';
  static const String methodNotAllowed = 'Method not allowed';
}
