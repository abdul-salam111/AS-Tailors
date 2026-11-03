import '../../../../../core/shared/shared_exports.dart';
import '../../../domain/entities/signin_params.dart';
import '../../../domain/usecases/signin_usecase.dart';
import 'signin_event.dart';
import 'signin_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> with UsecaseExecuterMixin {
  final SignInUsecase _signinUsecase;

  SignInBloc({required SignInUsecase signinUsecase})
    : _signinUsecase = signinUsecase,
      super(const SignInState()) {
    on<SignInSubmitted>(_onSignInSubmitted);
    on<EmailChangedEvent>((event, emit) => emit(state.copyWith(email: event.email)));
    on<PasswordChangedEvent>((event, emit) => emit(state.copyWith(password: event.password)));
  }

  Future<void> _onSignInSubmitted(SignInSubmitted event, Emitter<SignInState> emit) async {
    await executeUsecase(
      emit: emit,
      currentState: state,
      usecase: () => _signinUsecase(SignInParams(email: state.email, password: state.password)),
      stateBuilder: (status, {data, error, failure}) =>
          state.copyWith(apiStatus: status, signinEntity: data, message: error, failure: failure),
    );
  }
}
