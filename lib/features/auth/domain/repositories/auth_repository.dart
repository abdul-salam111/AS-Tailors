import '../../../../core/shared/shared_exports.dart';
import '../entities/auth_entity.dart';
import '../entities/signin_params.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, AuthEntity>> signIn(SignInParams params);
  Future<Either<Failure, AuthEntity>> signInWithGoogle();
  Future<Either<Failure, AuthEntity>> signInWithApple();
  Future<Either<Failure, void>> signOut();

  /// Resolves the current Supabase session (if any) into an [AuthEntity],
  /// including shop membership. `Right(null)` means nobody is signed in —
  /// that's a valid outcome, not a failure.
  Future<Either<Failure, AuthEntity?>> getCurrentSession();

  /// Updates the signed-in user's display name (`auth.users.user_metadata
  /// .full_name` — the same field `_buildEntity`/`AuthEntity.fullName`
  /// reads, so this is the one value that actually needs changing for the
  /// name shown around the app to update).
  Future<Either<Failure, AuthEntity>> updateProfile({required String fullName});

  /// Uploads the image at [filePath] as the signed-in user's avatar and
  /// updates `user_metadata.avatar_url` to point at it.
  Future<Either<Failure, AuthEntity>> updateAvatar({required String filePath});
}
