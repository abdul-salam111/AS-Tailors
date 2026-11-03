import 'app_dependencies.dart';
import '../../features/shop/shop_exports.dart';

Future<void> registerShop() async {
  sl.registerLazySingleton<IShopRemoteDatasource>(() => ShopRemoteDatasourceImpl(client: sl()));
  sl.registerLazySingleton<IShopRepository>(() => ShopRepositoryImpl(dataSource: sl()));
  sl.registerLazySingleton<CreateShopUsecase>(() => CreateShopUsecase(repository: sl()));

  sl.registerFactory<CreateShopBloc>(() => CreateShopBloc(createShopUsecase: sl()));
}
