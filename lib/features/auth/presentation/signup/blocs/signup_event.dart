import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object> get props => [];
}

class NameChangedEvent extends SignupEvent {
  final String name;
  const NameChangedEvent(this.name);
}

class SignupEmailChangedEvent extends SignupEvent {
  final String email;
  const SignupEmailChangedEvent(this.email);
}

class SignupPasswordChangedEvent extends SignupEvent {
  final String password;
  const SignupPasswordChangedEvent(this.password);
}

class ConfirmPasswordChangedEvent extends SignupEvent {
  final String confirmPassword;
  const ConfirmPasswordChangedEvent(this.confirmPassword);
}

class SignupSubmitted extends SignupEvent {}
