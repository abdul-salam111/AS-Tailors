import '../../../domain/entities/measurement_field_value.dart';

abstract class MeasurementFormEvent {}

/// Dispatched once, right after the bloc is created, carrying the customer
/// this measurement profile will belong to — triggers the category list
/// load. [initialUnit] seeds the form with the shop's default measurement
/// unit (Account → Settings, see `MeasurementUnitCubit`) — there's no
/// in-form unit toggle; it's a shop-level preference, not a per-form one.
class MeasurementFormInitialized extends MeasurementFormEvent {
  final String customerId;
  final String initialUnit;
  MeasurementFormInitialized(this.customerId, this.initialUnit);
}

class CategorySelectedEvent extends MeasurementFormEvent {
  final String categoryId;
  CategorySelectedEvent(this.categoryId);
}

/// Switches which of a template's sub-sections (e.g. "Qameez" vs "Shalwar")
/// is shown — a no-op for templates with no sections.
class SectionSelectedEvent extends MeasurementFormEvent {
  final String sectionKey;
  SectionSelectedEvent(this.sectionKey);
}

class FieldValueChangedEvent extends MeasurementFormEvent {
  final String fieldId;
  final MeasurementFieldValue value;
  FieldValueChangedEvent(this.fieldId, this.value);
}

class MeasurementNotesChangedEvent extends MeasurementFormEvent {
  final String value;
  MeasurementNotesChangedEvent(this.value);
}

class ImageAddedEvent extends MeasurementFormEvent {
  final String filePath;
  ImageAddedEvent(this.filePath);
}

class ImageRemovedEvent extends MeasurementFormEvent {
  final String filePath;
  ImageRemovedEvent(this.filePath);
}

class MeasurementFormSubmitted extends MeasurementFormEvent {}
