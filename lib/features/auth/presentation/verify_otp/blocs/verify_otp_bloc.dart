import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../domain/entities/verify_otp_params.dart';
import '../../../domain/usecases/resend_signup_otp_usecase.dart';
import '../../../domain/usecases/verify_signup_otp_usecase.dart';
import 'verify_otp_event.dart';
import 'verify_otp_state.dart';

class VerifyOtpBloc extends Bloc<VerifyOtpEvent, VerifyOtpState> with UsecaseExecuterMixin {
  final VerifySignupOtpUsecase _verifySignupOtpUsecase;
  final ResendSignupOtpUsecase _resendSignupOtpUsecase;

  VerifyOtpBloc({
    required VerifySignupOtpUsecase verifySignupOtpUsecase,
    required ResendSignupOtpUsecase resendSignupOtpUsecase,
  }) : _verifySignupOtpUsecase = verifySignupOtpUsecase,
       _resendSignupOtpUsecase = resendSignupOtpUsecase,
       super(const VerifyOtpState()) {
    on<VerifyOtpInitialized>((event, emit) => emit(state.copyWith(email: event.email)));
    on<OtpChangedEvent>((event, emit) => emit(state.copyWith(otp: event.otp)));
    on<VerifyOtpSubmitted>(_onSubmit);
    on<ResendOtpRequested>(_onResend);
  }

  Future<void> _onSubmit(VerifyOtpSubmitted event, Emitter<VerifyOtpState> emit) => executeUsecase(
    emit: emit,
    currentState: state,
    usecase: () => _verifySignupOtpUsecase(VerifyOtpParams(email: state.email, token: state.otp)),
    stateBuilder: (status, {data, error, failure}) =>
        state.copyWith(apiStatus: status, authEntity: data, message: error, failure: failure),
  );

  // Hand-rolled rather than `executeUsecase` — a resend shouldn't flip the
  // whole screen (code field, verify button) into a loading state, so it
  // needs its own status field. See [VerifyOtpState.resendStatus].
  Future<void> _onResend(ResendOtpRequested event, Emitter<VerifyOtpState> emit) async {
    emit(state.copyWith(resendStatus: ApiStatus.LOADING));
    final result = await _resendSignupOtpUsecase(state.email);
    result.fold(
      (failure) => emit(state.copyWith(resendStatus: ApiStatus.FAILURE, failure: failure)),
      (_) => emit(state.copyWith(resendStatus: ApiStatus.SUCCESS)),
    );
  }
}
