import '../../../domain/entities/customer_entity.dart';

abstract class CustomerFormEvent {}

/// Dispatched once, right after the bloc is created, to pre-fill the form
/// when editing an existing customer. Pass `null` for add mode.
class CustomerFormInitialized extends CustomerFormEvent {
  final CustomerEntity? customer;
  CustomerFormInitialized(this.customer);
}

class FullNameChangedEvent extends CustomerFormEvent {
  final String value;
  FullNameChangedEvent(this.value);
}

class PhoneChangedEvent extends CustomerFormEvent {
  final String value;
  PhoneChangedEvent(this.value);
}

class WhatsappChangedEvent extends CustomerFormEvent {
  final String value;
  WhatsappChangedEvent(this.value);
}

class EmailChangedEvent extends CustomerFormEvent {
  final String value;
  EmailChangedEvent(this.value);
}

class AddressChangedEvent extends CustomerFormEvent {
  final String value;
  AddressChangedEvent(this.value);
}

class NotesChangedEvent extends CustomerFormEvent {
  final String value;
  NotesChangedEvent(this.value);
}

class CustomerFormSubmitted extends CustomerFormEvent {}
