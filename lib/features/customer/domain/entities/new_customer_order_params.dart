import 'package:equatable/equatable.dart';
import '../../../measurement/domain/entities/measurement_field_value.dart';

/// Everything collected across `AddCustomerWizardView`'s 4 steps, sent in
/// one shot to `createCustomerWithOrder` only when the final Summary step
/// is confirmed — nothing is created until then (`create_customer_with_
/// order()`, `0010_create_customer_with_order.sql`, is one transaction).
class NewCustomerOrderParams extends Equatable {
  // Step 1 — customer
  final String fullName;
  final String? whatsapp;
  final String? address;
  final String? customerNotes;

  // Step 2 — measurement (one garment category/template for this wizard)
  final String templateId;
  final String? measurementName;
  final String unit;
  final String? measurementNotes;
  final Map<String, MeasurementFieldValue> measurementValues;

  // Step 3 — order (a single line item for the category above)
  final int quantity;
  final double unitPrice;
  final DateTime? dueDate;
  final String? orderNotes;
  final String? itemNotes;

  const NewCustomerOrderParams({
    required this.fullName,
    this.whatsapp,
    this.address,
    this.customerNotes,
    required this.templateId,
    this.measurementName,
    required this.unit,
    this.measurementNotes,
    required this.measurementValues,
    required this.quantity,
    required this.unitPrice,
    this.dueDate,
    this.orderNotes,
    this.itemNotes,
  });

  @override
  List<Object?> get props => [
    fullName,
    whatsapp,
    address,
    customerNotes,
    templateId,
    measurementName,
    unit,
    measurementNotes,
    measurementValues,
    quantity,
    unitPrice,
    dueDate,
    orderNotes,
    itemNotes,
  ];
}
