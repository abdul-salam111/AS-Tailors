import 'package:equatable/equatable.dart';

/// One not-yet-submitted garment line in the Add Order form. Pure
/// client-side scratch state — turned into a [CreateOrderItemParams] only
/// at submit time. [categoryName]/[measurementProfileLabel] are captured
/// once when the item is added (via `_AddOrderItemSheet`) so the order
/// summary list can render without re-resolving them from an id.
class OrderItemDraftEntity extends Equatable {
  final String categoryId;
  final String categoryName;
  final String? measurementProfileId;
  final String? measurementProfileLabel;
  final int quantity;
  final double unitPrice;
  final String? notes;

  const OrderItemDraftEntity({
    required this.categoryId,
    required this.categoryName,
    this.measurementProfileId,
    this.measurementProfileLabel,
    required this.quantity,
    required this.unitPrice,
    this.notes,
  });

  /// Display-only — the authoritative total is recalculated server-side
  /// in `create_order()` (CLAUDE.md §1a: totals are never client-trusted).
  double get lineTotal => quantity * unitPrice;

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    measurementProfileId,
    measurementProfileLabel,
    quantity,
    unitPrice,
    notes,
  ];
}
