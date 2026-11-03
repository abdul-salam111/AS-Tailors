import '../../../../core/shared/shared_exports.dart';
import '../entities/create_customer_params.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class CreateCustomerUsecase implements Usecase<CustomerEntity, CreateCustomerParams> {
  final ICustomerRepository _repository;

  CreateCustomerUsecase({required ICustomerRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, CustomerEntity>> call(CreateCustomerParams params) =>
      _repository.createCustomer(params);
}
