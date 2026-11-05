import 'package:equatable/equatable.dart';

/// What the user entered for one template field, shaped by that field's
/// `inputType`:
/// - `number`/`counter` → [numericValue] (+ [unit] for `number` only)
/// - `checkbox` → [numericValue] of `0`/`1`
/// - `dropdown` → [selectedOptionId]
///
/// Built by `MeasurementFormBloc` as the user fills in each field, so the
/// repository/datasource never need to know a field's `inputType` to
/// serialize it correctly.
class MeasurementFieldValue extends Equatable {
  final double? numericValue;
  final String? unit;
  final String? selectedOptionId;

  const MeasurementFieldValue({this.numericValue, this.unit, this.selectedOptionId});

  @override
  List<Object?> get props => [numericValue, unit, selectedOptionId];
}
