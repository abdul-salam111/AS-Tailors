import '../../../../core/shared/shared_exports.dart';
import '../entities/create_order_params.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CreateOrderUsecase implements Usecase<OrderEntity, CreateOrderParams> {
  final IOrderRepository _repository;

  CreateOrderUsecase({required IOrderRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, OrderEntity>> call(CreateOrderParams params) =>
      _repository.createOrder(params);
}
