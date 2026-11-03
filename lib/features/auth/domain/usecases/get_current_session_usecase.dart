import '../../../../core/shared/shared_exports.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentSessionUsecase implements Usecase<AuthEntity?, NoParams> {
  final IAuthRepository _repository;

  GetCurrentSessionUsecase({required IAuthRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, AuthEntity?>> call(NoParams params) => _repository.getCurrentSession();
}
