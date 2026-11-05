import 'dart:io';
import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../domain/entities/measurement_field_value.dart';
import '../../models/garment_category_model.dart';
import '../../models/measurement_profile_model.dart';
import '../../models/measurement_template_field_model.dart';
import '../../models/measurement_template_field_option_model.dart';
import '../../models/measurement_template_model.dart';
import '../../models/measurement_value_model.dart';

abstract interface class IMeasurementRemoteDatasource {
  Future<List<GarmentCategoryModel>> getGarmentCategories();

  Future<MeasurementTemplateModel> getTemplateForCategory(String categoryId);

  Future<MeasurementProfileModel> createMeasurementProfile({
    required String shopId,
    required String customerId,
    required String templateId,
    String? name,
    required String unit,
    String? notes,
    required Map<String, MeasurementFieldValue> values,
  });

  Future<void> uploadReferenceImage({
    required String profileId,
    required String shopId,
    required String filePath,
  });

  Future<List<MeasurementProfileModel>> getProfilesForCustomer(String customerId);

  Future<MeasurementProfileModel> getProfileDetail(String profileId);
}

class MeasurementRemoteDatasourceImpl extends BaseSupabaseDatasource
    implements IMeasurementRemoteDatasource {
  const MeasurementRemoteDatasourceImpl({required super.client});

  static const _categoriesTable = 'garment_categories';
  static const _templatesTable = 'measurement_templates';
  static const _fieldsTable = 'measurement_template_fields';
  static const _fieldOptionsTable = 'measurement_template_field_options';
  static const _profilesTable = 'measurement_profiles';
  static const _valuesTable = 'measurement_values';
  static const _imagesTable = 'measurement_reference_images';
  static const _bucket = 'measurement-references';

  @override
  Future<List<GarmentCategoryModel>> getGarmentCategories() => list(
    query: () => client.from(_categoriesTable).select().eq('is_active', true).order('name'),
    parser: GarmentCategoryModel.fromJson,
  );

  @override
  Future<MeasurementTemplateModel> getTemplateForCategory(String categoryId) => guard(() async {
    final templateRow = await client
        .from(_templatesTable)
        .select()
        .eq('category_id', categoryId)
        .eq('is_active', true)
        .order('version', ascending: false)
        .limit(1)
        .single();
    final template = MeasurementTemplateModel.fromJson(templateRow);

    final fieldRows = await client
        .from(_fieldsTable)
        .select()
        .eq('template_id', template.id)
        .order('display_order');
    final fields = fieldRows.map(MeasurementTemplateFieldModel.fromJson).toList();

    final fieldIds = fields.map((f) => f.id).toList();
    final optionRows = fieldIds.isEmpty
        ? <Map<String, dynamic>>[]
        : await client
              .from(_fieldOptionsTable)
              .select()
              .inFilter('field_id', fieldIds)
              .order('display_order');
    final optionsByField = <String, List<MeasurementTemplateFieldOptionModel>>{};
    for (final row in optionRows) {
      final option = MeasurementTemplateFieldOptionModel.fromJson(row);
      (optionsByField[row['field_id'] as String] ??= []).add(option);
    }
    final fieldsWithOptions = fields
        .map((f) => f.copyWith(options: optionsByField[f.id] ?? const []))
        .toList();

    return template.copyWith(fields: fieldsWithOptions);
  });

  @override
  Future<MeasurementProfileModel> createMeasurementProfile({
    required String shopId,
    required String customerId,
    required String templateId,
    String? name,
    required String unit,
    String? notes,
    required Map<String, MeasurementFieldValue> values,
  }) => rpc(
    function: 'create_measurement_profile',
    params: {
      'p_shop_id': shopId,
      'p_customer_id': customerId,
      'p_template_id': templateId,
      'p_name': name,
      'p_unit': unit,
      'p_notes': notes,
      'p_values': values.entries
          .map(
            (e) => {
              'field_id': e.key,
              'value': e.value.numericValue,
              'unit': e.value.unit,
              'selected_option_id': e.value.selectedOptionId,
            },
          )
          .toList(),
    },
    parser: (data) => MeasurementProfileModel.fromJson(data as Map<String, dynamic>),
  );

  @override
  Future<void> uploadReferenceImage({
    required String profileId,
    required String shopId,
    required String filePath,
  }) => guard(() async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final extension = filePath.split('.').last;
    final storagePath = '$shopId/$profileId/${DateTime.now().microsecondsSinceEpoch}.$extension';

    await uploadToStorage(bucket: _bucket, path: storagePath, bytes: bytes);

    await client.from(_imagesTable).insert({
      'measurement_profile_id': profileId,
      'storage_path': storagePath,
    });
  });

  static MeasurementProfileModel _parseProfileWithTemplateName(Map<String, dynamic> row) {
    final template = row['measurement_templates'] as Map<String, dynamic>?;
    return MeasurementProfileModel.fromJson(
      row,
    ).copyWith(templateName: template?['name'] as String?);
  }

  @override
  Future<List<MeasurementProfileModel>> getProfilesForCustomer(String customerId) => list(
    query: () => client
        .from(_profilesTable)
        .select('*, measurement_templates(name)')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false),
    parser: _parseProfileWithTemplateName,
  );

  @override
  Future<MeasurementProfileModel> getProfileDetail(String profileId) => guard(() async {
    final profileRow = await client
        .from(_profilesTable)
        .select('*, measurement_templates(name)')
        .eq('id', profileId)
        .single();
    final profile = _parseProfileWithTemplateName(profileRow);

    final valueRows = await client
        .from(_valuesTable)
        .select('''
          field_id, value, unit,
          measurement_template_fields(field_key, label_en, label_ur, input_type),
          measurement_template_field_options(label_en, label_ur)
        ''')
        .eq('measurement_profile_id', profileId);
    final values = valueRows.map((row) {
      final field = row['measurement_template_fields'] as Map<String, dynamic>;
      final selectedOption = row['measurement_template_field_options'] as Map<String, dynamic>?;
      return MeasurementValueModel(
        fieldId: row['field_id'] as String,
        fieldKey: field['field_key'] as String,
        labelEn: field['label_en'] as String,
        labelUr: field['label_ur'] as String?,
        inputType: MeasurementFieldInputType.values.byName(field['input_type'] as String),
        value: (row['value'] as num?)?.toDouble(),
        unit: row['unit'] as String?,
        selectedOptionLabelEn: selectedOption?['label_en'] as String?,
        selectedOptionLabelUr: selectedOption?['label_ur'] as String?,
      );
    }).toList();

    final imageRows = await client
        .from(_imagesTable)
        .select('storage_path')
        .eq('measurement_profile_id', profileId);
    final imageUrls = <String>[];
    for (final row in imageRows) {
      final signedUrl = await createSignedUrl(bucket: _bucket, path: row['storage_path'] as String);
      imageUrls.add(signedUrl);
    }

    return profile.copyWith(values: values, imageUrls: imageUrls);
  });
}
