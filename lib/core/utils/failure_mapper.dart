import '../shared/domain/failures/failure.dart';

/// How the UI should surface an error to the user.
enum ErrorDisplay {
  /// Brief overlay at the top of the screen (flushbar / snackbar).
  toast,

  /// Inline message beneath the relevant form field.
  inline,

  /// Replaces the current screen content with an error view.
  fullScreen,

  /// Modal dialog that requires explicit user dismissal.
  dialog,
}

/// A domain [Failure] translated into a user-facing message and display intent.
///
/// Produced by [AppFailureMapper.map] and consumed by the presentation layer
/// to decide *how* (not just *what*) to show the error.
class UserFacingError {
  const UserFacingError({
    required this.message,
    required this.display,
  });

  final String message;
  final ErrorDisplay display;
}

/// Maps domain [Failure] subtypes to [UserFacingError] with an appropriate
/// display strategy.
///
/// Usage in a BLoC listener:
/// ```dart
/// listener: (context, state) {
///   if (state.apiStatus == ApiStatus.failure && state.failure != null) {
///     final error = AppFailureMapper.map(state.failure!);
///     switch (error.display) {
///       case ErrorDisplay.toast:
///         AppToastsUtils.showErrorTop(context, error.message);
///       case ErrorDisplay.dialog:
///         _showErrorDialog(context, error.message);
///       case ErrorDisplay.fullScreen:
///         // navigate to error screen
///       case ErrorDisplay.inline:
///         // handled by form field validators
///     }
///   }
/// },
/// ```
class AppFailureMapper {
  const AppFailureMapper._();

  static UserFacingError map(Failure failure) {
    return switch (failure) {
      AuthFailure() => UserFacingError(
          message: failure.message,
          display: ErrorDisplay.dialog,
        ),
      ValidationFailure() => UserFacingError(
          message: failure.message,
          display: ErrorDisplay.inline,
        ),
      NetworkFailure() => const UserFacingError(
          message: 'No internet connection. Please check your network.',
          display: ErrorDisplay.toast,
        ),
      RateLimitFailure() => const UserFacingError(
          message: 'Too many attempts. Please wait a moment and try again.',
          display: ErrorDisplay.toast,
        ),
      NotFoundFailure() => UserFacingError(
          message: failure.message,
          display: ErrorDisplay.toast,
        ),
      ServerFailure() => const UserFacingError(
          message: 'Something went wrong on our end. Please try again.',
          display: ErrorDisplay.toast,
        ),
      UnexpectedFailure() => const UserFacingError(
          message: 'An unexpected error occurred.',
          display: ErrorDisplay.toast,
        ),
      _ => UserFacingError(
          message: failure.message,
          display: ErrorDisplay.toast,
        ),
    };
  }
}
