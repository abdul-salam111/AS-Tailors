import 'package:equatable/equatable.dart';
import 'measurement_template_field_entity.dart';

/// A versioned set of fields for one garment category (SRS §9.4).
class MeasurementTemplateEntity extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final int version;
  final List<MeasurementTemplateFieldEntity> fields;

  const MeasurementTemplateEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.version,
    required this.fields,
  });

  @override
  List<Object?> get props => [id, categoryId, name, version, fields];
}
