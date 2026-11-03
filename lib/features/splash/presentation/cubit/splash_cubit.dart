import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/splash_services.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final SplashServices _splashServices;

  SplashCubit({required SplashServices splashServices})
    : _splashServices = splashServices,
      super(const SplashInitial());

  Future<void> checkAuthStatus() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final session = await _splashServices.resolveSession();
    if (session == null) {
      emit(const SplashUnauthenticated());
    } else if (!session.hasShop) {
      emit(const SplashNeedsShop());
    } else {
      emit(const SplashAuthenticated());
    }
  }
}
