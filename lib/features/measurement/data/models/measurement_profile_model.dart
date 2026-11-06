import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/measurement_profile_entity.dart';
import '../../domain/entities/measurement_value_entity.dart';
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

/// Shared with `AddCustomerWizardView`'s repository call (customer feature)
/// as well as `MeasurementRepositoryImpl` — kept as a public extension
/// rather than a private repository method so both can map a row without
/// duplicating the field list.
extension MeasurementProfileModelMapper on MeasurementProfileModel {
  MeasurementProfileEntity toEntity() => MeasurementProfileEntity(
    id: id,
    shopId: shopId,
    customerId: customerId,
    templateId: templateId,
    name: name,
    version: version,
    unit: unit,
    measuredAt: measuredAt,
    notes: notes,
    createdAt: createdAt,
    templateName: templateName,
    values: values
        .map(
          (v) => MeasurementValueEntity(
            fieldId: v.fieldId,
            fieldKey: v.fieldKey,
            labelEn: v.labelEn,
            labelUr: v.labelUr,
            inputType: v.inputType,
            value: v.value,
            unit: v.unit,
            selectedOptionLabelEn: v.selectedOptionLabelEn,
            selectedOptionLabelUr: v.selectedOptionLabelUr,
          ),
        )
        .toList(),
    imageUrls: imageUrls,
  );
}
