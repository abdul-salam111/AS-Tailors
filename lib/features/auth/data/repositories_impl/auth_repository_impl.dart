import '../../../../../core/shared/shared_exports.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/signin_params.dart';
import '../../domain/entities/signup_params.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource/auth_remote_datasource.dart';
import '../models/request_models/login_user_by_id/login_user_by_id.dart';
import '../models/request_models/signup_user/signup_user.dart';

class AuthRepositoryImpl extends BaseRepository implements IAuthRepository {
  final IAuthRemoteDatasource _dataSource;

  AuthRepositoryImpl({required IAuthRemoteDatasource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Either<Failure, SigninEntity>> signInById(SignInParams params) {
    return execute(
      call: () async {
        final userToken = await _dataSource.loginUserById(
          loginUserById: LoginUserById(
            uid: params.uid,
            password: params.password,
          ),
        );
        return SigninEntity(
          accessToken: userToken.accessToken ?? '',
          refreshToken: userToken.refreshToken,
          tokenType: userToken.tokenType,
        );
      },
    );
  }

  @override
  Future<Either<Failure, SigninEntity>> signup(SignupParams params) {
    return execute(
      call: () async {
        final userToken = await _dataSource.signup(
          signupUser: SignupUser(
            name: params.name,
            email: params.email,
            password: params.password,
          ),
        );
        return SigninEntity(
          accessToken: userToken.accessToken ?? '',
          refreshToken: userToken.refreshToken,
          tokenType: userToken.tokenType,
        );
      },
    );
  }
}
