import 'package:freezed_annotation/freezed_annotation.dart';
import 'measurement_value_model.dart';

part 'measurement_profile_model.freezed.dart';
part 'measurement_profile_model.g.dart';

/// `values`/`imageUrls` are never present in the raw `measurement_profiles`
/// row JSON — populated via `copyWith` after separate queries, same as
/// `MeasurementTemplateModel.fields`.
@freezed
abstract class MeasurementProfileModel with _$MeasurementProfileModel {
  const factory MeasurementProfileModel({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'customer_id') required String customerId,
    @JsonKey(name: 'template_id') required String templateId,
    String? name,
    required int version,
    required String unit,
    @JsonKey(name: 'measured_at') required DateTime measuredAt,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Not a column on `measurement_profiles` — attached via `copyWith`
    /// from a joined `measurement_templates(name)` select, same pattern as
    /// `values`/`imageUrls` below.
    String? templateName,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(<MeasurementValueModel>[])
    List<MeasurementValueModel> values,
    @Default(<String>[]) List<String> imageUrls,
  }) = _MeasurementProfileModel;

  factory MeasurementProfileModel.fromJson(Map<String, dynamic> json) =>
      _$MeasurementProfileModelFromJson(json);
}
