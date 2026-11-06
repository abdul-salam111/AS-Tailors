import '../../../../measurement/domain/entities/measurement_field_value.dart';

abstract class AddCustomerWizardEvent {}

/// Loads garment categories once, and the signed-in shop's default
/// measurement unit, same as `MeasurementFormInitialized`.
class WizardInitialized extends AddCustomerWizardEvent {
  final String initialUnit;
  WizardInitialized(this.initialUnit);
}

/// Advances to [step] — only allowed backward (tapping an already-visited
/// step indicator) or via [WizardNextPressed]'s own validation; the view
/// never fires this to skip ahead unvalidated.
class WizardStepChanged extends AddCustomerWizardEvent {
  final int step;
  WizardStepChanged(this.step);
}

class WizardNextPressed extends AddCustomerWizardEvent {}

class WizardBackPressed extends AddCustomerWizardEvent {}

// Step 1 — customer
class CustomerFullNameChanged extends AddCustomerWizardEvent {
  final String value;
  CustomerFullNameChanged(this.value);
}

class CustomerWhatsappChanged extends AddCustomerWizardEvent {
  final String value;
  CustomerWhatsappChanged(this.value);
}

class CustomerAddressChanged extends AddCustomerWizardEvent {
  final String value;
  CustomerAddressChanged(this.value);
}

class CustomerNotesChanged extends AddCustomerWizardEvent {
  final String value;
  CustomerNotesChanged(this.value);
}

// Step 2 — measurement
class WizardCategorySelected extends AddCustomerWizardEvent {
  final String categoryId;
  WizardCategorySelected(this.categoryId);
}

class WizardFieldValueChanged extends AddCustomerWizardEvent {
  final String fieldId;
  final MeasurementFieldValue value;
  WizardFieldValueChanged(this.fieldId, this.value);
}

class MeasurementNotesChanged extends AddCustomerWizardEvent {
  final String value;
  MeasurementNotesChanged(this.value);
}

// Step 3 — order
class OrderQuantityChanged extends AddCustomerWizardEvent {
  final int value;
  OrderQuantityChanged(this.value);
}

class OrderUnitPriceChanged extends AddCustomerWizardEvent {
  final double? value;
  OrderUnitPriceChanged(this.value);
}

class OrderDueDateChanged extends AddCustomerWizardEvent {
  final DateTime? value;
  OrderDueDateChanged(this.value);
}

class OrderNotesChanged extends AddCustomerWizardEvent {
  final String value;
  OrderNotesChanged(this.value);
}

class WizardSubmitted extends AddCustomerWizardEvent {}
