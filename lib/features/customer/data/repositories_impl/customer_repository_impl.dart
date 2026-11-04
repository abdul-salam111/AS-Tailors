import '../../../../core/networks/exceptions/app_exceptions.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/shared/shared_exports.dart';
import '../../domain/entities/create_customer_params.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/get_customers_params.dart';
import '../../domain/entities/update_customer_params.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource/customer_remote_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl extends BaseRepository implements ICustomerRepository {
  final ICustomerRemoteDatasource _dataSource;
  final SessionController _sessionController;

  CustomerRepositoryImpl({
    required ICustomerRemoteDatasource dataSource,
    required SessionController sessionController,
  }) : _dataSource = dataSource,
       _sessionController = sessionController;

  /// Every query here is shop-scoped (SRS §1a item 8) — reading the shop id
  /// here, once, means every repository method gets that scoping for free
  /// instead of each call site having to remember to pass it.
  String _requireShopId() {
    final shopId = _sessionController.session.shopId;
    if (shopId == null) {
      throw const UnauthorizedException('No active shop for this account');
    }
    return shopId;
  }

  CustomerEntity _toEntity(CustomerModel model) => CustomerEntity(
    id: model.id,
    shopId: model.shopId,
    profileId: model.profileId,
    fullName: model.fullName,
    phone: model.phone,
    whatsapp: model.whatsapp,
    email: model.email,
    address: model.address,
    notes: model.notes,
    isActive: model.isActive,
    createdAt: model.createdAt,
    updatedAt: model.updatedAt,
  );

  @override
  Future<Either<Failure, CustomerEntity>> createCustomer(CreateCustomerParams params) => execute(
    call: () async {
      final model = await _dataSource.createCustomer(
        shopId: _requireShopId(),
        fullName: params.fullName,
        phone: params.phone,
        whatsapp: params.whatsapp,
        email: params.email,
        address: params.address,
        notes: params.notes,
      );
      return _toEntity(model);
    },
  );

  @override
  Future<Either<Failure, List<CustomerEntity>>> getCustomers(GetCustomersParams params) => execute(
    call: () async {
      final models = await _dataSource.getCustomers(
        shopId: _requireShopId(),
        page: params.page,
        limit: params.limit,
        search: params.search,
      );
      return models.map(_toEntity).toList();
    },
  );

  @override
  Future<Either<Failure, CustomerEntity>> getCustomerById(String id) =>
      execute(call: () async => _toEntity(await _dataSource.getCustomerById(id)));

  @override
  Future<Either<Failure, CustomerEntity>> updateCustomer(UpdateCustomerParams params) => execute(
    call: () async => _toEntity(
      await _dataSource.updateCustomer(
        id: params.id,
        fullName: params.fullName,
        phone: params.phone,
        whatsapp: params.whatsapp,
        email: params.email,
        address: params.address,
        notes: params.notes,
      ),
    ),
  );

  @override
  Future<Either<Failure, CustomerEntity>> archiveCustomer(String id) =>
      execute(call: () async => _toEntity(await _dataSource.archiveCustomer(id)));

  @override
  Future<Either<Failure, int>> getCustomerCount({DateTime? since}) => execute(
    call: () => _dataSource.getCustomerCount(shopId: _requireShopId(), since: since),
  );
}
