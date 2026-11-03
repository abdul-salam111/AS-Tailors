import '../../../../../core/shared/shared_exports.dart';
import '../../../domain/entities/signup_params.dart';
import '../../../domain/usecases/signup_usecase.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState>
    with UsecaseExecuterMixin {
  final SignupUsecase _signupUsecase;

  SignupBloc({required SignupUsecase signupUsecase})
      : _signupUsecase = signupUsecase,
        super(const SignupState()) {
    on<SignupSubmitted>(_onSignupSubmitted);
    on<NameChangedEvent>(
      (event, emit) => emit(state.copyWith(name: event.name)),
    );
    on<SignupEmailChangedEvent>(
      (event, emit) => emit(state.copyWith(email: event.email)),
    );
    on<SignupPasswordChangedEvent>(
      (event, emit) => emit(state.copyWith(password: event.password)),
    );
    on<ConfirmPasswordChangedEvent>(
      (event, emit) =>
          emit(state.copyWith(confirmPassword: event.confirmPassword)),
    );
  }

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<SignupState> emit,
  ) async {
    await executeUsecase(
      emit: emit,
      currentState: state,
      usecase: () => _signupUsecase(
        SignupParams(
          name: state.name,
          email: state.email,
          password: state.password,
        ),
      ),
      stateBuilder: (status, {data, error, failure}) => state.copyWith(
        apiStatus: status,
        signupEntity: data,
        message: error,
        failure: failure,
      ),
    );
  }
}
