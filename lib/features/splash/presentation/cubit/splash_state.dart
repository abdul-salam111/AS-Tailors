import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashAuthenticated extends SplashState {
  const SplashAuthenticated();
}

/// Signed in, but hasn't finished shop onboarding yet (SRS §3's
/// "controlled setup process" — see the `shop` feature).
class SplashNeedsShop extends SplashState {
  const SplashNeedsShop();
}

class SplashUnauthenticated extends SplashState {
  const SplashUnauthenticated();
}
