import '../../../../core/shared/shared_exports.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleUsecase implements Usecase<AuthEntity, NoParams> {
  final IAuthRepository _repository;

  SignInWithGoogleUsecase({required IAuthRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, AuthEntity>> call(NoParams params) => _repository.signInWithGoogle();
}
