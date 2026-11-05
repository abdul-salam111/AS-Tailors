abstract class CustomerDetailEvent {}

class LoadCustomerEvent extends CustomerDetailEvent {
  final String id;
  LoadCustomerEvent(this.id);
}

class ArchiveCustomerRequested extends CustomerDetailEvent {
  final String id;
  ArchiveCustomerRequested(this.id);
}

/// Fired alongside [LoadCustomerEvent] — an independent fan-out, not a
/// continuation of it, so a slow measurements fetch never blocks the
/// customer's own contact-info rows from rendering.
class LoadMeasurementsEvent extends CustomerDetailEvent {
  final String customerId;
  LoadMeasurementsEvent(this.customerId);
}
