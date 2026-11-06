import '../../../../core/shared/shared_exports.dart';
import '../entities/create_customer_params.dart';
import '../entities/customer_entity.dart';
import '../entities/get_customers_params.dart';
import '../entities/new_customer_order_params.dart';
import '../entities/new_customer_order_result.dart';
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

  /// Count of active customers in the signed-in user's shop, optionally
  /// restricted to ones created on/after [since].
  Future<Either<Failure, int>> getCustomerCount({DateTime? since});

  /// Atomic "new customer" wizard submit (`AddCustomerWizardView`) —
  /// creates the customer, their first measurement profile and their
  /// first order together in one transaction. See
  /// `create_customer_with_order()` in `0010_create_customer_with_order.sql`.
  Future<Either<Failure, NewCustomerOrderResult>> createCustomerWithOrder(
    NewCustomerOrderParams params,
  );
}
