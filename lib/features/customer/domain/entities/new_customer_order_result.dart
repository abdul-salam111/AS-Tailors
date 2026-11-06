import 'package:equatable/equatable.dart';
import '../../../measurement/domain/entities/measurement_profile_entity.dart';
import '../../../orders/domain/entities/order_entity.dart';
import 'customer_entity.dart';

/// The 3 rows `createCustomerWithOrder` created in one transaction.
class NewCustomerOrderResult extends Equatable {
  final CustomerEntity customer;
  final MeasurementProfileEntity measurementProfile;
  final OrderEntity order;

  const NewCustomerOrderResult({
    required this.customer,
    required this.measurementProfile,
    required this.order,
  });

  @override
  List<Object?> get props => [customer, measurementProfile, order];
}
