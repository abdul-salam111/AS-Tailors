import 'package:equatable/equatable.dart';

abstract class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object> get props => [];
}

class EmailChangedEvent extends SignInEvent {
  final String email;
  const EmailChangedEvent(this.email);
}

class PasswordChangedEvent extends SignInEvent {
  final String password;
  const PasswordChangedEvent(this.password);
}

class SignInSubmitted extends SignInEvent {}
