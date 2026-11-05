import '../../../../core/shared/shared_exports.dart';
import '../entities/create_measurement_profile_params.dart';
import '../entities/measurement_profile_entity.dart';
import '../repositories/measurement_repository.dart';

class CreateMeasurementProfileUsecase
    implements Usecase<MeasurementProfileEntity, CreateMeasurementProfileParams> {
  final IMeasurementRepository _repository;

  CreateMeasurementProfileUsecase({required IMeasurementRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, MeasurementProfileEntity>> call(CreateMeasurementProfileParams params) =>
      _repository.createMeasurementProfile(params);
}
