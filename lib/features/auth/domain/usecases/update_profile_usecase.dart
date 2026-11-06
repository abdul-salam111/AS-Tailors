import '../../../../core/shared/shared_exports.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUsecase implements Usecase<AuthEntity, String> {
  final IAuthRepository _repository;

  UpdateProfileUsecase({required IAuthRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, AuthEntity>> call(String fullName) =>
      _repository.updateProfile(fullName: fullName);
}
