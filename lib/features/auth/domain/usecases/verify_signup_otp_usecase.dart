import '../../../../core/shared/shared_exports.dart';
import '../entities/auth_entity.dart';
import '../entities/verify_otp_params.dart';
import '../repositories/auth_repository.dart';

class VerifySignupOtpUsecase implements Usecase<AuthEntity, VerifyOtpParams> {
  final IAuthRepository _repository;

  VerifySignupOtpUsecase({required IAuthRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, AuthEntity>> call(VerifyOtpParams params) =>
      _repository.verifySignupOtp(email: params.email, token: params.token);
}
