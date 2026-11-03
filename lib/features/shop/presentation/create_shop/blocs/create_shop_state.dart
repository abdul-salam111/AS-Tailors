import 'package:equatable/equatable.dart';
import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/shared/domain/failures/failure.dart';
import '../../../domain/entities/shop_entity.dart';

class CreateShopState extends Equatable {
  final ShopEntity? shop;
  final String? message;
  final Failure? failure;
  final ApiStatus apiStatus;
  final String name;

  const CreateShopState({
    this.shop,
    this.message,
    this.failure,
    this.apiStatus = ApiStatus.INITIAL,
    this.name = '',
  });

  CreateShopState copyWith({
    ShopEntity? shop,
    String? message,
    Failure? failure,
    ApiStatus? apiStatus,
    String? name,
  }) {
    return CreateShopState(
      shop: shop ?? this.shop,
      message: message ?? this.message,
      failure: failure ?? this.failure,
      apiStatus: apiStatus ?? this.apiStatus,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [shop, message, failure, apiStatus, name];
}
