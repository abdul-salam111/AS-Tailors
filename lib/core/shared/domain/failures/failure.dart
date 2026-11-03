abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure([super.message = 'Too many requests']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred']);
}

/// The user backed out of a native OAuth sheet (Google/Apple) themselves —
/// listeners should treat this as a silent no-op, not an error to display.
class UserCancelledFailure extends Failure {
  const UserCancelledFailure([super.message = 'Sign-in was cancelled.']);
}
