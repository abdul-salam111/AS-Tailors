// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomerModel _$CustomerModelFromJson(Map<String, dynamic> json) => _CustomerModel(
  id: json['id'] as String,
  shopId: json['shop_id'] as String,
  profileId: json['profile_id'] as String?,
  fullName: json['full_name'] as String,
  phone: json['phone'] as String?,
  normalizedPhone: json['normalized_phone'] as String?,
  whatsapp: json['whatsapp'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  notes: json['notes'] as String?,
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$CustomerModelToJson(_CustomerModel instance) => <String, dynamic>{
  'id': instance.id,
  'shop_id': instance.shopId,
  'profile_id': instance.profileId,
  'full_name': instance.fullName,
  'phone': instance.phone,
  'normalized_phone': instance.normalizedPhone,
  'whatsapp': instance.whatsapp,
  'email': instance.email,
  'address': instance.address,
  'notes': instance.notes,
  'is_active': instance.isActive,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
