// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garment_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GarmentCategoryModel _$GarmentCategoryModelFromJson(Map<String, dynamic> json) =>
    _GarmentCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameUr: json['name_ur'] as String?,
      slug: json['slug'] as String,
    );

Map<String, dynamic> _$GarmentCategoryModelToJson(_GarmentCategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_ur': instance.nameUr,
      'slug': instance.slug,
    };
