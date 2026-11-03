import '../../../../core/shared/shared_exports.dart';
import '../entities/customer_entity.dart';
import '../entities/update_customer_params.dart';
import '../repositories/customer_repository.dart';

class UpdateCustomerUsecase implements Usecase<CustomerEntity, UpdateCustomerParams> {
  final ICustomerRepository _repository;

  UpdateCustomerUsecase({required ICustomerRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, CustomerEntity>> call(UpdateCustomerParams params) =>
      _repository.updateCustomer(params);
}
