import 'package:equatable/equatable.dart';

/// One selectable option of a `dropdown`-type [MeasurementTemplateFieldEntity]
/// (e.g. a collar-type or stitching-type choice).
class MeasurementTemplateFieldOptionEntity extends Equatable {
  final String id;
  final String optionKey;
  final String labelEn;
  final String? labelUr;
  final int displayOrder;

  const MeasurementTemplateFieldOptionEntity({
    required this.id,
    required this.optionKey,
    required this.labelEn,
    this.labelUr,
    required this.displayOrder,
  });

  @override
  List<Object?> get props => [id, optionKey, labelEn, labelUr, displayOrder];
}
