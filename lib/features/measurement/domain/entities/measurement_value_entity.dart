import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_enums.dart';

/// One recorded value within a measurement profile, with its field's label
/// denormalized on by the repository for display convenience — this shape
/// is assembled from a join at read time, not stored this way.
///
/// [inputType] tells the UI how to render it: `number`/`counter` use
/// [value]+[unit] (unit only meaningful for `number`); `checkbox` uses
/// [value] as `0`/`1`; `dropdown` uses [selectedOptionLabelEn]/`Ur` instead.
class MeasurementValueEntity extends Equatable {
  final String fieldId;
  final String fieldKey;
  final String labelEn;
  final String? labelUr;
  final MeasurementFieldInputType inputType;
  final double? value;
  final String? unit;
  final String? selectedOptionLabelEn;
  final String? selectedOptionLabelUr;

  const MeasurementValueEntity({
    required this.fieldId,
    required this.fieldKey,
    required this.labelEn,
    this.labelUr,
    required this.inputType,
    this.value,
    this.unit,
    this.selectedOptionLabelEn,
    this.selectedOptionLabelUr,
  });

  @override
  List<Object?> get props => [
    fieldId,
    fieldKey,
    labelEn,
    labelUr,
    inputType,
    value,
    unit,
    selectedOptionLabelEn,
    selectedOptionLabelUr,
  ];
}
