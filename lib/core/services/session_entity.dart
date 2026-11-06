import 'package:equatable/equatable.dart';
import '../constants/app_enums.dart';

/// The app's resolved identity for the current request/session: who is
/// signed in, and — once resolved — which shop they belong to and in what
/// role. [shopId]/[role] are null until shop membership has been looked
/// up (see `ISessionResolver`), which is why `hasShop` is a separate check
/// from `isValid`.
class SessionEntity extends Equatable {
  final String userId;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? shopId;
  final ShopRole? role;

  const SessionEntity({
    required this.userId,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.shopId,
    this.role,
  });

  static const empty = SessionEntity(userId: '', email: '');

  bool get isValid => userId.isNotEmpty;
  bool get hasShop => shopId != null;

  SessionEntity copyWith({
    String? userId,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? shopId,
    ShopRole? role,
  }) {
    return SessionEntity(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      shopId: shopId ?? this.shopId,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [userId, email, fullName, avatarUrl, shopId, role];
}
