import '../../../../core/shared/shared_exports.dart';
import '../entities/customer_entity.dart';
import '../entities/get_customers_params.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUsecase implements Usecase<List<CustomerEntity>, GetCustomersParams> {
  final ICustomerRepository _repository;

  GetCustomersUsecase({required ICustomerRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, List<CustomerEntity>>> call(GetCustomersParams params) =>
      _repository.getCustomers(params);
}
