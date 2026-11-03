import 'package:equatable/equatable.dart';
import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/shared/domain/failures/failure.dart';
import '../../../domain/entities/auth_entity.dart';

class SignupState extends Equatable {
  final SigninEntity? signupEntity;
  final String? message;
  final Failure? failure;
  final ApiStatus apiStatus;
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  const SignupState({
    this.signupEntity,
    this.message,
    this.failure,
    this.apiStatus = ApiStatus.INITIAL,
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
  });

  SignupState copyWith({
    SigninEntity? signupEntity,
    String? message,
    Failure? failure,
    ApiStatus? apiStatus,
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
  }) {
    return SignupState(
      signupEntity: signupEntity ?? this.signupEntity,
      message: message ?? this.message,
      failure: failure ?? this.failure,
      apiStatus: apiStatus ?? this.apiStatus,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  @override
  List<Object?> get props => [
        signupEntity,
        message,
        failure,
        apiStatus,
        name,
        email,
        password,
        confirmPassword,
      ];
}
