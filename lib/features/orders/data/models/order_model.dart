import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/order_entity.dart';

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

/// Shared with `AddCustomerWizardView`'s repository call (customer
/// feature) as well as `OrderRepositoryImpl` — kept as a public extension
/// rather than a private repository method so both can map a row without
/// duplicating the field list.
extension OrderModelMapper on OrderModel {
  OrderEntity toEntity() => OrderEntity(
    id: id,
    shopId: shopId,
    customerId: customerId,
    orderNumber: orderNumber,
    status: status,
    dueDate: dueDate,
    notes: notes,
    totalAmount: totalAmount,
    createdAt: createdAt,
  );
}
