import 'package:equatable/equatable.dart';
import 'measurement_field_value.dart';

class CreateMeasurementProfileParams extends Equatable {
  final String customerId;
  final String templateId;
  final String? name;
  final String unit;
  final String? notes;

  /// Maps a template field's id to what the user entered for it.
  final Map<String, MeasurementFieldValue> values;

  /// Local file paths of reference photos to upload after the profile row
  /// is created (Postgres and Storage aren't one transaction, so the
  /// measurement data itself — the primary goal — is safely stored even if
  /// a photo upload fails).
  final List<String> imageFilePaths;

  const CreateMeasurementProfileParams({
    required this.customerId,
    required this.templateId,
    this.name,
    required this.unit,
    this.notes,
    required this.values,
    this.imageFilePaths = const [],
  });

  @override
  List<Object?> get props => [customerId, templateId, name, unit, notes, values, imageFilePaths];
}
