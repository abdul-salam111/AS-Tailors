import 'package:equatable/equatable.dart';

class SigninEntity extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final String? tokenType;

  const SigninEntity({
    required this.accessToken,
    this.refreshToken,
    this.tokenType,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, tokenType];
}
