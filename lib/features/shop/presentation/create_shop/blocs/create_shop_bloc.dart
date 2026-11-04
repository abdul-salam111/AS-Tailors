import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../domain/entities/create_shop_params.dart';
import '../../../domain/usecases/check_shop_exists_usecase.dart';
import '../../../domain/usecases/create_shop_usecase.dart';
import '../../../domain/usecases/join_existing_shop_usecase.dart';
import 'create_shop_event.dart';
import 'create_shop_state.dart';

class CreateShopBloc extends Bloc<CreateShopEvent, CreateShopState> with UsecaseExecuterMixin {
  final CreateShopUsecase _createShopUsecase;
  final CheckShopExistsUsecase _checkShopExistsUsecase;
  final JoinExistingShopUsecase _joinExistingShopUsecase;

  CreateShopBloc({
    required CreateShopUsecase createShopUsecase,
    required CheckShopExistsUsecase checkShopExistsUsecase,
    required JoinExistingShopUsecase joinExistingShopUsecase,
  }) : _createShopUsecase = createShopUsecase,
       _checkShopExistsUsecase = checkShopExistsUsecase,
       _joinExistingShopUsecase = joinExistingShopUsecase,
       super(const CreateShopState()) {
    on<CreateShopInitialized>(_onInitialized);
    on<CreateShopSubmitted>(_onCreateShopSubmitted);
    on<ShopNameChangedEvent>((event, emit) => emit(state.copyWith(name: event.name)));
  }

  // Single-shop deployment (SRS §1.4): the first account bootstraps the
  // shop via the form below, every account after that auto-joins as
  // staff instead of being shown a "name your shop" form for a shop that
  // already has a name.
  Future<void> _onInitialized(CreateShopInitialized event, Emitter<CreateShopState> emit) async {
    final existsResult = await _checkShopExistsUsecase(NoParams());
    final shopAlreadyExists = existsResult.fold((_) => false, (exists) => exists);

    if (!shopAlreadyExists) {
      emit(state.copyWith(isInitializing: false));
      return;
    }

    final joinResult = await _joinExistingShopUsecase(NoParams());
    joinResult.fold(
      (failure) =>
          emit(state.copyWith(isInitializing: false, autoJoinFailed: true, failure: failure)),
      (shop) => emit(
        state.copyWith(
          isInitializing: false,
          apiStatus: ApiStatus.SUCCESS,
          shop: shop,
          role: ShopRole.staff,
        ),
      ),
    );
  }

  Future<void> _onCreateShopSubmitted(
    CreateShopSubmitted event,
    Emitter<CreateShopState> emit,
  ) async {
    await executeUsecase(
      emit: emit,
      currentState: state,
      usecase: () => _createShopUsecase(CreateShopParams(name: state.name)),
      stateBuilder: (status, {data, error, failure}) => state.copyWith(
        apiStatus: status,
        shop: data,
        message: error,
        failure: failure,
        role: ShopRole.owner,
      ),
    );
  }
}
