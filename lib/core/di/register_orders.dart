import 'app_dependencies.dart';
import '../services/session_manager.dart';
import '../../features/measurement/measurement_exports.dart';
import '../../features/orders/orders_exports.dart';

/// Called after `registerMeasurement()` — `AddOrderBloc` depends on
/// `GetGarmentCategoriesUsecase` from that feature to populate its
/// category picker.
Future<void> registerOrders() async {
  sl.registerLazySingleton<IOrderRemoteDatasource>(() => OrderRemoteDatasourceImpl(client: sl()));
  sl.registerLazySingleton<IOrderRepository>(
    () => OrderRepositoryImpl(dataSource: sl(), sessionController: sl<SessionController>()),
  );
  sl.registerLazySingleton<CreateOrderUsecase>(() => CreateOrderUsecase(repository: sl()));

  sl.registerFactory<AddOrderBloc>(
    () => AddOrderBloc(
      getGarmentCategoriesUsecase: sl<GetGarmentCategoriesUsecase>(),
      createOrderUsecase: sl(),
    ),
  );
}
