import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_enums.dart';
import 'measurement_template_field_option_entity.dart';

/// One field of a measurement template (SRS §23.5) — `fieldKey` is the
/// stable machine identifier; `labelEn`/`labelUr` are display-only and can
/// change without affecting historical `measurement_values` rows, which
/// reference this field by id.
///
/// `sectionKey` groups fields into a sub-picker within one template (e.g.
/// the Shalwar Kameez template's "Qameez" vs "Shalwar" halves) — null for
/// templates that render as one flat list.
class MeasurementTemplateFieldEntity extends Equatable {
  final String id;
  final String fieldKey;
  final String labelEn;
  final String? labelUr;
  final String? sectionKey;
  final String? sectionLabelEn;
  final String? sectionLabelUr;
  final int displayOrder;
  final bool isRequired;
  final MeasurementFieldInputType inputType;
  final String defaultUnit;

  /// Populated only when [inputType] is [MeasurementFieldInputType.dropdown].
  final List<MeasurementTemplateFieldOptionEntity> options;

  const MeasurementTemplateFieldEntity({
    required this.id,
    required this.fieldKey,
    required this.labelEn,
    this.labelUr,
    this.sectionKey,
    this.sectionLabelEn,
    this.sectionLabelUr,
    required this.displayOrder,
    required this.isRequired,
    required this.inputType,
    required this.defaultUnit,
    this.options = const [],
  });

  @override
  List<Object?> get props => [
    id,
    fieldKey,
    labelEn,
    labelUr,
    sectionKey,
    sectionLabelEn,
    sectionLabelUr,
    displayOrder,
    isRequired,
    inputType,
    defaultUnit,
    options,
  ];
}
