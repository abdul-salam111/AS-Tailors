import '../../../../core/shared/shared_exports.dart';
import '../entities/create_shop_params.dart';
import '../entities/shop_entity.dart';

abstract interface class IShopRepository {
  /// Provisions the shop and makes the caller its owner — the "controlled
  /// setup process" from SRS §3, wrapping the `bootstrap_shop` RPC. Fails
  /// if a shop already exists (single-shop deployment, SRS §1.4) or if the
  /// caller already belongs to one.
  Future<Either<Failure, ShopEntity>> createShop(CreateShopParams params);
}
