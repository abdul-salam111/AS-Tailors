import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_enums.dart';

/// The signed-in user's identity plus their resolved shop membership.
/// [shopId]/[role] are null until the user has completed shop onboarding
/// (see the `shop` feature's `CreateShopUsecase`) — a freshly signed-up
/// user is valid but has no shop yet.
class AuthEntity extends Equatable {
  final String userId;
  final String email;
  final String? fullName;
  final String? shopId;
  final ShopRole? role;

  const AuthEntity({
    required this.userId,
    required this.email,
    this.fullName,
    this.shopId,
    this.role,
  });

  bool get hasShop => shopId != null;

  @override
  List<Object?> get props => [userId, email, fullName, shopId, role];
}
