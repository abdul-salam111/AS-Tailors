import '../../../../core/shared/shared_exports.dart';
import '../entities/auth_entity.dart';
import '../entities/signin_params.dart';
import '../repositories/auth_repository.dart';

class SignInUsecase implements Usecase<SigninEntity, SignInParams> {
  final IAuthRepository _repository;

  SignInUsecase({required IAuthRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, SigninEntity>> call(SignInParams params) =>
      _repository.signInById(params);
}
