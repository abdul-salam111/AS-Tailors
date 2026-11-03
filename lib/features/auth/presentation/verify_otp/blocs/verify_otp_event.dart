import 'package:equatable/equatable.dart';

abstract class VerifyOtpEvent extends Equatable {
  const VerifyOtpEvent();

  @override
  List<Object> get props => [];
}

/// Fired once, right after the screen opens, to stash the email the code
/// was sent to (passed in via the route's `extra`).
class VerifyOtpInitialized extends VerifyOtpEvent {
  final String email;
  const VerifyOtpInitialized(this.email);

  @override
  List<Object> get props => [email];
}

class OtpChangedEvent extends VerifyOtpEvent {
  final String otp;
  const OtpChangedEvent(this.otp);

  @override
  List<Object> get props => [otp];
}

class VerifyOtpSubmitted extends VerifyOtpEvent {}

class ResendOtpRequested extends VerifyOtpEvent {}
