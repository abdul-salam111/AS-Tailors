import '../../../../core/shared/shared_exports.dart';
import '../entities/garment_category_entity.dart';
import '../repositories/measurement_repository.dart';

class GetGarmentCategoriesUsecase implements Usecase<List<GarmentCategoryEntity>, NoParams> {
  final IMeasurementRepository _repository;

  GetGarmentCategoriesUsecase({required IMeasurementRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<GarmentCategoryEntity>>> call(NoParams params) =>
      _repository.getGarmentCategories();
}
