import '../../../../core/networks/exceptions/app_exceptions.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/shared/shared_exports.dart';
import '../../domain/entities/create_measurement_profile_params.dart';
import '../../domain/entities/garment_category_entity.dart';
import '../../domain/entities/measurement_profile_entity.dart';
import '../../domain/entities/measurement_template_entity.dart';
import '../../domain/entities/measurement_template_field_entity.dart';
import '../../domain/entities/measurement_template_field_option_entity.dart';
import '../../domain/repositories/measurement_repository.dart';
import '../datasources/measurement_remote_datasource/measurement_remote_datasource.dart';
import '../models/garment_category_model.dart';
import '../models/measurement_profile_model.dart';
import '../models/measurement_template_model.dart';

class MeasurementRepositoryImpl extends BaseRepository implements IMeasurementRepository {
  final IMeasurementRemoteDatasource _dataSource;
  final SessionController _sessionController;

  MeasurementRepositoryImpl({
    required IMeasurementRemoteDatasource dataSource,
    required SessionController sessionController,
  }) : _dataSource = dataSource,
       _sessionController = sessionController;

  /// Same pattern as `CustomerRepositoryImpl._requireShopId()` (§1a item 8).
  String _requireShopId() {
    final shopId = _sessionController.session.shopId;
    if (shopId == null) {
      throw const UnauthorizedException('No active shop for this account');
    }
    return shopId;
  }

  GarmentCategoryEntity _toCategoryEntity(GarmentCategoryModel model) =>
      GarmentCategoryEntity(id: model.id, name: model.name, nameUr: model.nameUr, slug: model.slug);

  MeasurementTemplateEntity _toTemplateEntity(MeasurementTemplateModel model) =>
      MeasurementTemplateEntity(
        id: model.id,
        categoryId: model.categoryId,
        name: model.name,
        version: model.version,
        fields: model.fields
            .map(
              (f) => MeasurementTemplateFieldEntity(
                id: f.id,
                fieldKey: f.fieldKey,
                labelEn: f.labelEn,
                labelUr: f.labelUr,
                sectionKey: f.sectionKey,
                sectionLabelEn: f.sectionLabelEn,
                sectionLabelUr: f.sectionLabelUr,
                displayOrder: f.displayOrder,
                isRequired: f.isRequired,
                inputType: f.inputType,
                defaultUnit: f.defaultUnit,
                options: f.options
                    .map(
                      (o) => MeasurementTemplateFieldOptionEntity(
                        id: o.id,
                        optionKey: o.optionKey,
                        labelEn: o.labelEn,
                        labelUr: o.labelUr,
                        displayOrder: o.displayOrder,
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
      );

  @override
  Future<Either<Failure, List<GarmentCategoryEntity>>> getGarmentCategories() => execute(
    call: () async => (await _dataSource.getGarmentCategories()).map(_toCategoryEntity).toList(),
  );

  @override
  Future<Either<Failure, MeasurementTemplateEntity>> getTemplateForCategory(String categoryId) =>
      execute(
        call: () async => _toTemplateEntity(await _dataSource.getTemplateForCategory(categoryId)),
      );

  @override
  Future<Either<Failure, MeasurementProfileEntity>> createMeasurementProfile(
    CreateMeasurementProfileParams params,
  ) => execute(
    call: () async {
      final shopId = _requireShopId();
      final model = await _dataSource.createMeasurementProfile(
        shopId: shopId,
        customerId: params.customerId,
        templateId: params.templateId,
        name: params.name,
        unit: params.unit,
        notes: params.notes,
        values: params.values,
      );

      for (final filePath in params.imageFilePaths) {
        await _dataSource.uploadReferenceImage(
          profileId: model.id,
          shopId: shopId,
          filePath: filePath,
        );
      }

      return model.toEntity();
    },
  );

  @override
  Future<Either<Failure, List<MeasurementProfileEntity>>> getProfilesForCustomer(
    String customerId,
  ) => execute(
    call: () async => (await _dataSource.getProfilesForCustomer(
      customerId,
    )).map((model) => model.toEntity()).toList(),
  );

  @override
  Future<Either<Failure, MeasurementProfileEntity>> getProfileDetail(String profileId) =>
      execute(call: () async => (await _dataSource.getProfileDetail(profileId)).toEntity());
}
