import 'package:equatable/equatable.dart';

/// A tailoring order (`orders` row) — returned by `createOrder`. Read-only
/// elsewhere until an orders list/detail screen exists.
class OrderEntity extends Equatable {
  final String id;
  final String shopId;
  final String customerId;
  final int orderNumber;
  final String status;
  final DateTime? dueDate;
  final String? notes;
  final double totalAmount;
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    required this.shopId,
    required this.customerId,
    required this.orderNumber,
    required this.status,
    this.dueDate,
    this.notes,
    required this.totalAmount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    shopId,
    customerId,
    orderNumber,
    status,
    dueDate,
    notes,
    totalAmount,
    createdAt,
  ];
}
