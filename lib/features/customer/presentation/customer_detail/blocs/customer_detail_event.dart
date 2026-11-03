abstract class CustomerDetailEvent {}

class LoadCustomerEvent extends CustomerDetailEvent {
  final String id;
  LoadCustomerEvent(this.id);
}

class ArchiveCustomerRequested extends CustomerDetailEvent {
  final String id;
  ArchiveCustomerRequested(this.id);
}
