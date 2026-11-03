// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_token.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserToken {

@JsonKey(name: "access_token") String? get accessToken;@JsonKey(name: "token_type") String? get tokenType;@JsonKey(name: "refresh_token") String? get refreshToken;
/// Create a copy of UserToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserTokenCopyWith<UserToken> get copyWith => _$UserTokenCopyWithImpl<UserToken>(this as UserToken, _$identity);

  /// Serializes this UserToken to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserToken&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,tokenType,refreshToken);

@override
String toString() {
  return 'UserToken(accessToken: $accessToken, tokenType: $tokenType, refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class $UserTokenCopyWith<$Res>  {
  factory $UserTokenCopyWith(UserToken value, $Res Function(UserToken) _then) = _$UserTokenCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "access_token") String? accessToken,@JsonKey(name: "token_type") String? tokenType,@JsonKey(name: "refresh_token") String? refreshToken
});




}
/// @nodoc
class _$UserTokenCopyWithImpl<$Res>
    implements $UserTokenCopyWith<$Res> {
  _$UserTokenCopyWithImpl(this._self, this._then);

  final UserToken _self;
  final $Res Function(UserToken) _then;

/// Create a copy of UserToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = freezed,Object? tokenType = freezed,Object? refreshToken = freezed,}) {
  return _then(_self.copyWith(
accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,tokenType: freezed == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserToken].
extension UserTokenPatterns on UserToken {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserToken value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserToken() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserToken value)  $default,){
final _that = this;
switch (_that) {
case _UserToken():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserToken value)?  $default,){
final _that = this;
switch (_that) {
case _UserToken() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: "access_token")  String? accessToken, @JsonKey(name: "token_type")  String? tokenType, @JsonKey(name: "refresh_token")  String? refreshToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserToken() when $default != null:
return $default(_that.accessToken,_that.tokenType,_that.refreshToken);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: "access_token")  String? accessToken, @JsonKey(name: "token_type")  String? tokenType, @JsonKey(name: "refresh_token")  String? refreshToken)  $default,) {final _that = this;
switch (_that) {
case _UserToken():
return $default(_that.accessToken,_that.tokenType,_that.refreshToken);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: "access_token")  String? accessToken, @JsonKey(name: "token_type")  String? tokenType, @JsonKey(name: "refresh_token")  String? refreshToken)?  $default,) {final _that = this;
switch (_that) {
case _UserToken() when $default != null:
return $default(_that.accessToken,_that.tokenType,_that.refreshToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserToken implements UserToken {
  const _UserToken({@JsonKey(name: "access_token") this.accessToken, @JsonKey(name: "token_type") this.tokenType, @JsonKey(name: "refresh_token") this.refreshToken});
  factory _UserToken.fromJson(Map<String, dynamic> json) => _$UserTokenFromJson(json);

@override@JsonKey(name: "access_token") final  String? accessToken;
@override@JsonKey(name: "token_type") final  String? tokenType;
@override@JsonKey(name: "refresh_token") final  String? refreshToken;

/// Create a copy of UserToken
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserTokenCopyWith<_UserToken> get copyWith => __$UserTokenCopyWithImpl<_UserToken>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserTokenToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserToken&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,tokenType,refreshToken);

@override
String toString() {
  return 'UserToken(accessToken: $accessToken, tokenType: $tokenType, refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class _$UserTokenCopyWith<$Res> implements $UserTokenCopyWith<$Res> {
  factory _$UserTokenCopyWith(_UserToken value, $Res Function(_UserToken) _then) = __$UserTokenCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: "access_token") String? accessToken,@JsonKey(name: "token_type") String? tokenType,@JsonKey(name: "refresh_token") String? refreshToken
});




}
/// @nodoc
class __$UserTokenCopyWithImpl<$Res>
    implements _$UserTokenCopyWith<$Res> {
  __$UserTokenCopyWithImpl(this._self, this._then);

  final _UserToken _self;
  final $Res Function(_UserToken) _then;

/// Create a copy of UserToken
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = freezed,Object? tokenType = freezed,Object? refreshToken = freezed,}) {
  return _then(_UserToken(
accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,tokenType: freezed == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
