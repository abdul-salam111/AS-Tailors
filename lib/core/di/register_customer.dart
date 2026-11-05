import 'app_dependencies.dart';
import '../services/session_manager.dart';
import '../../features/customer/customer_exports.dart';

Future<void> registerCustomer() async {
  sl.registerLazySingleton<ICustomerRemoteDatasource>(
    () => CustomerRemoteDatasourceImpl(client: sl()),
  );
  sl.registerLazySingleton<ICustomerRepository>(
    () => CustomerRepositoryImpl(dataSource: sl(), sessionController: sl<SessionController>()),
  );
  sl.registerLazySingleton<CreateCustomerUsecase>(() => CreateCustomerUsecase(repository: sl()));
  sl.registerLazySingleton<GetCustomersUsecase>(() => GetCustomersUsecase(repository: sl()));
  sl.registerLazySingleton<GetCustomerByIdUsecase>(() => GetCustomerByIdUsecase(repository: sl()));
  sl.registerLazySingleton<UpdateCustomerUsecase>(() => UpdateCustomerUsecase(repository: sl()));
  sl.registerLazySingleton<ArchiveCustomerUsecase>(() => ArchiveCustomerUsecase(repository: sl()));
  sl.registerLazySingleton<GetCustomerCountUsecase>(
    () => GetCustomerCountUsecase(repository: sl()),
  );

  sl.registerFactory<CustomerFormBloc>(
    () => CustomerFormBloc(createCustomerUsecase: sl(), updateCustomerUsecase: sl()),
  );
  sl.registerFactory<CustomerDetailBloc>(
    () => CustomerDetailBloc(
      getCustomerByIdUsecase: sl(),
      archiveCustomerUsecase: sl(),
      getProfilesForCustomerUsecase: sl(),
    ),
  );
}
