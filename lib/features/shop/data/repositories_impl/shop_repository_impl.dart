import '../../../../core/shared/shared_exports.dart';
import '../../domain/entities/create_shop_params.dart';
import '../../domain/entities/shop_entity.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/shop_remote_datasource/shop_remote_datasource.dart';

class ShopRepositoryImpl extends BaseRepository implements IShopRepository {
  final IShopRemoteDatasource _dataSource;

  ShopRepositoryImpl({required IShopRemoteDatasource dataSource}) : _dataSource = dataSource;

  @override
  Future<Either<Failure, ShopEntity>> createShop(CreateShopParams params) => execute(
    call: () async {
      final model = await _dataSource.bootstrapShop(
        name: params.name,
        phone: params.phone,
        currency: params.currency,
        timezone: params.timezone,
      );
      return ShopEntity(
        id: model.id,
        ownerId: model.ownerId,
        name: model.name,
        currency: model.currency,
        timezone: model.timezone,
      );
    },
  );
}
