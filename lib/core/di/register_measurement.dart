import 'app_dependencies.dart';
import '../services/session_manager.dart';
import '../../features/measurement/measurement_exports.dart';

/// Called before `registerCustomer()` in `setupLocator()` — `CustomerDetailBloc`
/// depends on `GetProfilesForCustomerUsecase` from this feature to show a
/// customer's measurements list.
Future<void> registerMeasurement() async {
  sl.registerLazySingleton<IMeasurementRemoteDatasource>(
    () => MeasurementRemoteDatasourceImpl(client: sl()),
  );
  sl.registerLazySingleton<IMeasurementRepository>(
    () => MeasurementRepositoryImpl(dataSource: sl(), sessionController: sl<SessionController>()),
  );
  sl.registerLazySingleton<GetGarmentCategoriesUsecase>(
    () => GetGarmentCategoriesUsecase(repository: sl()),
  );
  sl.registerLazySingleton<GetTemplateForCategoryUsecase>(
    () => GetTemplateForCategoryUsecase(repository: sl()),
  );
  sl.registerLazySingleton<CreateMeasurementProfileUsecase>(
    () => CreateMeasurementProfileUsecase(repository: sl()),
  );
  sl.registerLazySingleton<GetProfilesForCustomerUsecase>(
    () => GetProfilesForCustomerUsecase(repository: sl()),
  );
  sl.registerLazySingleton<GetProfileDetailUsecase>(
    () => GetProfileDetailUsecase(repository: sl()),
  );

  sl.registerFactory<MeasurementFormBloc>(
    () => MeasurementFormBloc(
      getGarmentCategoriesUsecase: sl(),
      getTemplateForCategoryUsecase: sl(),
      createMeasurementProfileUsecase: sl(),
    ),
  );
}
