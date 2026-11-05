import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../domain/entities/create_measurement_profile_params.dart';
import '../../../domain/usecases/create_measurement_profile_usecase.dart';
import '../../../domain/usecases/get_garment_categories_usecase.dart';
import '../../../domain/usecases/get_template_for_category_usecase.dart';
import 'measurement_form_event.dart';
import 'measurement_form_state.dart';

class MeasurementFormBloc extends Bloc<MeasurementFormEvent, MeasurementFormState> {
  final GetGarmentCategoriesUsecase _getGarmentCategoriesUsecase;
  final GetTemplateForCategoryUsecase _getTemplateForCategoryUsecase;
  final CreateMeasurementProfileUsecase _createMeasurementProfileUsecase;

  MeasurementFormBloc({
    required GetGarmentCategoriesUsecase getGarmentCategoriesUsecase,
    required GetTemplateForCategoryUsecase getTemplateForCategoryUsecase,
    required CreateMeasurementProfileUsecase createMeasurementProfileUsecase,
  }) : _getGarmentCategoriesUsecase = getGarmentCategoriesUsecase,
       _getTemplateForCategoryUsecase = getTemplateForCategoryUsecase,
       _createMeasurementProfileUsecase = createMeasurementProfileUsecase,
       super(const MeasurementFormState()) {
    on<MeasurementFormInitialized>(_onInitialized);
    on<CategorySelectedEvent>(_onCategorySelected);
    on<SectionSelectedEvent>(
      (event, emit) => emit(state.copyWith(selectedSectionKey: event.sectionKey)),
    );
    on<FieldValueChangedEvent>(
      (event, emit) =>
          emit(state.copyWith(fieldValues: {...state.fieldValues, event.fieldId: event.value})),
    );
    on<UnitChangedEvent>((event, emit) => emit(state.copyWith(unit: event.unit)));
    on<MeasurementNotesChangedEvent>((event, emit) => emit(state.copyWith(notes: event.value)));
    on<ImageAddedEvent>(
      (event, emit) => emit(state.copyWith(imagePaths: [...state.imagePaths, event.filePath])),
    );
    on<ImageRemovedEvent>(
      (event, emit) => emit(
        state.copyWith(imagePaths: state.imagePaths.where((p) => p != event.filePath).toList()),
      ),
    );
    on<MeasurementFormSubmitted>(_onSubmitted);
  }

  Future<void> _onInitialized(
    MeasurementFormInitialized event,
    Emitter<MeasurementFormState> emit,
  ) async {
    emit(state.copyWith(customerId: event.customerId, categoriesStatus: ApiStatus.LOADING));
    final result = await _getGarmentCategoriesUsecase(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(categoriesStatus: ApiStatus.FAILURE, failure: failure)),
      (categories) =>
          emit(state.copyWith(categoriesStatus: ApiStatus.SUCCESS, categories: categories)),
    );
  }

  Future<void> _onCategorySelected(
    CategorySelectedEvent event,
    Emitter<MeasurementFormState> emit,
  ) async {
    emit(state.copyWith(selectedCategoryId: event.categoryId, templateStatus: ApiStatus.LOADING));
    final result = await _getTemplateForCategoryUsecase(event.categoryId);
    result.fold(
      (failure) => emit(state.copyWith(templateStatus: ApiStatus.FAILURE, failure: failure)),
      (template) {
        final sectionKeys = <String>{};
        for (final field in template.fields) {
          if (field.sectionKey != null) sectionKeys.add(field.sectionKey!);
        }
        emit(
          state.copyWith(
            templateStatus: ApiStatus.SUCCESS,
            template: template,
            fieldValues: {},
            selectedSectionKey: sectionKeys.isNotEmpty ? sectionKeys.first : null,
          ),
        );
      },
    );
  }

  Future<void> _onSubmitted(
    MeasurementFormSubmitted event,
    Emitter<MeasurementFormState> emit,
  ) async {
    final template = state.template;
    final customerId = state.customerId;
    if (template == null || customerId == null) return;

    emit(state.copyWith(submitStatus: ApiStatus.LOADING));

    final result = await _createMeasurementProfileUsecase(
      CreateMeasurementProfileParams(
        customerId: customerId,
        templateId: template.id,
        unit: state.unit,
        notes: state.notes.isEmpty ? null : state.notes,
        values: state.fieldValues,
        imageFilePaths: state.imagePaths,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(submitStatus: ApiStatus.FAILURE, failure: failure)),
      (profile) => emit(state.copyWith(submitStatus: ApiStatus.SUCCESS, savedProfile: profile)),
    );
  }
}
