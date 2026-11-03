// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserToken _$UserTokenFromJson(Map<String, dynamic> json) => _UserToken(
  accessToken: json['access_token'] as String?,
  tokenType: json['token_type'] as String?,
  refreshToken: json['refresh_token'] as String?,
);

Map<String, dynamic> _$UserTokenToJson(_UserToken instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'refresh_token': instance.refreshToken,
    };
