import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../measurement/domain/entities/measurement_profile_entity.dart';
import '../../../domain/entities/customer_entity.dart';

class CustomerDetailState extends Equatable {
  final ApiStatus apiStatus;
  final CustomerEntity? customer;
  final String? message;
  final Failure? failure;

  /// Tracks the archive action separately from [apiStatus] so a slow
  /// archive request doesn't flip the whole screen back to a loading
  /// spinner — the already-loaded customer stays visible underneath.
  final bool isArchiving;

  /// Independent of [apiStatus] — the measurements list loads in parallel
  /// with the customer's own details, not after them.
  final List<MeasurementProfileEntity> measurementProfiles;
  final ApiStatus measurementsStatus;

  const CustomerDetailState({
    this.apiStatus = ApiStatus.INITIAL,
    this.customer,
    this.message,
    this.failure,
    this.isArchiving = false,
    this.measurementProfiles = const [],
    this.measurementsStatus = ApiStatus.INITIAL,
  });

  CustomerDetailState copyWith({
    ApiStatus? apiStatus,
    CustomerEntity? customer,
    String? message,
    Failure? failure,
    bool? isArchiving,
    List<MeasurementProfileEntity>? measurementProfiles,
    ApiStatus? measurementsStatus,
  }) {
    return CustomerDetailState(
      apiStatus: apiStatus ?? this.apiStatus,
      customer: customer ?? this.customer,
      message: message ?? this.message,
      failure: failure ?? this.failure,
      isArchiving: isArchiving ?? this.isArchiving,
      measurementProfiles: measurementProfiles ?? this.measurementProfiles,
      measurementsStatus: measurementsStatus ?? this.measurementsStatus,
    );
  }

  @override
  List<Object?> get props => [
    apiStatus,
    customer,
    message,
    failure,
    isArchiving,
    measurementProfiles,
    measurementsStatus,
  ];
}
