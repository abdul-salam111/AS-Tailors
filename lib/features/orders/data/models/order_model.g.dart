// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => _OrderModel(
  id: json['id'] as String,
  shopId: json['shop_id'] as String,
  customerId: json['customer_id'] as String,
  orderNumber: (json['order_number'] as num).toInt(),
  status: json['status'] as String,
  dueDate: json['due_date'] == null ? null : DateTime.parse(json['due_date'] as String),
  notes: json['notes'] as String?,
  totalAmount: (json['total_amount'] as num).toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$OrderModelToJson(_OrderModel instance) => <String, dynamic>{
  'id': instance.id,
  'shop_id': instance.shopId,
  'customer_id': instance.customerId,
  'order_number': instance.orderNumber,
  'status': instance.status,
  'due_date': instance.dueDate?.toIso8601String(),
  'notes': instance.notes,
  'total_amount': instance.totalAmount,
  'created_at': instance.createdAt.toIso8601String(),
};
