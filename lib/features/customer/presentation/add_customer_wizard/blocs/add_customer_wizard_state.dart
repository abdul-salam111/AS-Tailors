import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../measurement/domain/entities/garment_category_entity.dart';
import '../../../../measurement/domain/entities/measurement_field_value.dart';
import '../../../../measurement/domain/entities/measurement_template_entity.dart';
import '../../../domain/entities/new_customer_order_result.dart';

/// All 4 steps' in-memory state — nothing here is persisted until
/// [WizardSubmitted] fires on the Summary step (see
/// `CreateCustomerWithOrderUsecase`).
class AddCustomerWizardState extends Equatable {
  final int currentStep;

  final List<GarmentCategoryEntity> categories;
  final ApiStatus categoriesStatus;
  final String unit;

  // Step 1 — customer
  final String fullName;
  final String whatsapp;
  final String address;
  final String customerNotes;

  // Step 2 — measurement
  final String? selectedCategoryId;
  final MeasurementTemplateEntity? template;
  final ApiStatus templateStatus;
  final Map<String, MeasurementFieldValue> fieldValues;
  final String measurementNotes;

  // Step 3 — order
  final int quantity;
  final double? unitPrice;
  final DateTime? dueDate;
  final String orderNotes;

  final ApiStatus submitStatus;
  final NewCustomerOrderResult? result;
  final Failure? failure;

  const AddCustomerWizardState({
    this.currentStep = 0,
    this.categories = const [],
    this.categoriesStatus = ApiStatus.INITIAL,
    this.unit = 'in',
    this.fullName = '',
    this.whatsapp = '',
    this.address = '',
    this.customerNotes = '',
    this.selectedCategoryId,
    this.template,
    this.templateStatus = ApiStatus.INITIAL,
    this.fieldValues = const {},
    this.measurementNotes = '',
    this.quantity = 1,
    this.unitPrice,
    this.dueDate,
    this.orderNotes = '',
    this.submitStatus = ApiStatus.INITIAL,
    this.result,
    this.failure,
  });

  double get lineTotal => quantity * (unitPrice ?? 0);

  String? selectedCategoryLabel(bool isUrdu) {
    for (final category in categories) {
      if (category.id == selectedCategoryId) {
        return isUrdu ? (category.nameUr ?? category.name) : category.name;
      }
    }
    return null;
  }

  AddCustomerWizardState copyWith({
    int? currentStep,
    List<GarmentCategoryEntity>? categories,
    ApiStatus? categoriesStatus,
    String? unit,
    String? fullName,
    String? whatsapp,
    String? address,
    String? customerNotes,
    String? selectedCategoryId,
    MeasurementTemplateEntity? template,
    ApiStatus? templateStatus,
    Map<String, MeasurementFieldValue>? fieldValues,
    String? measurementNotes,
    int? quantity,
    double? unitPrice,
    DateTime? dueDate,
    String? orderNotes,
    ApiStatus? submitStatus,
    NewCustomerOrderResult? result,
    Failure? failure,
  }) {
    return AddCustomerWizardState(
      currentStep: currentStep ?? this.currentStep,
      categories: categories ?? this.categories,
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      unit: unit ?? this.unit,
      fullName: fullName ?? this.fullName,
      whatsapp: whatsapp ?? this.whatsapp,
      address: address ?? this.address,
      customerNotes: customerNotes ?? this.customerNotes,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      template: template ?? this.template,
      templateStatus: templateStatus ?? this.templateStatus,
      fieldValues: fieldValues ?? this.fieldValues,
      measurementNotes: measurementNotes ?? this.measurementNotes,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      dueDate: dueDate ?? this.dueDate,
      orderNotes: orderNotes ?? this.orderNotes,
      submitStatus: submitStatus ?? this.submitStatus,
      result: result ?? this.result,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    categories,
    categoriesStatus,
    unit,
    fullName,
    whatsapp,
    address,
    customerNotes,
    selectedCategoryId,
    template,
    templateStatus,
    fieldValues,
    measurementNotes,
    quantity,
    unitPrice,
    dueDate,
    orderNotes,
    submitStatus,
    result,
    failure,
  ];
}
