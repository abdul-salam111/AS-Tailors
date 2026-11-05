import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../domain/entities/garment_category_entity.dart';
import '../../../domain/entities/measurement_field_value.dart';
import '../../../domain/entities/measurement_profile_entity.dart';
import '../../../domain/entities/measurement_template_entity.dart';

class MeasurementFormState extends Equatable {
  final String? customerId;
  final List<GarmentCategoryEntity> categories;
  final ApiStatus categoriesStatus;
  final String? selectedCategoryId;
  final MeasurementTemplateEntity? template;
  final ApiStatus templateStatus;

  /// Which of the template's sub-sections (e.g. "Qameez" vs "Shalwar") is
  /// currently shown — null when the template has no sections (a flat
  /// field list, e.g. the `shirt` template).
  final String? selectedSectionKey;

  final Map<String, MeasurementFieldValue> fieldValues;
  final String unit;
  final String notes;
  final List<String> imagePaths;
  final ApiStatus submitStatus;
  final MeasurementProfileEntity? savedProfile;
  final Failure? failure;

  const MeasurementFormState({
    this.customerId,
    this.categories = const [],
    this.categoriesStatus = ApiStatus.INITIAL,
    this.selectedCategoryId,
    this.template,
    this.templateStatus = ApiStatus.INITIAL,
    this.selectedSectionKey,
    this.fieldValues = const {},
    this.unit = 'in',
    this.notes = '',
    this.imagePaths = const [],
    this.submitStatus = ApiStatus.INITIAL,
    this.savedProfile,
    this.failure,
  });

  /// Distinct section keys across the template's fields, in field order —
  /// empty when the template is a flat list.
  List<String> get sectionKeys {
    final seen = <String>{};
    final keys = <String>[];
    for (final field in template?.fields ?? const []) {
      final key = field.sectionKey;
      if (key != null && seen.add(key)) keys.add(key);
    }
    return keys;
  }

  MeasurementFormState copyWith({
    String? customerId,
    List<GarmentCategoryEntity>? categories,
    ApiStatus? categoriesStatus,
    String? selectedCategoryId,
    MeasurementTemplateEntity? template,
    ApiStatus? templateStatus,
    String? selectedSectionKey,
    Map<String, MeasurementFieldValue>? fieldValues,
    String? unit,
    String? notes,
    List<String>? imagePaths,
    ApiStatus? submitStatus,
    MeasurementProfileEntity? savedProfile,
    Failure? failure,
  }) {
    return MeasurementFormState(
      customerId: customerId ?? this.customerId,
      categories: categories ?? this.categories,
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      template: template ?? this.template,
      templateStatus: templateStatus ?? this.templateStatus,
      selectedSectionKey: selectedSectionKey ?? this.selectedSectionKey,
      fieldValues: fieldValues ?? this.fieldValues,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      imagePaths: imagePaths ?? this.imagePaths,
      submitStatus: submitStatus ?? this.submitStatus,
      savedProfile: savedProfile ?? this.savedProfile,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    customerId,
    categories,
    categoriesStatus,
    selectedCategoryId,
    template,
    templateStatus,
    selectedSectionKey,
    fieldValues,
    unit,
    notes,
    imagePaths,
    submitStatus,
    savedProfile,
    failure,
  ];
}
