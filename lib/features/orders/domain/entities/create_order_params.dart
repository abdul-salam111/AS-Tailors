import 'package:equatable/equatable.dart';

class CreateOrderItemParams extends Equatable {
  final String categoryId;
  final String? measurementProfileId;
  final int quantity;
  final double unitPrice;
  final String? notes;

  const CreateOrderItemParams({
    required this.categoryId,
    this.measurementProfileId,
    required this.quantity,
    required this.unitPrice,
    this.notes,
  });

  @override
  List<Object?> get props => [categoryId, measurementProfileId, quantity, unitPrice, notes];
}

class CreateOrderParams extends Equatable {
  final String customerId;
  final DateTime? dueDate;
  final String? notes;
  final List<CreateOrderItemParams> items;

  const CreateOrderParams({
    required this.customerId,
    this.dueDate,
    this.notes,
    required this.items,
  });

  @override
  List<Object?> get props => [customerId, dueDate, notes, items];
}
