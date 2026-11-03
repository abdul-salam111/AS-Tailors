import '../local_storage/storage.dart';
import '../services/connectivity_service.dart';
import '../services/session_manager.dart';
import '../services/splash_services.dart';
import 'app_dependencies.dart';

Future<void> registerCore() async {
  sl.registerLazySingleton(() =>  LocalStorage());
  sl.registerLazySingleton(() => SessionController(localStorage: sl()));
  sl.registerLazySingleton(() => SplashServices(sessionController: sl()));
  sl.registerLazySingleton(() => ConnectivityService());
}
