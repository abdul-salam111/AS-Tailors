import '../../../../../core/shared/shared_exports.dart';
import '../../../domain/entities/create_shop_params.dart';
import '../../../domain/usecases/create_shop_usecase.dart';
import 'create_shop_event.dart';
import 'create_shop_state.dart';

class CreateShopBloc extends Bloc<CreateShopEvent, CreateShopState> with UsecaseExecuterMixin {
  final CreateShopUsecase _createShopUsecase;

  CreateShopBloc({required CreateShopUsecase createShopUsecase})
    : _createShopUsecase = createShopUsecase,
      super(const CreateShopState()) {
    on<CreateShopSubmitted>(_onCreateShopSubmitted);
    on<ShopNameChangedEvent>((event, emit) => emit(state.copyWith(name: event.name)));
  }

  Future<void> _onCreateShopSubmitted(
    CreateShopSubmitted event,
    Emitter<CreateShopState> emit,
  ) async {
    await executeUsecase(
      emit: emit,
      currentState: state,
      usecase: () => _createShopUsecase(CreateShopParams(name: state.name)),
      stateBuilder: (status, {data, error, failure}) =>
          state.copyWith(apiStatus: status, shop: data, message: error, failure: failure),
    );
  }
}
