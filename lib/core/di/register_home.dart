import 'app_dependencies.dart';
import '../../features/home/home_exports.dart';

Future<void> registerHome() async {
  sl.registerFactory<DashboardCubit>(() => DashboardCubit(getCustomerCountUsecase: sl()));
}
