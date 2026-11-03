import '../../../../core/shared/shared_exports.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class GetCustomerByIdUsecase implements Usecase<CustomerEntity, String> {
  final ICustomerRepository _repository;

  GetCustomerByIdUsecase({required ICustomerRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, CustomerEntity>> call(String id) => _repository.getCustomerById(id);
}
