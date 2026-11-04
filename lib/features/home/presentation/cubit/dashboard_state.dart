import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/shared/domain/failures/failure.dart';

class DashboardState extends Equatable {
  final ApiStatus apiStatus;
  final int? totalCustomers;
  final int? newCustomersThisWeek;
  final Failure? failure;

  const DashboardState({
    this.apiStatus = ApiStatus.INITIAL,
    this.totalCustomers,
    this.newCustomersThisWeek,
    this.failure,
  });

  DashboardState copyWith({
    ApiStatus? apiStatus,
    int? totalCustomers,
    int? newCustomersThisWeek,
    Failure? failure,
  }) {
    return DashboardState(
      apiStatus: apiStatus ?? this.apiStatus,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      newCustomersThisWeek: newCustomersThisWeek ?? this.newCustomersThisWeek,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [apiStatus, totalCustomers, newCustomersThisWeek, failure];
}
