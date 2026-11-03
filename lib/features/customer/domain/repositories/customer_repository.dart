import '../../../../core/shared/shared_exports.dart';
import '../entities/create_customer_params.dart';
import '../entities/customer_entity.dart';
import '../entities/get_customers_params.dart';
import '../entities/update_customer_params.dart';

abstract interface class ICustomerRepository {
  Future<Either<Failure, CustomerEntity>> createCustomer(CreateCustomerParams params);

  /// Scoped to the signed-in user's shop (SRS §1a item 8) — the
  /// implementation reads `SessionController.session.shopId` itself rather
  /// than taking it as a param, so every call site gets shop-scoping for
  /// free instead of having to remember to pass it.
  Future<Either<Failure, List<CustomerEntity>>> getCustomers(GetCustomersParams params);

  Future<Either<Failure, CustomerEntity>> getCustomerById(String id);

  Future<Either<Failure, CustomerEntity>> updateCustomer(UpdateCustomerParams params);

  /// Archives (never hard-deletes, per SRS §23.4) a customer linked to
  /// business history by setting `is_active = false`.
  Future<Either<Failure, CustomerEntity>> archiveCustomer(String id);
}
