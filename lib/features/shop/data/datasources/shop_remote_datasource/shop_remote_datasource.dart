import '../../../../../core/shared/shared_exports.dart';
import '../../models/shop_model.dart';

abstract interface class IShopRemoteDatasource {
  Future<ShopModel> bootstrapShop({
    required String name,
    String? phone,
    required String currency,
    required String timezone,
  });

  /// Whether this single-shop deployment (SRS §1.4) already has its owner
  /// — callable pre-login (`shop_exists()` is granted to `anon` too) so the
  /// sign-in/sign-up screens can gate the entry point itself. See
  /// `supabase/migrations/0003_shop_exists.sql`.
  Future<bool> shopExists();

  /// Joins the caller to the single existing shop as `staff` — the
  /// auto-join counterpart to [bootstrapShop] for every account after the
  /// first. See `supabase/migrations/0004_join_existing_shop.sql`.
  Future<ShopModel> joinExistingShop();
}

class ShopRemoteDatasourceImpl extends BaseSupabaseDatasource implements IShopRemoteDatasource {
  const ShopRemoteDatasourceImpl({required super.client});

  @override
  Future<ShopModel> bootstrapShop({
    required String name,
    String? phone,
    required String currency,
    required String timezone,
  }) => rpc(
    function: 'bootstrap_shop',
    params: {'p_name': name, 'p_phone': phone, 'p_currency': currency, 'p_timezone': timezone},
    parser: (data) => ShopModel.fromJson(data as Map<String, dynamic>),
  );

  @override
  Future<bool> shopExists() => rpc(function: 'shop_exists', parser: (data) => data as bool);

  @override
  Future<ShopModel> joinExistingShop() => rpc(
    function: 'join_existing_shop',
    parser: (data) => ShopModel.fromJson(data as Map<String, dynamic>),
  );
}
