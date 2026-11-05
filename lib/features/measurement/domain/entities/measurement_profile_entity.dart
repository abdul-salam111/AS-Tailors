import 'package:equatable/equatable.dart';
import 'measurement_value_entity.dart';

/// A versioned, named measurement record for one customer + garment
/// category (SRS §23.5). `values`/`imageUrls` are empty for the summary
/// shape used in list views — populated only by `getProfileDetail`.
class MeasurementProfileEntity extends Equatable {
  final String id;
  final String shopId;
  final String customerId;
  final String templateId;
  final String? name;
  final int version;
  final String unit;
  final DateTime measuredAt;
  final String? notes;
  final DateTime createdAt;

  /// The template's display name (e.g. "Shalwar Kameez Measurements") —
  /// only populated by queries that join it; null otherwise.
  final String? templateName;
  final List<MeasurementValueEntity> values;
  final List<String> imageUrls;

  const MeasurementProfileEntity({
    required this.id,
    required this.shopId,
    required this.customerId,
    required this.templateId,
    this.name,
    required this.version,
    required this.unit,
    required this.measuredAt,
    this.notes,
    required this.createdAt,
    this.templateName,
    this.values = const [],
    this.imageUrls = const [],
  });

  @override
  List<Object?> get props => [
    id,
    shopId,
    customerId,
    templateId,
    name,
    version,
    unit,
    measuredAt,
    notes,
    createdAt,
    templateName,
    values,
    imageUrls,
  ];
}
