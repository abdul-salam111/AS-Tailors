import '../../features/splash/presentation/cubit/splash_cubit.dart';
import 'app_dependencies.dart';

Future<void> registerSplash() async {
  sl.registerFactory(() => SplashCubit(splashServices: sl()));
}
