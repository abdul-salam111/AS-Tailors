// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shop_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShopModel {

 String get id;@JsonKey(name: 'owner_id') String get ownerId; String get name; String get currency; String get timezone;
/// Create a copy of ShopModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShopModelCopyWith<ShopModel> get copyWith => _$ShopModelCopyWithImpl<ShopModel>(this as ShopModel, _$identity);

  /// Serializes this ShopModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShopModel&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.timezone, timezone) || other.timezone == timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,currency,timezone);

@override
String toString() {
  return 'ShopModel(id: $id, ownerId: $ownerId, name: $name, currency: $currency, timezone: $timezone)';
}


}

/// @nodoc
abstract mixin class $ShopModelCopyWith<$Res>  {
  factory $ShopModelCopyWith(ShopModel value, $Res Function(ShopModel) _then) = _$ShopModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'owner_id') String ownerId, String name, String currency, String timezone
});




}
/// @nodoc
class _$ShopModelCopyWithImpl<$Res>
    implements $ShopModelCopyWith<$Res> {
  _$ShopModelCopyWithImpl(this._self, this._then);

  final ShopModel _self;
  final $Res Function(ShopModel) _then;

/// Create a copy of ShopModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? currency = null,Object? timezone = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ShopModel].
extension ShopModelPatterns on ShopModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShopModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShopModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShopModel value)  $default,){
final _that = this;
switch (_that) {
case _ShopModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShopModel value)?  $default,){
final _that = this;
switch (_that) {
case _ShopModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'owner_id')  String ownerId,  String name,  String currency,  String timezone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShopModel() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.currency,_that.timezone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'owner_id')  String ownerId,  String name,  String currency,  String timezone)  $default,) {final _that = this;
switch (_that) {
case _ShopModel():
return $default(_that.id,_that.ownerId,_that.name,_that.currency,_that.timezone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'owner_id')  String ownerId,  String name,  String currency,  String timezone)?  $default,) {final _that = this;
switch (_that) {
case _ShopModel() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.currency,_that.timezone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShopModel implements ShopModel {
  const _ShopModel({required this.id, @JsonKey(name: 'owner_id') required this.ownerId, required this.name, required this.currency, required this.timezone});
  factory _ShopModel.fromJson(Map<String, dynamic> json) => _$ShopModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'owner_id') final  String ownerId;
@override final  String name;
@override final  String currency;
@override final  String timezone;

/// Create a copy of ShopModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShopModelCopyWith<_ShopModel> get copyWith => __$ShopModelCopyWithImpl<_ShopModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShopModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShopModel&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.timezone, timezone) || other.timezone == timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,currency,timezone);

@override
String toString() {
  return 'ShopModel(id: $id, ownerId: $ownerId, name: $name, currency: $currency, timezone: $timezone)';
}


}

/// @nodoc
abstract mixin class _$ShopModelCopyWith<$Res> implements $ShopModelCopyWith<$Res> {
  factory _$ShopModelCopyWith(_ShopModel value, $Res Function(_ShopModel) _then) = __$ShopModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'owner_id') String ownerId, String name, String currency, String timezone
});




}
/// @nodoc
class __$ShopModelCopyWithImpl<$Res>
    implements _$ShopModelCopyWith<$Res> {
  __$ShopModelCopyWithImpl(this._self, this._then);

  final _ShopModel _self;
  final $Res Function(_ShopModel) _then;

/// Create a copy of ShopModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? currency = null,Object? timezone = null,}) {
  return _then(_ShopModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
