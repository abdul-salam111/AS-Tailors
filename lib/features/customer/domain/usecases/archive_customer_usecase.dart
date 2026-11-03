import '../../../../core/shared/shared_exports.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class ArchiveCustomerUsecase implements Usecase<CustomerEntity, String> {
  final ICustomerRepository _repository;

  ArchiveCustomerUsecase({required ICustomerRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, CustomerEntity>> call(String id) => _repository.archiveCustomer(id);
}
