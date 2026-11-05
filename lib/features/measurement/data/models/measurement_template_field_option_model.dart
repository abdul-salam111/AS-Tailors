import 'package:freezed_annotation/freezed_annotation.dart';

part 'measurement_template_field_option_model.freezed.dart';
part 'measurement_template_field_option_model.g.dart';

@freezed
abstract class MeasurementTemplateFieldOptionModel with _$MeasurementTemplateFieldOptionModel {
  const factory MeasurementTemplateFieldOptionModel({
    required String id,
    @JsonKey(name: 'option_key') required String optionKey,
    @JsonKey(name: 'label_en') required String labelEn,
    @JsonKey(name: 'label_ur') String? labelUr,
    @JsonKey(name: 'display_order') required int displayOrder,
  }) = _MeasurementTemplateFieldOptionModel;

  factory MeasurementTemplateFieldOptionModel.fromJson(Map<String, dynamic> json) =>
      _$MeasurementTemplateFieldOptionModelFromJson(json);
}
