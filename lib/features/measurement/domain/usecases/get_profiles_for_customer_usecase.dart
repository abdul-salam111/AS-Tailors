import '../../../../core/shared/shared_exports.dart';
import '../entities/measurement_profile_entity.dart';
import '../repositories/measurement_repository.dart';

class GetProfilesForCustomerUsecase implements Usecase<List<MeasurementProfileEntity>, String> {
  final IMeasurementRepository _repository;

  GetProfilesForCustomerUsecase({required IMeasurementRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<MeasurementProfileEntity>>> call(String customerId) =>
      _repository.getProfilesForCustomer(customerId);
}
