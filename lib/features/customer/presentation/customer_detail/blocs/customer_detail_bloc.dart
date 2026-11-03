import '../../../../../core/shared/shared_exports.dart';
import '../../../domain/usecases/archive_customer_usecase.dart';
import '../../../domain/usecases/get_customer_by_id_usecase.dart';
import 'customer_detail_event.dart';
import 'customer_detail_state.dart';

class CustomerDetailBloc extends Bloc<CustomerDetailEvent, CustomerDetailState>
    with UsecaseExecuterMixin {
  final GetCustomerByIdUsecase _getCustomerByIdUsecase;
  final ArchiveCustomerUsecase _archiveCustomerUsecase;

  CustomerDetailBloc({
    required GetCustomerByIdUsecase getCustomerByIdUsecase,
    required ArchiveCustomerUsecase archiveCustomerUsecase,
  }) : _getCustomerByIdUsecase = getCustomerByIdUsecase,
       _archiveCustomerUsecase = archiveCustomerUsecase,
       super(const CustomerDetailState()) {
    on<LoadCustomerEvent>(_onLoad);
    on<ArchiveCustomerRequested>(_onArchive);
  }

  Future<void> _onLoad(LoadCustomerEvent event, Emitter<CustomerDetailState> emit) {
    return executeUsecase(
      emit: emit,
      currentState: state,
      usecase: () => _getCustomerByIdUsecase(event.id),
      stateBuilder: (status, {data, error, failure}) =>
          state.copyWith(apiStatus: status, customer: data, message: error, failure: failure),
    );
  }

  /// Handled by hand rather than [executeUsecase] — that mixin always
  /// drives [CustomerDetailState.apiStatus], which would flip the whole
  /// screen back to a loading spinner while archiving. [isArchiving]
  /// tracks this action on its own so the already-loaded customer stays
  /// visible underneath.
  Future<void> _onArchive(ArchiveCustomerRequested event, Emitter<CustomerDetailState> emit) async {
    emit(state.copyWith(isArchiving: true));
    final result = await _archiveCustomerUsecase(event.id);
    result.fold(
      (failure) => emit(
        CustomerDetailState(
          apiStatus: state.apiStatus,
          customer: state.customer,
          failure: failure,
          message: failure.message,
        ),
      ),
      (customer) => emit(CustomerDetailState(apiStatus: state.apiStatus, customer: customer)),
    );
  }
}
