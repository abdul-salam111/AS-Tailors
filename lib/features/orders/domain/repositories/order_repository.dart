import '../../../../core/shared/shared_exports.dart';
import '../entities/create_order_params.dart';
import '../entities/order_entity.dart';

abstract interface class IOrderRepository {
  Future<Either<Failure, OrderEntity>> createOrder(CreateOrderParams params);
}
