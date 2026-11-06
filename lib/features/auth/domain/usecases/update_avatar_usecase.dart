import '../../../../core/shared/shared_exports.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateAvatarUsecase implements Usecase<AuthEntity, String> {
  final IAuthRepository _repository;

  UpdateAvatarUsecase({required IAuthRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, AuthEntity>> call(String filePath) =>
      _repository.updateAvatar(filePath: filePath);
}
