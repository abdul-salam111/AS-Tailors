// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_template_field_option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MeasurementTemplateFieldOptionModel _$MeasurementTemplateFieldOptionModelFromJson(
  Map<String, dynamic> json,
) => _MeasurementTemplateFieldOptionModel(
  id: json['id'] as String,
  optionKey: json['option_key'] as String,
  labelEn: json['label_en'] as String,
  labelUr: json['label_ur'] as String?,
  displayOrder: (json['display_order'] as num).toInt(),
);

Map<String, dynamic> _$MeasurementTemplateFieldOptionModelToJson(
  _MeasurementTemplateFieldOptionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'option_key': instance.optionKey,
  'label_en': instance.labelEn,
  'label_ur': instance.labelUr,
  'display_order': instance.displayOrder,
};
