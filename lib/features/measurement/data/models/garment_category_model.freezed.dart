// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'garment_category_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GarmentCategoryModel {

 String get id; String get name;@JsonKey(name: 'name_ur') String? get nameUr; String get slug;
/// Create a copy of GarmentCategoryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GarmentCategoryModelCopyWith<GarmentCategoryModel> get copyWith => _$GarmentCategoryModelCopyWithImpl<GarmentCategoryModel>(this as GarmentCategoryModel, _$identity);

  /// Serializes this GarmentCategoryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GarmentCategoryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameUr, nameUr) || other.nameUr == nameUr)&&(identical(other.slug, slug) || other.slug == slug));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nameUr,slug);

@override
String toString() {
  return 'GarmentCategoryModel(id: $id, name: $name, nameUr: $nameUr, slug: $slug)';
}


}

/// @nodoc
abstract mixin class $GarmentCategoryModelCopyWith<$Res>  {
  factory $GarmentCategoryModelCopyWith(GarmentCategoryModel value, $Res Function(GarmentCategoryModel) _then) = _$GarmentCategoryModelCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'name_ur') String? nameUr, String slug
});




}
/// @nodoc
class _$GarmentCategoryModelCopyWithImpl<$Res>
    implements $GarmentCategoryModelCopyWith<$Res> {
  _$GarmentCategoryModelCopyWithImpl(this._self, this._then);

  final GarmentCategoryModel _self;
  final $Res Function(GarmentCategoryModel) _then;

/// Create a copy of GarmentCategoryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? nameUr = freezed,Object? slug = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nameUr: freezed == nameUr ? _self.nameUr : nameUr // ignore: cast_nullable_to_non_nullable
as String?,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GarmentCategoryModel].
extension GarmentCategoryModelPatterns on GarmentCategoryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GarmentCategoryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GarmentCategoryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GarmentCategoryModel value)  $default,){
final _that = this;
switch (_that) {
case _GarmentCategoryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GarmentCategoryModel value)?  $default,){
final _that = this;
switch (_that) {
case _GarmentCategoryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'name_ur')  String? nameUr,  String slug)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GarmentCategoryModel() when $default != null:
return $default(_that.id,_that.name,_that.nameUr,_that.slug);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'name_ur')  String? nameUr,  String slug)  $default,) {final _that = this;
switch (_that) {
case _GarmentCategoryModel():
return $default(_that.id,_that.name,_that.nameUr,_that.slug);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'name_ur')  String? nameUr,  String slug)?  $default,) {final _that = this;
switch (_that) {
case _GarmentCategoryModel() when $default != null:
return $default(_that.id,_that.name,_that.nameUr,_that.slug);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GarmentCategoryModel implements GarmentCategoryModel {
  const _GarmentCategoryModel({required this.id, required this.name, @JsonKey(name: 'name_ur') this.nameUr, required this.slug});
  factory _GarmentCategoryModel.fromJson(Map<String, dynamic> json) => _$GarmentCategoryModelFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'name_ur') final  String? nameUr;
@override final  String slug;

/// Create a copy of GarmentCategoryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GarmentCategoryModelCopyWith<_GarmentCategoryModel> get copyWith => __$GarmentCategoryModelCopyWithImpl<_GarmentCategoryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GarmentCategoryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GarmentCategoryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameUr, nameUr) || other.nameUr == nameUr)&&(identical(other.slug, slug) || other.slug == slug));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nameUr,slug);

@override
String toString() {
  return 'GarmentCategoryModel(id: $id, name: $name, nameUr: $nameUr, slug: $slug)';
}


}

/// @nodoc
abstract mixin class _$GarmentCategoryModelCopyWith<$Res> implements $GarmentCategoryModelCopyWith<$Res> {
  factory _$GarmentCategoryModelCopyWith(_GarmentCategoryModel value, $Res Function(_GarmentCategoryModel) _then) = __$GarmentCategoryModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'name_ur') String? nameUr, String slug
});




}
/// @nodoc
class __$GarmentCategoryModelCopyWithImpl<$Res>
    implements _$GarmentCategoryModelCopyWith<$Res> {
  __$GarmentCategoryModelCopyWithImpl(this._self, this._then);

  final _GarmentCategoryModel _self;
  final $Res Function(_GarmentCategoryModel) _then;

/// Create a copy of GarmentCategoryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? nameUr = freezed,Object? slug = null,}) {
  return _then(_GarmentCategoryModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nameUr: freezed == nameUr ? _self.nameUr : nameUr // ignore: cast_nullable_to_non_nullable
as String?,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
