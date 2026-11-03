import 'app_dependencies.dart';
import '../../features/auth/auth_exports.dart';

Future<void> registerAuth() async {
  // DataSource
  sl.registerLazySingleton<IAuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(dioHelper: sl()),
  );

  // Repository
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl()),
  );

  // UseCase
  sl.registerLazySingleton<SignInUsecase>(
    () => SignInUsecase(repository: sl()),
  );
  sl.registerLazySingleton<SignupUsecase>(
    () => SignupUsecase(repository: sl()),
  );

  // BLoC — factory so each screen gets a fresh instance
  sl.registerFactory<SignInBloc>(() => SignInBloc(signinUsecase: sl()));
  sl.registerFactory<SignupBloc>(() => SignupBloc(signupUsecase: sl()));
}
