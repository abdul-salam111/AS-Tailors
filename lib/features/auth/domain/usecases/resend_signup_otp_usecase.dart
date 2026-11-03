import '../../../../core/shared/shared_exports.dart';
import '../repositories/auth_repository.dart';

class ResendSignupOtpUsecase implements Usecase<void, String> {
  final IAuthRepository _repository;

  ResendSignupOtpUsecase({required IAuthRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, void>> call(String email) => _repository.resendSignupOtp(email: email);
}
