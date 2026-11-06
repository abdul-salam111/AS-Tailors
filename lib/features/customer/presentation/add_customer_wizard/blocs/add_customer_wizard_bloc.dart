import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../measurement/domain/usecases/get_garment_categories_usecase.dart';
import '../../../../measurement/domain/usecases/get_template_for_category_usecase.dart';
import '../../../domain/entities/new_customer_order_params.dart';
import '../../../domain/usecases/create_customer_with_order_usecase.dart';
import 'add_customer_wizard_event.dart';
import 'add_customer_wizard_state.dart';

class AddCustomerWizardBloc extends Bloc<AddCustomerWizardEvent, AddCustomerWizardState> {
  final GetGarmentCategoriesUsecase _getGarmentCategoriesUsecase;
  final GetTemplateForCategoryUsecase _getTemplateForCategoryUsecase;
  final CreateCustomerWithOrderUsecase _createCustomerWithOrderUsecase;

  AddCustomerWizardBloc({
    required GetGarmentCategoriesUsecase getGarmentCategoriesUsecase,
    required GetTemplateForCategoryUsecase getTemplateForCategoryUsecase,
    required CreateCustomerWithOrderUsecase createCustomerWithOrderUsecase,
  }) : _getGarmentCategoriesUsecase = getGarmentCategoriesUsecase,
       _getTemplateForCategoryUsecase = getTemplateForCategoryUsecase,
       _createCustomerWithOrderUsecase = createCustomerWithOrderUsecase,
       super(const AddCustomerWizardState()) {
    on<WizardInitialized>(_onInitialized);
    on<WizardStepChanged>((event, emit) => emit(state.copyWith(currentStep: event.step)));
    on<WizardNextPressed>(
      (event, emit) => emit(state.copyWith(currentStep: state.currentStep + 1)),
    );
    on<WizardBackPressed>(
      (event, emit) => emit(state.copyWith(currentStep: state.currentStep - 1)),
    );
    on<CustomerFullNameChanged>((event, emit) => emit(state.copyWith(fullName: event.value)));
    on<CustomerWhatsappChanged>((event, emit) => emit(state.copyWith(whatsapp: event.value)));
    on<CustomerAddressChanged>((event, emit) => emit(state.copyWith(address: event.value)));
    on<CustomerNotesChanged>((event, emit) => emit(state.copyWith(customerNotes: event.value)));
    on<WizardCategorySelected>(_onCategorySelected);
    on<WizardFieldValueChanged>(
      (event, emit) =>
          emit(state.copyWith(fieldValues: {...state.fieldValues, event.fieldId: event.value})),
    );
    on<MeasurementNotesChanged>(
      (event, emit) => emit(state.copyWith(measurementNotes: event.value)),
    );
    on<OrderQuantityChanged>((event, emit) => emit(state.copyWith(quantity: event.value)));
    on<OrderUnitPriceChanged>((event, emit) => emit(state.copyWith(unitPrice: event.value)));
    on<OrderDueDateChanged>((event, emit) => emit(state.copyWith(dueDate: event.value)));
    on<OrderNotesChanged>((event, emit) => emit(state.copyWith(orderNotes: event.value)));
    on<WizardSubmitted>(_onSubmitted);
  }

  Future<void> _onInitialized(WizardInitialized event, Emitter<AddCustomerWizardState> emit) async {
    emit(state.copyWith(unit: event.initialUnit, categoriesStatus: ApiStatus.LOADING));
    final result = await _getGarmentCategoriesUsecase(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(categoriesStatus: ApiStatus.FAILURE, failure: failure)),
      (categories) =>
          emit(state.copyWith(categoriesStatus: ApiStatus.SUCCESS, categories: categories)),
    );
  }

  Future<void> _onCategorySelected(
    WizardCategorySelected event,
    Emitter<AddCustomerWizardState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedCategoryId: event.categoryId,
        templateStatus: ApiStatus.LOADING,
        fieldValues: {},
      ),
    );
    final result = await _getTemplateForCategoryUsecase(event.categoryId);
    result.fold(
      (failure) => emit(state.copyWith(templateStatus: ApiStatus.FAILURE, failure: failure)),
      (template) => emit(state.copyWith(templateStatus: ApiStatus.SUCCESS, template: template)),
    );
  }

  Future<void> _onSubmitted(WizardSubmitted event, Emitter<AddCustomerWizardState> emit) async {
    final template = state.template;
    final unitPrice = state.unitPrice;
    if (template == null || unitPrice == null) return;

    emit(state.copyWith(submitStatus: ApiStatus.LOADING));
    final result = await _createCustomerWithOrderUsecase(
      NewCustomerOrderParams(
        fullName: state.fullName,
        whatsapp: state.whatsapp.isEmpty ? null : state.whatsapp,
        address: state.address.isEmpty ? null : state.address,
        customerNotes: state.customerNotes.isEmpty ? null : state.customerNotes,
        templateId: template.id,
        unit: state.unit,
        measurementNotes: state.measurementNotes.isEmpty ? null : state.measurementNotes,
        measurementValues: state.fieldValues,
        quantity: state.quantity,
        unitPrice: unitPrice,
        dueDate: state.dueDate,
        orderNotes: state.orderNotes.isEmpty ? null : state.orderNotes,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(submitStatus: ApiStatus.FAILURE, failure: failure)),
      (result) => emit(state.copyWith(submitStatus: ApiStatus.SUCCESS, result: result)),
    );
  }
}
