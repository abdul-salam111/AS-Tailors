import '../local_storage/storage.dart';
import '../services/connectivity_service.dart';
import '../services/session_manager.dart';
import 'app_dependencies.dart';

Future<void> registerCore() async {
  sl.registerLazySingleton(() => LocalStorage());
  sl.registerLazySingleton(() => SessionController(supabaseClient: sl()));
  sl.registerLazySingleton(() => ConnectivityService());
  // SplashServices needs ISessionResolver, registered by registerAuth() —
  // registered there too, see register_auth.dart.
}
