import '../../../../../core/shared/shared_exports.dart';
import '../../models/shop_model.dart';

abstract interface class IShopRemoteDatasource {
  Future<ShopModel> bootstrapShop({
    required String name,
    String? phone,
    required String currency,
    required String timezone,
  });
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
}
