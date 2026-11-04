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
  final ShopRole role;
  // True while CreateShopInitialized's "does a shop exist yet, and if so
  // auto-join it" sequence is still running — the view shows a loader
  // instead of the create-shop form until this settles.
  final bool isInitializing;
  // The auto-join attempt itself failed (shop existed, but
  // joinExistingShop errored) — distinct from "no shop exists yet", which
  // should show the create-shop form instead.
  final bool autoJoinFailed;

  const CreateShopState({
    this.shop,
    this.message,
    this.failure,
    this.apiStatus = ApiStatus.INITIAL,
    this.name = '',
    this.role = ShopRole.owner,
    this.isInitializing = true,
    this.autoJoinFailed = false,
  });

  CreateShopState copyWith({
    ShopEntity? shop,
    String? message,
    Failure? failure,
    ApiStatus? apiStatus,
    String? name,
    ShopRole? role,
    bool? isInitializing,
    bool? autoJoinFailed,
  }) {
    return CreateShopState(
      shop: shop ?? this.shop,
      message: message ?? this.message,
      failure: failure ?? this.failure,
      apiStatus: apiStatus ?? this.apiStatus,
      name: name ?? this.name,
      role: role ?? this.role,
      isInitializing: isInitializing ?? this.isInitializing,
      autoJoinFailed: autoJoinFailed ?? this.autoJoinFailed,
    );
  }

  @override
  List<Object?> get props => [
    shop,
    message,
    failure,
    apiStatus,
    name,
    role,
    isInitializing,
    autoJoinFailed,
  ];
}
