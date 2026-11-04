import '../../../../core/shared/shared_exports.dart';
import '../entities/shop_entity.dart';
import '../repositories/shop_repository.dart';

class JoinExistingShopUsecase implements Usecase<ShopEntity, NoParams> {
  final IShopRepository _repository;

  JoinExistingShopUsecase({required IShopRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, ShopEntity>> call(NoParams params) => _repository.joinExistingShop();
}
