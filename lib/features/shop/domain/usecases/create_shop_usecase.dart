import '../../../../core/shared/shared_exports.dart';
import '../entities/create_shop_params.dart';
import '../entities/shop_entity.dart';
import '../repositories/shop_repository.dart';

class CreateShopUsecase implements Usecase<ShopEntity, CreateShopParams> {
  final IShopRepository _repository;

  CreateShopUsecase({required IShopRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, ShopEntity>> call(CreateShopParams params) =>
      _repository.createShop(params);
}
