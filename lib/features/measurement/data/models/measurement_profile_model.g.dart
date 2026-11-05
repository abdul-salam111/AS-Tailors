// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MeasurementProfileModel _$MeasurementProfileModelFromJson(Map<String, dynamic> json) =>
    _MeasurementProfileModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      customerId: json['customer_id'] as String,
      templateId: json['template_id'] as String,
      name: json['name'] as String?,
      version: (json['version'] as num).toInt(),
      unit: json['unit'] as String,
      measuredAt: DateTime.parse(json['measured_at'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      templateName: json['templateName'] as String?,
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
    );

Map<String, dynamic> _$MeasurementProfileModelToJson(_MeasurementProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shop_id': instance.shopId,
      'customer_id': instance.customerId,
      'template_id': instance.templateId,
      'name': instance.name,
      'version': instance.version,
      'unit': instance.unit,
      'measured_at': instance.measuredAt.toIso8601String(),
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'templateName': instance.templateName,
      'imageUrls': instance.imageUrls,
    };
