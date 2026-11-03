import 'package:equatable/equatable.dart';
import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/shared/domain/failures/failure.dart';
import '../../../domain/entities/auth_entity.dart';

class SignInState extends Equatable {
  final SigninEntity? signinEntity;
  final String? message;
  final Failure? failure;
  final ApiStatus apiStatus;
  final String email;
  final String password;

  const SignInState({
    this.signinEntity,
    this.message,
    this.failure,
    this.apiStatus = ApiStatus.INITIAL,
    this.email = '',
    this.password = '',
  });

  SignInState copyWith({
    SigninEntity? signinEntity,
    String? message,
    Failure? failure,
    ApiStatus? apiStatus,
    String? email,
    String? password,
  }) {
    return SignInState(
      signinEntity: signinEntity ?? this.signinEntity,
      message: message ?? this.message,
      failure: failure ?? this.failure,
      apiStatus: apiStatus ?? this.apiStatus,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props =>
      [signinEntity, message, failure, apiStatus, email, password];
}
