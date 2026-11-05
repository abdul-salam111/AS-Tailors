// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_template_field_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MeasurementTemplateFieldModel _$MeasurementTemplateFieldModelFromJson(Map<String, dynamic> json) =>
    _MeasurementTemplateFieldModel(
      id: json['id'] as String,
      fieldKey: json['field_key'] as String,
      labelEn: json['label_en'] as String,
      labelUr: json['label_ur'] as String?,
      sectionKey: json['section_key'] as String?,
      sectionLabelEn: json['section_label_en'] as String?,
      sectionLabelUr: json['section_label_ur'] as String?,
      displayOrder: (json['display_order'] as num).toInt(),
      isRequired: json['is_required'] as bool,
      inputType: $enumDecode(_$MeasurementFieldInputTypeEnumMap, json['input_type']),
      defaultUnit: json['default_unit'] as String,
    );

Map<String, dynamic> _$MeasurementTemplateFieldModelToJson(
  _MeasurementTemplateFieldModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'field_key': instance.fieldKey,
  'label_en': instance.labelEn,
  'label_ur': instance.labelUr,
  'section_key': instance.sectionKey,
  'section_label_en': instance.sectionLabelEn,
  'section_label_ur': instance.sectionLabelUr,
  'display_order': instance.displayOrder,
  'is_required': instance.isRequired,
  'input_type': _$MeasurementFieldInputTypeEnumMap[instance.inputType]!,
  'default_unit': instance.defaultUnit,
};

const _$MeasurementFieldInputTypeEnumMap = {
  MeasurementFieldInputType.number: 'number',
  MeasurementFieldInputType.counter: 'counter',
  MeasurementFieldInputType.dropdown: 'dropdown',
  MeasurementFieldInputType.checkbox: 'checkbox',
};
