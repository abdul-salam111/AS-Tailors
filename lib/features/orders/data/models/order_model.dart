import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

/// Maps an `orders` row (see `supabase/migrations/0009_orders.sql`).
/// Always comes back from `create_order()` with `total_amount` already
/// server-recalculated — never constructed with a client-supplied total.
@freezed
abstract class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'customer_id') required String customerId,
    @JsonKey(name: 'order_number') required int orderNumber,
    required String status,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    String? notes,
    @JsonKey(name: 'total_amount') required double totalAmount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
}
