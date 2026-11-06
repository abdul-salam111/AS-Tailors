// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_membership_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShopMembershipModel _$ShopMembershipModelFromJson(Map<String, dynamic> json) =>
    _ShopMembershipModel(
      shopId: json['shop_id'] as String,
      role: $enumDecode(_$ShopRoleEnumMap, json['role']),
    );

Map<String, dynamic> _$ShopMembershipModelToJson(_ShopMembershipModel instance) =>
    <String, dynamic>{'shop_id': instance.shopId, 'role': _$ShopRoleEnumMap[instance.role]!};

const _$ShopRoleEnumMap = {
  ShopRole.owner: 'owner',
  ShopRole.admin: 'admin',
  ShopRole.tailor: 'tailor',
  ShopRole.staff: 'staff',
};
