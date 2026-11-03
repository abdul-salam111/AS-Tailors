import '../../../../core/shared/shared_exports.dart';
import '../entities/auth_entity.dart';
import '../entities/signup_params.dart';
import '../repositories/auth_repository.dart';

class SignupUsecase implements Usecase<AuthEntity, SignupParams> {
  final IAuthRepository _repository;

  SignupUsecase({required IAuthRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, AuthEntity>> call(SignupParams params) => _repository.signUp(params);
}
