// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shop_membership_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShopMembershipModel {

@JsonKey(name: 'shop_id') String get shopId; ShopRole get role;
/// Create a copy of ShopMembershipModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShopMembershipModelCopyWith<ShopMembershipModel> get copyWith => _$ShopMembershipModelCopyWithImpl<ShopMembershipModel>(this as ShopMembershipModel, _$identity);

  /// Serializes this ShopMembershipModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShopMembershipModel&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shopId,role);

@override
String toString() {
  return 'ShopMembershipModel(shopId: $shopId, role: $role)';
}


}

/// @nodoc
abstract mixin class $ShopMembershipModelCopyWith<$Res>  {
  factory $ShopMembershipModelCopyWith(ShopMembershipModel value, $Res Function(ShopMembershipModel) _then) = _$ShopMembershipModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'shop_id') String shopId, ShopRole role
});




}
/// @nodoc
class _$ShopMembershipModelCopyWithImpl<$Res>
    implements $ShopMembershipModelCopyWith<$Res> {
  _$ShopMembershipModelCopyWithImpl(this._self, this._then);

  final ShopMembershipModel _self;
  final $Res Function(ShopMembershipModel) _then;

/// Create a copy of ShopMembershipModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shopId = null,Object? role = null,}) {
  return _then(_self.copyWith(
shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ShopRole,
  ));
}

}


/// Adds pattern-matching-related methods to [ShopMembershipModel].
extension ShopMembershipModelPatterns on ShopMembershipModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShopMembershipModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShopMembershipModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShopMembershipModel value)  $default,){
final _that = this;
switch (_that) {
case _ShopMembershipModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShopMembershipModel value)?  $default,){
final _that = this;
switch (_that) {
case _ShopMembershipModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'shop_id')  String shopId,  ShopRole role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShopMembershipModel() when $default != null:
return $default(_that.shopId,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'shop_id')  String shopId,  ShopRole role)  $default,) {final _that = this;
switch (_that) {
case _ShopMembershipModel():
return $default(_that.shopId,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'shop_id')  String shopId,  ShopRole role)?  $default,) {final _that = this;
switch (_that) {
case _ShopMembershipModel() when $default != null:
return $default(_that.shopId,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShopMembershipModel implements ShopMembershipModel {
  const _ShopMembershipModel({@JsonKey(name: 'shop_id') required this.shopId, required this.role});
  factory _ShopMembershipModel.fromJson(Map<String, dynamic> json) => _$ShopMembershipModelFromJson(json);

@override@JsonKey(name: 'shop_id') final  String shopId;
@override final  ShopRole role;

/// Create a copy of ShopMembershipModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShopMembershipModelCopyWith<_ShopMembershipModel> get copyWith => __$ShopMembershipModelCopyWithImpl<_ShopMembershipModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShopMembershipModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShopMembershipModel&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shopId,role);

@override
String toString() {
  return 'ShopMembershipModel(shopId: $shopId, role: $role)';
}


}

/// @nodoc
abstract mixin class _$ShopMembershipModelCopyWith<$Res> implements $ShopMembershipModelCopyWith<$Res> {
  factory _$ShopMembershipModelCopyWith(_ShopMembershipModel value, $Res Function(_ShopMembershipModel) _then) = __$ShopMembershipModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'shop_id') String shopId, ShopRole role
});




}
/// @nodoc
class __$ShopMembershipModelCopyWithImpl<$Res>
    implements _$ShopMembershipModelCopyWith<$Res> {
  __$ShopMembershipModelCopyWithImpl(this._self, this._then);

  final _ShopMembershipModel _self;
  final $Res Function(_ShopMembershipModel) _then;

/// Create a copy of ShopMembershipModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shopId = null,Object? role = null,}) {
  return _then(_ShopMembershipModel(
shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ShopRole,
  ));
}


}

// dart format on
