import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../customer/domain/entities/customer_entity.dart';
import '../../../../measurement/domain/entities/garment_category_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/order_item_draft_entity.dart';

class AddOrderState extends Equatable {
  final List<GarmentCategoryEntity> categories;
  final ApiStatus categoriesStatus;
  final CustomerEntity? customer;
  final DateTime? dueDate;
  final String notes;
  final List<OrderItemDraftEntity> items;
  final ApiStatus submitStatus;
  final OrderEntity? createdOrder;
  final Failure? failure;

  const AddOrderState({
    this.categories = const [],
    this.categoriesStatus = ApiStatus.INITIAL,
    this.customer,
    this.dueDate,
    this.notes = '',
    this.items = const [],
    this.submitStatus = ApiStatus.INITIAL,
    this.createdOrder,
    this.failure,
  });

  /// Display-only sum of the drafted items — the authoritative total comes
  /// back from `create_order()` on submit (CLAUDE.md §1a money rule).
  double get totalAmount => items.fold(0, (sum, item) => sum + item.lineTotal);

  AddOrderState copyWith({
    List<GarmentCategoryEntity>? categories,
    ApiStatus? categoriesStatus,
    CustomerEntity? customer,
    DateTime? dueDate,
    String? notes,
    List<OrderItemDraftEntity>? items,
    ApiStatus? submitStatus,
    OrderEntity? createdOrder,
    Failure? failure,
  }) {
    return AddOrderState(
      categories: categories ?? this.categories,
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      customer: customer ?? this.customer,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      submitStatus: submitStatus ?? this.submitStatus,
      createdOrder: createdOrder ?? this.createdOrder,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    categoriesStatus,
    customer,
    dueDate,
    notes,
    items,
    submitStatus,
    createdOrder,
    failure,
  ];
}
