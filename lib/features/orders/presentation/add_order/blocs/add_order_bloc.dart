import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../measurement/domain/usecases/get_garment_categories_usecase.dart';
import '../../../domain/entities/create_order_params.dart';
import '../../../domain/usecases/create_order_usecase.dart';
import 'add_order_event.dart';
import 'add_order_state.dart';

class AddOrderBloc extends Bloc<AddOrderEvent, AddOrderState> {
  final GetGarmentCategoriesUsecase _getGarmentCategoriesUsecase;
  final CreateOrderUsecase _createOrderUsecase;

  AddOrderBloc({
    required GetGarmentCategoriesUsecase getGarmentCategoriesUsecase,
    required CreateOrderUsecase createOrderUsecase,
  }) : _getGarmentCategoriesUsecase = getGarmentCategoriesUsecase,
       _createOrderUsecase = createOrderUsecase,
       super(const AddOrderState()) {
    on<AddOrderInitialized>(_onInitialized);
    on<OrderCustomerSelected>((event, emit) => emit(state.copyWith(customer: event.customer)));
    on<OrderDueDateChanged>((event, emit) => emit(state.copyWith(dueDate: event.dueDate)));
    on<OrderNotesChanged>((event, emit) => emit(state.copyWith(notes: event.value)));
    on<OrderItemAdded>((event, emit) => emit(state.copyWith(items: [...state.items, event.item])));
    on<OrderItemRemoved>(
      (event, emit) => emit(state.copyWith(items: [...state.items]..removeAt(event.index))),
    );
    on<AddOrderSubmitted>(_onSubmitted);
  }

  Future<void> _onInitialized(AddOrderInitialized event, Emitter<AddOrderState> emit) async {
    emit(state.copyWith(customer: event.initialCustomer, categoriesStatus: ApiStatus.LOADING));
    final result = await _getGarmentCategoriesUsecase(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(categoriesStatus: ApiStatus.FAILURE, failure: failure)),
      (categories) =>
          emit(state.copyWith(categoriesStatus: ApiStatus.SUCCESS, categories: categories)),
    );
  }

  Future<void> _onSubmitted(AddOrderSubmitted event, Emitter<AddOrderState> emit) async {
    final customer = state.customer;
    if (customer == null || state.items.isEmpty) return;

    emit(state.copyWith(submitStatus: ApiStatus.LOADING));
    final result = await _createOrderUsecase(
      CreateOrderParams(
        customerId: customer.id,
        dueDate: state.dueDate,
        notes: state.notes.isEmpty ? null : state.notes,
        items: state.items
            .map(
              (item) => CreateOrderItemParams(
                categoryId: item.categoryId,
                measurementProfileId: item.measurementProfileId,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                notes: item.notes,
              ),
            )
            .toList(),
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(submitStatus: ApiStatus.FAILURE, failure: failure)),
      (order) => emit(state.copyWith(submitStatus: ApiStatus.SUCCESS, createdOrder: order)),
    );
  }
}
