import '../../../../../core/shared/shared_exports.dart';
import '../../models/order_model.dart';

abstract interface class IOrderRemoteDatasource {
  /// Atomic order + line-items write via `create_order()` (money +
  /// measurement snapshots, see `0009_orders.sql`). [items] is a list of
  /// `{category_id, measurement_profile_id, quantity, unit_price, notes}`
  /// maps, one per garment, built by the repository.
  Future<OrderModel> createOrder({
    required String shopId,
    required String customerId,
    DateTime? dueDate,
    String? notes,
    required List<Map<String, dynamic>> items,
  });
}

class OrderRemoteDatasourceImpl extends BaseSupabaseDatasource implements IOrderRemoteDatasource {
  const OrderRemoteDatasourceImpl({required super.client});

  @override
  Future<OrderModel> createOrder({
    required String shopId,
    required String customerId,
    DateTime? dueDate,
    String? notes,
    required List<Map<String, dynamic>> items,
  }) => rpc(
    function: 'create_order',
    params: {
      'p_shop_id': shopId,
      'p_customer_id': customerId,
      'p_due_date': dueDate == null ? null : _dateOnly(dueDate),
      'p_notes': notes,
      'p_items': items,
    },
    parser: (data) => OrderModel.fromJson(data as Map<String, dynamic>),
  );

  /// Postgres `date` wants `YYYY-MM-DD`, not a full ISO-8601 timestamp.
  String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
