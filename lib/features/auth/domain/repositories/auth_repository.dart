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

  /// Exchanges the 6-digit code emailed after [signUp] for a real session —
  /// the returned [AuthEntity] includes shop membership, since by this
  /// point the user is genuinely authenticated.
  Future<Either<Failure, AuthEntity>> verifySignupOtp({required String email, required String token});

  /// Re-sends the signup verification email (with a fresh code).
  Future<Either<Failure, void>> resendSignupOtp({required String email});

  /// Resolves the current Supabase session (if any) into an [AuthEntity],
  /// including shop membership. `Right(null)` means nobody is signed in —
  /// that's a valid outcome, not a failure.
  Future<Either<Failure, AuthEntity?>> getCurrentSession();
}
