import '../../../../../core/constants/const_exports.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../models/request_models/login_user_by_id/login_user_by_id.dart';
import '../../models/request_models/signup_user/signup_user.dart';
import '../../models/response_models/user_token/user_token.dart';

abstract interface class IAuthRemoteDatasource {
  Future<UserToken> loginUserById({required LoginUserById loginUserById});
  Future<UserToken> signup({required SignupUser signupUser});
}

class AuthRemoteDatasourceImpl extends BaseRemoteDatasource
    implements IAuthRemoteDatasource {
  AuthRemoteDatasourceImpl({required super.dioHelper});

  @override
  Future<UserToken> loginUserById({
    required LoginUserById loginUserById,
  }) async {
    return post(
      url: ApiEndPoints.loginByUid,
      parser: (json) => UserToken.fromJson(json as Map<String, dynamic>),
      body: loginUserById.toJson(),
    );
  }

  @override
  Future<UserToken> signup({required SignupUser signupUser}) async {
    return post(
      url: ApiEndPoints.signupUser,
      parser: (json) => UserToken.fromJson(json as Map<String, dynamic>),
      body: signupUser.toJson(),
    );
  }
}
