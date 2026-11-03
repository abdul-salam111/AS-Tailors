import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/app_enums.dart';

part 'shop_membership_model.freezed.dart';
part 'shop_membership_model.g.dart';

/// Maps a single `shop_members` row (joined narrowly — just the columns
/// the auth/session flow needs, not the full table).
@freezed
abstract class ShopMembershipModel with _$ShopMembershipModel {
  const factory ShopMembershipModel({
    @JsonKey(name: 'shop_id') required String shopId,
    required ShopRole role,
  }) = _ShopMembershipModel;

  factory ShopMembershipModel.fromJson(Map<String, dynamic> json) =>
      _$ShopMembershipModelFromJson(json);
}
