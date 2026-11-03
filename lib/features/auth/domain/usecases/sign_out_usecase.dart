import '../../../../core/shared/shared_exports.dart';
import '../repositories/auth_repository.dart';

class SignOutUsecase implements Usecase<void, NoParams> {
  final IAuthRepository _repository;

  SignOutUsecase({required IAuthRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) => _repository.signOut();
}
