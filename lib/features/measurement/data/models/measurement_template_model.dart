import 'package:freezed_annotation/freezed_annotation.dart';
import 'measurement_template_field_model.dart';

part 'measurement_template_model.freezed.dart';
part 'measurement_template_model.g.dart';

/// `fields` is never present in the raw `measurement_templates` row JSON —
/// the datasource fetches it with a separate query and attaches it via
/// `copyWith` after `fromJson` parses the row itself.
@freezed
abstract class MeasurementTemplateModel with _$MeasurementTemplateModel {
  const factory MeasurementTemplateModel({
    required String id,
    @JsonKey(name: 'category_id') required String categoryId,
    required String name,
    required int version,
    @Default(<MeasurementTemplateFieldModel>[]) List<MeasurementTemplateFieldModel> fields,
  }) = _MeasurementTemplateModel;

  factory MeasurementTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$MeasurementTemplateModelFromJson(json);
}
