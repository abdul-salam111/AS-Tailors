import 'package:freezed_annotation/freezed_annotation.dart';
part 'user_token.freezed.dart';
part 'user_token.g.dart';

@freezed
abstract class UserToken with _$UserToken {
  const factory UserToken({
    @JsonKey(name: "access_token") String? accessToken,
    @JsonKey(name: "token_type") String? tokenType,
    @JsonKey(name: "refresh_token") String? refreshToken,
  }) = _UserToken;

  factory UserToken.fromJson(Map<String, dynamic> json) =>
      _$UserTokenFromJson(json);
}
