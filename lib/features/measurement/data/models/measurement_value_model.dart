import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/app_enums.dart';

part 'measurement_value_model.freezed.dart';

/// Assembled by the datasource from a join between `measurement_values`,
/// `measurement_template_fields` and (for dropdown picks)
/// `measurement_template_field_options` — not parsed from a single raw
/// table row, so there's no `fromJson` factory (constructed directly,
/// hence no `.g.dart` part either).
@freezed
abstract class MeasurementValueModel with _$MeasurementValueModel {
  const factory MeasurementValueModel({
    required String fieldId,
    required String fieldKey,
    required String labelEn,
    String? labelUr,
    required MeasurementFieldInputType inputType,
    double? value,
    String? unit,
    String? selectedOptionLabelEn,
    String? selectedOptionLabelUr,
  }) = _MeasurementValueModel;
}
