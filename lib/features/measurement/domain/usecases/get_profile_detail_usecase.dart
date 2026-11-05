import '../../../../core/shared/shared_exports.dart';
import '../entities/measurement_profile_entity.dart';
import '../repositories/measurement_repository.dart';

class GetProfileDetailUsecase implements Usecase<MeasurementProfileEntity, String> {
  final IMeasurementRepository _repository;

  GetProfileDetailUsecase({required IMeasurementRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, MeasurementProfileEntity>> call(String profileId) =>
      _repository.getProfileDetail(profileId);
}
