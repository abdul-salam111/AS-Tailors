import 'package:freezed_annotation/freezed_annotation.dart';

part 'garment_category_model.freezed.dart';
part 'garment_category_model.g.dart';

@freezed
abstract class GarmentCategoryModel with _$GarmentCategoryModel {
  const factory GarmentCategoryModel({
    required String id,
    required String name,
    @JsonKey(name: 'name_ur') String? nameUr,
    required String slug,
  }) = _GarmentCategoryModel;

  factory GarmentCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$GarmentCategoryModelFromJson(json);
}
