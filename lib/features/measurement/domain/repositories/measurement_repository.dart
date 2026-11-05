import '../../../../core/shared/shared_exports.dart';
import '../entities/create_measurement_profile_params.dart';
import '../entities/garment_category_entity.dart';
import '../entities/measurement_profile_entity.dart';
import '../entities/measurement_template_entity.dart';

abstract interface class IMeasurementRepository {
  Future<Either<Failure, List<GarmentCategoryEntity>>> getGarmentCategories();

  Future<Either<Failure, MeasurementTemplateEntity>> getTemplateForCategory(String categoryId);

  Future<Either<Failure, MeasurementProfileEntity>> createMeasurementProfile(
    CreateMeasurementProfileParams params,
  );

  /// Summary rows only (no values/images) — for a customer's measurements list.
  Future<Either<Failure, List<MeasurementProfileEntity>>> getProfilesForCustomer(String customerId);

  /// Full detail (values + resolved image URLs) — for the preview sheet.
  Future<Either<Failure, MeasurementProfileEntity>> getProfileDetail(String profileId);
}
