import '../../../../customer/domain/entities/customer_entity.dart';
import '../../../domain/entities/order_item_draft_entity.dart';

abstract class AddOrderEvent {}

class AddOrderInitialized extends AddOrderEvent {
  final CustomerEntity? initialCustomer;
  AddOrderInitialized([this.initialCustomer]);
}

class OrderCustomerSelected extends AddOrderEvent {
  final CustomerEntity customer;
  OrderCustomerSelected(this.customer);
}

class OrderDueDateChanged extends AddOrderEvent {
  final DateTime dueDate;
  OrderDueDateChanged(this.dueDate);
}

class OrderNotesChanged extends AddOrderEvent {
  final String value;
  OrderNotesChanged(this.value);
}

class OrderItemAdded extends AddOrderEvent {
  final OrderItemDraftEntity item;
  OrderItemAdded(this.item);
}

class OrderItemRemoved extends AddOrderEvent {
  final int index;
  OrderItemRemoved(this.index);
}

class AddOrderSubmitted extends AddOrderEvent {}
