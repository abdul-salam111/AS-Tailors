import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/app_enums.dart';
import 'measurement_template_field_option_model.dart';

part 'measurement_template_field_model.freezed.dart';
part 'measurement_template_field_model.g.dart';

/// `options` is never present in the raw `measurement_template_fields` row
/// JSON — the datasource fetches it with a separate query and attaches it
/// via `copyWith` after `fromJson` parses the row itself (same pattern as
/// `MeasurementTemplateModel.fields`).
@freezed
abstract class MeasurementTemplateFieldModel with _$MeasurementTemplateFieldModel {
  const factory MeasurementTemplateFieldModel({
    required String id,
    @JsonKey(name: 'field_key') required String fieldKey,
    @JsonKey(name: 'label_en') required String labelEn,
    @JsonKey(name: 'label_ur') String? labelUr,
    @JsonKey(name: 'section_key') String? sectionKey,
    @JsonKey(name: 'section_label_en') String? sectionLabelEn,
    @JsonKey(name: 'section_label_ur') String? sectionLabelUr,
    @JsonKey(name: 'display_order') required int displayOrder,
    @JsonKey(name: 'is_required') required bool isRequired,
    @JsonKey(name: 'input_type') required MeasurementFieldInputType inputType,
    @JsonKey(name: 'default_unit') required String defaultUnit,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(<MeasurementTemplateFieldOptionModel>[])
    List<MeasurementTemplateFieldOptionModel> options,
  }) = _MeasurementTemplateFieldModel;

  factory MeasurementTemplateFieldModel.fromJson(Map<String, dynamic> json) =>
      _$MeasurementTemplateFieldModelFromJson(json);
}
