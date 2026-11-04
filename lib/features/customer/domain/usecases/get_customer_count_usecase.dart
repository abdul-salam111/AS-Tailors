import '../../../../core/shared/shared_exports.dart';
import '../repositories/customer_repository.dart';

/// `null` means "all-time total"; a non-null [since] restricts the count
/// to customers created on/after that date (e.g. "new this week").
class GetCustomerCountUsecase implements Usecase<int, DateTime?> {
  final ICustomerRepository _repository;

  GetCustomerCountUsecase({required ICustomerRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, int>> call(DateTime? since) => _repository.getCustomerCount(since: since);
}
