import 'package:freezed_annotation/freezed_annotation.dart';
part 'login_user_by_id.freezed.dart';
part 'login_user_by_id.g.dart';

@freezed
abstract class LoginUserById with _$LoginUserById {
  const factory LoginUserById({
    @JsonKey(name: "uid") String? uid,
    @JsonKey(name: "password") String? password,
  }) = _LoginUserById;

  factory LoginUserById.fromJson(Map<String, dynamic> json) =>
      _$LoginUserByIdFromJson(json);
}
