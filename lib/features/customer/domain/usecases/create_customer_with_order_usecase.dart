import '../../../../core/shared/shared_exports.dart';
import '../entities/new_customer_order_params.dart';
import '../entities/new_customer_order_result.dart';
import '../repositories/customer_repository.dart';

class CreateCustomerWithOrderUsecase
    implements Usecase<NewCustomerOrderResult, NewCustomerOrderParams> {
  final ICustomerRepository _repository;

  CreateCustomerWithOrderUsecase({required ICustomerRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, NewCustomerOrderResult>> call(NewCustomerOrderParams params) =>
      _repository.createCustomerWithOrder(params);
}
