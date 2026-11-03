import '../../../../core/shared/shared_exports.dart';
import '../entities/auth_entity.dart';
import '../entities/signin_params.dart';
import '../entities/signup_params.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, SigninEntity>> signInById(SignInParams params);
  Future<Either<Failure, SigninEntity>> signup(SignupParams params);
}
