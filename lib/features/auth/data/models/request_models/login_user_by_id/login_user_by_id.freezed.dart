// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_user_by_id.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoginUserById {

@JsonKey(name: "uid") String? get uid;@JsonKey(name: "password") String? get password;
/// Create a copy of LoginUserById
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginUserByIdCopyWith<LoginUserById> get copyWith => _$LoginUserByIdCopyWithImpl<LoginUserById>(this as LoginUserById, _$identity);

  /// Serializes this LoginUserById to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginUserById&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,password);

@override
String toString() {
  return 'LoginUserById(uid: $uid, password: $password)';
}


}

/// @nodoc
abstract mixin class $LoginUserByIdCopyWith<$Res>  {
  factory $LoginUserByIdCopyWith(LoginUserById value, $Res Function(LoginUserById) _then) = _$LoginUserByIdCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "uid") String? uid,@JsonKey(name: "password") String? password
});




}
/// @nodoc
class _$LoginUserByIdCopyWithImpl<$Res>
    implements $LoginUserByIdCopyWith<$Res> {
  _$LoginUserByIdCopyWithImpl(this._self, this._then);

  final LoginUserById _self;
  final $Res Function(LoginUserById) _then;

/// Create a copy of LoginUserById
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = freezed,Object? password = freezed,}) {
  return _then(_self.copyWith(
uid: freezed == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginUserById].
extension LoginUserByIdPatterns on LoginUserById {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginUserById value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginUserById() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginUserById value)  $default,){
final _that = this;
switch (_that) {
case _LoginUserById():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginUserById value)?  $default,){
final _that = this;
switch (_that) {
case _LoginUserById() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: "uid")  String? uid, @JsonKey(name: "password")  String? password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginUserById() when $default != null:
return $default(_that.uid,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: "uid")  String? uid, @JsonKey(name: "password")  String? password)  $default,) {final _that = this;
switch (_that) {
case _LoginUserById():
return $default(_that.uid,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: "uid")  String? uid, @JsonKey(name: "password")  String? password)?  $default,) {final _that = this;
switch (_that) {
case _LoginUserById() when $default != null:
return $default(_that.uid,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginUserById implements LoginUserById {
  const _LoginUserById({@JsonKey(name: "uid") this.uid, @JsonKey(name: "password") this.password});
  factory _LoginUserById.fromJson(Map<String, dynamic> json) => _$LoginUserByIdFromJson(json);

@override@JsonKey(name: "uid") final  String? uid;
@override@JsonKey(name: "password") final  String? password;

/// Create a copy of LoginUserById
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginUserByIdCopyWith<_LoginUserById> get copyWith => __$LoginUserByIdCopyWithImpl<_LoginUserById>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginUserByIdToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginUserById&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,password);

@override
String toString() {
  return 'LoginUserById(uid: $uid, password: $password)';
}


}

/// @nodoc
abstract mixin class _$LoginUserByIdCopyWith<$Res> implements $LoginUserByIdCopyWith<$Res> {
  factory _$LoginUserByIdCopyWith(_LoginUserById value, $Res Function(_LoginUserById) _then) = __$LoginUserByIdCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: "uid") String? uid,@JsonKey(name: "password") String? password
});




}
/// @nodoc
class __$LoginUserByIdCopyWithImpl<$Res>
    implements _$LoginUserByIdCopyWith<$Res> {
  __$LoginUserByIdCopyWithImpl(this._self, this._then);

  final _LoginUserById _self;
  final $Res Function(_LoginUserById) _then;

/// Create a copy of LoginUserById
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = freezed,Object? password = freezed,}) {
  return _then(_LoginUserById(
uid: freezed == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
