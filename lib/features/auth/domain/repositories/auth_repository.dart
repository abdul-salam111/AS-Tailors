import '../../../../core/shared/shared_exports.dart';
import '../entities/auth_entity.dart';
import '../entities/signin_params.dart';
import '../entities/signup_params.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, AuthEntity>> signIn(SignInParams params);
  Future<Either<Failure, AuthEntity>> signUp(SignupParams params);
  Future<Either<Failure, AuthEntity>> signInWithGoogle();
  Future<Either<Failure, AuthEntity>> signInWithApple();
  Future<Either<Failure, void>> signOut();

  /// Resolves the current Supabase session (if any) into an [AuthEntity],
  /// including shop membership. `Right(null)` means nobody is signed in —
  /// that's a valid outcome, not a failure.
  Future<Either<Failure, AuthEntity?>> getCurrentSession();
}
