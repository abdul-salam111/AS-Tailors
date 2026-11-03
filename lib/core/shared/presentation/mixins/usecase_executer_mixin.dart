import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' hide State;
import '../../domain/failures/failure.dart';
import '../../../constants/app_enums.dart';

/// A mixin for [Bloc] classes that simplifies executing a single use-case.
///
/// ## What it does
/// Wraps the standard loading → success/failure state transition so that
/// individual BLoC event handlers stay to a few lines rather than repeating
/// the same emit/fold boilerplate everywhere.
///
/// ## How to use
/// 1. Add `with UsecaseExecuterMixin` to your BLoC declaration.
/// 2. Call [executeUsecase] inside an event handler, providing:
///    - [usecase]      — a closure that calls your use-case and returns
///                       `Future<Either<Failure, T>>`.
///    - [stateBuilder] — maps `(ApiStatus, {data, error, failure})` to your
///                       state. Called three times: loading, then success or
///                       failure. `error` is `failure?.message` for quick
///                       display; keep the `Failure` itself on state too if
///                       you want `AppFailureMapper` to pick a display
///                       strategy (toast/dialog/inline) in the listener.
///    - [emit]         — the emitter from the event handler.
///    - [currentState] — passed through so [stateBuilder] can use `copyWith`.
///
/// ## When NOT to use it
/// This mixin is intentionally thin. For BLoCs that need custom retry logic,
/// optimistic updates, pagination, or multi-step flows, handle the `Either`
/// result inline in your event handler instead.
///
/// ## Example
/// ```dart
/// class SignInBloc extends Bloc<SignInEvent, SignInState>
///     with UsecaseExecuterMixin {
///   Future<void> _onSubmit(SignInSubmitted event, Emitter<SignInState> emit) {
///     return executeUsecase(
///       emit: emit,
///       currentState: state,
///       usecase: () => signinUsecase(SignInParams(...)),
///       stateBuilder: (status, {data, error}) =>
///           state.copyWith(apiStatus: status, signinEntity: data, message: error),
///     );
///   }
/// }
/// ```
mixin UsecaseExecuterMixin<Event, State> on Bloc<Event, State> {
  Future<void> executeUsecase<T>({
    required Emitter<State> emit,
    required State currentState,
    required Future<Either<Failure, T>> Function() usecase,
    required State Function(ApiStatus status, {T? data, String? error, Failure? failure})
    stateBuilder,
  }) async {
    emit(stateBuilder(ApiStatus.LOADING));
    final result = await usecase();
    result.fold(
      (failure) => emit(stateBuilder(ApiStatus.FAILURE, error: failure.message, failure: failure)),
      (data) => emit(stateBuilder(ApiStatus.SUCCESS, data: data)),
    );
  }
}
