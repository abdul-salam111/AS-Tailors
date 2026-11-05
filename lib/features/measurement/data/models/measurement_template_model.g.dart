// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MeasurementTemplateModel _$MeasurementTemplateModelFromJson(Map<String, dynamic> json) =>
    _MeasurementTemplateModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      version: (json['version'] as num).toInt(),
      fields:
          (json['fields'] as List<dynamic>?)
              ?.map((e) => MeasurementTemplateFieldModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <MeasurementTemplateFieldModel>[],
    );

Map<String, dynamic> _$MeasurementTemplateModelToJson(_MeasurementTemplateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'name': instance.name,
      'version': instance.version,
      'fields': instance.fields,
    };
