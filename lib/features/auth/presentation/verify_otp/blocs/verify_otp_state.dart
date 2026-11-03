import 'package:equatable/equatable.dart';
import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/shared/domain/failures/failure.dart';
import '../../../domain/entities/auth_entity.dart';

class VerifyOtpState extends Equatable {
  final String email;
  final String otp;
  final AuthEntity? authEntity;
  final String? message;
  final Failure? failure;
  final ApiStatus apiStatus;

  /// Kept separate from [apiStatus] so a resend doesn't put the whole
  /// screen (including the code field) back into a loading state — same
  /// reasoning as `CustomerDetailBloc`'s `isArchiving` flag.
  final ApiStatus resendStatus;

  const VerifyOtpState({
    this.email = '',
    this.otp = '',
    this.authEntity,
    this.message,
    this.failure,
    this.apiStatus = ApiStatus.INITIAL,
    this.resendStatus = ApiStatus.INITIAL,
  });

  VerifyOtpState copyWith({
    String? email,
    String? otp,
    AuthEntity? authEntity,
    String? message,
    Failure? failure,
    ApiStatus? apiStatus,
    ApiStatus? resendStatus,
  }) {
    return VerifyOtpState(
      email: email ?? this.email,
      otp: otp ?? this.otp,
      authEntity: authEntity ?? this.authEntity,
      message: message ?? this.message,
      failure: failure ?? this.failure,
      apiStatus: apiStatus ?? this.apiStatus,
      resendStatus: resendStatus ?? this.resendStatus,
    );
  }

  @override
  List<Object?> get props => [
    email,
    otp,
    authEntity,
    message,
    failure,
    apiStatus,
    resendStatus,
  ];
}
