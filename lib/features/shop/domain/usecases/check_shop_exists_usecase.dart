import '../../../../core/shared/shared_exports.dart';
import '../repositories/shop_repository.dart';

class CheckShopExistsUsecase implements Usecase<bool, NoParams> {
  final IShopRepository _repository;

  CheckShopExistsUsecase({required IShopRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) => _repository.checkShopExists();
}
