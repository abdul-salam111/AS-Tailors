import '../../../../core/shared/shared_exports.dart';
import '../entities/auth_entity.dart';
import '../entities/signin_params.dart';
import '../repositories/auth_repository.dart';

class SignInUsecase implements Usecase<AuthEntity, SignInParams> {
  final IAuthRepository _repository;

  SignInUsecase({required IAuthRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, AuthEntity>> call(SignInParams params) => _repository.signIn(params);
}
