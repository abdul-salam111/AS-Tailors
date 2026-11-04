import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../customer/domain/usecases/get_customer_count_usecase.dart';
import 'dashboard_state.dart';

/// Loads the dashboard's real stats (only customer counts exist as real
/// data today — see CLAUDE.md's gap list for orders/measurements/
/// payments). Plain [Cubit] rather than `UsecaseExecuterMixin`'s
/// single-usecase flow since this fans out to two calls at once.
class DashboardCubit extends Cubit<DashboardState> {
  final GetCustomerCountUsecase _getCustomerCountUsecase;

  DashboardCubit({required GetCustomerCountUsecase getCustomerCountUsecase})
    : _getCustomerCountUsecase = getCustomerCountUsecase,
      super(const DashboardState());

  Future<void> loadStats() async {
    emit(state.copyWith(apiStatus: ApiStatus.LOADING));

    final results = await Future.wait([
      _getCustomerCountUsecase(null),
      _getCustomerCountUsecase(DateTime.now().startOfWeek()),
    ]);
    final totalResult = results[0];
    final newThisWeekResult = results[1];

    final failure =
        totalResult.fold((f) => f, (_) => null) ?? newThisWeekResult.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(apiStatus: ApiStatus.FAILURE, failure: failure));
      return;
    }

    emit(
      state.copyWith(
        apiStatus: ApiStatus.SUCCESS,
        totalCustomers: totalResult.getOrElse((_) => 0),
        newCustomersThisWeek: newThisWeekResult.getOrElse((_) => 0),
      ),
    );
  }
}
