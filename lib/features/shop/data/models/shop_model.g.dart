// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShopModel _$ShopModelFromJson(Map<String, dynamic> json) => _ShopModel(
  id: json['id'] as String,
  ownerId: json['owner_id'] as String,
  name: json['name'] as String,
  currency: json['currency'] as String,
  timezone: json['timezone'] as String,
);

Map<String, dynamic> _$ShopModelToJson(_ShopModel instance) => <String, dynamic>{
  'id': instance.id,
  'owner_id': instance.ownerId,
  'name': instance.name,
  'currency': instance.currency,
  'timezone': instance.timezone,
};
