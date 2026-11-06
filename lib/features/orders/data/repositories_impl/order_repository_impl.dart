import '../../../../core/networks/exceptions/app_exceptions.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/shared/shared_exports.dart';
import '../../domain/entities/create_order_params.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource/order_remote_datasource.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl extends BaseRepository implements IOrderRepository {
  final IOrderRemoteDatasource _dataSource;
  final SessionController _sessionController;

  OrderRepositoryImpl({
    required IOrderRemoteDatasource dataSource,
    required SessionController sessionController,
  }) : _dataSource = dataSource,
       _sessionController = sessionController;

  String _requireShopId() {
    final shopId = _sessionController.session.shopId;
    if (shopId == null) {
      throw const UnauthorizedException('No active shop for this account');
    }
    return shopId;
  }

  OrderEntity _toEntity(OrderModel model) => OrderEntity(
    id: model.id,
    shopId: model.shopId,
    customerId: model.customerId,
    orderNumber: model.orderNumber,
    status: model.status,
    dueDate: model.dueDate,
    notes: model.notes,
    totalAmount: model.totalAmount,
    createdAt: model.createdAt,
  );

  @override
  Future<Either<Failure, OrderEntity>> createOrder(CreateOrderParams params) => execute(
    call: () async {
      final model = await _dataSource.createOrder(
        shopId: _requireShopId(),
        customerId: params.customerId,
        dueDate: params.dueDate,
        notes: params.notes,
        items: params.items
            .map(
              (item) => {
                'category_id': item.categoryId,
                'measurement_profile_id': item.measurementProfileId,
                'quantity': item.quantity,
                'unit_price': item.unitPrice,
                'notes': item.notes,
              },
            )
            .toList(),
      );
      return _toEntity(model);
    },
  );
}
