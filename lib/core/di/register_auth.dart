import '../services/session_resolver.dart';
import '../services/splash_services.dart';
import 'app_dependencies.dart';
import '../../features/auth/auth_exports.dart';

Future<void> registerAuth() async {
  // DataSource
  sl.registerLazySingleton<IAuthRemoteDatasource>(() => AuthRemoteDatasourceImpl(client: sl()));

  // Repository
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(dataSource: sl()));

  // Dependency-inversion adapter: implements core's ISessionResolver port
  // using this feature's own repository. See core/services/session_resolver.dart.
  sl.registerLazySingleton<ISessionResolver>(() => SessionResolverImpl(authRepository: sl()));
  sl.registerLazySingleton(() => SplashServices(sessionResolver: sl(), sessionController: sl()));

  // UseCases
  sl.registerLazySingleton<SignInUsecase>(() => SignInUsecase(repository: sl()));
  sl.registerLazySingleton<SignInWithGoogleUsecase>(
    () => SignInWithGoogleUsecase(repository: sl()),
  );
  sl.registerLazySingleton<SignInWithAppleUsecase>(() => SignInWithAppleUsecase(repository: sl()));
  sl.registerLazySingleton<SignOutUsecase>(() => SignOutUsecase(repository: sl()));
  sl.registerLazySingleton<GetCurrentSessionUsecase>(
    () => GetCurrentSessionUsecase(repository: sl()),
  );

  // BLoC — factory so each screen gets a fresh instance
  sl.registerFactory<SignInBloc>(() => SignInBloc(signinUsecase: sl()));
}
