import '../../../../../core/shared/shared_exports.dart';
import '../../../domain/entities/create_customer_params.dart';
import '../../../domain/entities/update_customer_params.dart';
import '../../../domain/usecases/create_customer_usecase.dart';
import '../../../domain/usecases/update_customer_usecase.dart';
import 'customer_form_event.dart';
import 'customer_form_state.dart';

class CustomerFormBloc extends Bloc<CustomerFormEvent, CustomerFormState>
    with UsecaseExecuterMixin {
  final CreateCustomerUsecase _createCustomerUsecase;
  final UpdateCustomerUsecase _updateCustomerUsecase;

  CustomerFormBloc({
    required CreateCustomerUsecase createCustomerUsecase,
    required UpdateCustomerUsecase updateCustomerUsecase,
  }) : _createCustomerUsecase = createCustomerUsecase,
       _updateCustomerUsecase = updateCustomerUsecase,
       super(const CustomerFormState()) {
    on<CustomerFormInitialized>((event, emit) {
      final customer = event.customer;
      emit(
        state.copyWith(
          editingId: customer?.id,
          fullName: customer?.fullName ?? '',
          phone: customer?.phone ?? '',
          whatsapp: customer?.whatsapp ?? '',
          email: customer?.email ?? '',
          address: customer?.address ?? '',
          notes: customer?.notes ?? '',
        ),
      );
    });
    on<FullNameChangedEvent>((event, emit) => emit(state.copyWith(fullName: event.value)));
    on<PhoneChangedEvent>((event, emit) => emit(state.copyWith(phone: event.value)));
    on<WhatsappChangedEvent>((event, emit) => emit(state.copyWith(whatsapp: event.value)));
    on<EmailChangedEvent>((event, emit) => emit(state.copyWith(email: event.value)));
    on<AddressChangedEvent>((event, emit) => emit(state.copyWith(address: event.value)));
    on<NotesChangedEvent>((event, emit) => emit(state.copyWith(notes: event.value)));
    on<CustomerFormSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(CustomerFormSubmitted event, Emitter<CustomerFormState> emit) {
    return executeUsecase(
      emit: emit,
      currentState: state,
      usecase: () => state.isEditing
          ? _updateCustomerUsecase(
              UpdateCustomerParams(
                id: state.editingId!,
                fullName: state.fullName,
                phone: state.phone.isEmpty ? null : state.phone,
                whatsapp: state.whatsapp.isEmpty ? null : state.whatsapp,
                email: state.email.isEmpty ? null : state.email,
                address: state.address.isEmpty ? null : state.address,
                notes: state.notes.isEmpty ? null : state.notes,
              ),
            )
          : _createCustomerUsecase(
              CreateCustomerParams(
                fullName: state.fullName,
                phone: state.phone.isEmpty ? null : state.phone,
                whatsapp: state.whatsapp.isEmpty ? null : state.whatsapp,
                email: state.email.isEmpty ? null : state.email,
                address: state.address.isEmpty ? null : state.address,
                notes: state.notes.isEmpty ? null : state.notes,
              ),
            ),
      stateBuilder: (status, {data, error, failure}) =>
          state.copyWith(apiStatus: status, customer: data, message: error, failure: failure),
    );
  }
}
