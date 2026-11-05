import '../../../../core/shared/shared_exports.dart';
import '../entities/measurement_template_entity.dart';
import '../repositories/measurement_repository.dart';

class GetTemplateForCategoryUsecase implements Usecase<MeasurementTemplateEntity, String> {
  final IMeasurementRepository _repository;

  GetTemplateForCategoryUsecase({required IMeasurementRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, MeasurementTemplateEntity>> call(String categoryId) =>
      _repository.getTemplateForCategory(categoryId);
}
