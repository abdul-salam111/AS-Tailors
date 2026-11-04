import 'package:supabase_flutter/supabase_flutter.dart' show User;
import '../../../../core/networks/exceptions/app_exceptions.dart';
import '../../../../core/shared/shared_exports.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/signin_params.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl extends BaseRepository implements IAuthRepository {
  final IAuthRemoteDatasource _dataSource;

  AuthRepositoryImpl({required IAuthRemoteDatasource dataSource}) : _dataSource = dataSource;

  @override
  Future<Either<Failure, AuthEntity>> signIn(SignInParams params) => execute(
    call: () async {
      final response = await _dataSource.signInWithPassword(
        email: params.email,
        password: params.password,
      );
      final user = response.user;
      if (user == null) {
        throw const UnauthorizedException('Sign-in did not return a user.');
      }
      return _buildEntity(user);
    },
  );

  @override
  Future<Either<Failure, AuthEntity>> signInWithGoogle() => execute(
    call: () async {
      final response = await _dataSource.signInWithGoogle();
      final user = response.user;
      if (user == null) {
        throw const UnauthorizedException('Google sign-in did not return a user.');
      }
      return _buildEntity(user);
    },
  );

  @override
  Future<Either<Failure, AuthEntity>> signInWithApple() => execute(
    call: () async {
      final response = await _dataSource.signInWithApple();
      final user = response.user;
      if (user == null) {
        throw const UnauthorizedException('Apple sign-in did not return a user.');
      }
      return _buildEntity(user);
    },
  );

  @override
  Future<Either<Failure, void>> signOut() => execute(call: _dataSource.signOut);

  @override
  Future<Either<Failure, AuthEntity?>> getCurrentSession() => execute(
    call: () async {
      final user = _dataSource.currentUser;
      if (user == null) return null;
      return _buildEntity(user);
    },
  );

  Future<AuthEntity> _buildEntity(User user) async {
    final membership = await _dataSource.fetchMembership(user.id);
    return AuthEntity(
      userId: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
      shopId: membership?.shopId,
      role: membership?.role,
    );
  }
}
