// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'measurement_template_field_option_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MeasurementTemplateFieldOptionModel {

 String get id;@JsonKey(name: 'option_key') String get optionKey;@JsonKey(name: 'label_en') String get labelEn;@JsonKey(name: 'label_ur') String? get labelUr;@JsonKey(name: 'display_order') int get displayOrder;
/// Create a copy of MeasurementTemplateFieldOptionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeasurementTemplateFieldOptionModelCopyWith<MeasurementTemplateFieldOptionModel> get copyWith => _$MeasurementTemplateFieldOptionModelCopyWithImpl<MeasurementTemplateFieldOptionModel>(this as MeasurementTemplateFieldOptionModel, _$identity);

  /// Serializes this MeasurementTemplateFieldOptionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeasurementTemplateFieldOptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.optionKey, optionKey) || other.optionKey == optionKey)&&(identical(other.labelEn, labelEn) || other.labelEn == labelEn)&&(identical(other.labelUr, labelUr) || other.labelUr == labelUr)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,optionKey,labelEn,labelUr,displayOrder);

@override
String toString() {
  return 'MeasurementTemplateFieldOptionModel(id: $id, optionKey: $optionKey, labelEn: $labelEn, labelUr: $labelUr, displayOrder: $displayOrder)';
}


}

/// @nodoc
abstract mixin class $MeasurementTemplateFieldOptionModelCopyWith<$Res>  {
  factory $MeasurementTemplateFieldOptionModelCopyWith(MeasurementTemplateFieldOptionModel value, $Res Function(MeasurementTemplateFieldOptionModel) _then) = _$MeasurementTemplateFieldOptionModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'option_key') String optionKey,@JsonKey(name: 'label_en') String labelEn,@JsonKey(name: 'label_ur') String? labelUr,@JsonKey(name: 'display_order') int displayOrder
});




}
/// @nodoc
class _$MeasurementTemplateFieldOptionModelCopyWithImpl<$Res>
    implements $MeasurementTemplateFieldOptionModelCopyWith<$Res> {
  _$MeasurementTemplateFieldOptionModelCopyWithImpl(this._self, this._then);

  final MeasurementTemplateFieldOptionModel _self;
  final $Res Function(MeasurementTemplateFieldOptionModel) _then;

/// Create a copy of MeasurementTemplateFieldOptionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? optionKey = null,Object? labelEn = null,Object? labelUr = freezed,Object? displayOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,optionKey: null == optionKey ? _self.optionKey : optionKey // ignore: cast_nullable_to_non_nullable
as String,labelEn: null == labelEn ? _self.labelEn : labelEn // ignore: cast_nullable_to_non_nullable
as String,labelUr: freezed == labelUr ? _self.labelUr : labelUr // ignore: cast_nullable_to_non_nullable
as String?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MeasurementTemplateFieldOptionModel].
extension MeasurementTemplateFieldOptionModelPatterns on MeasurementTemplateFieldOptionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeasurementTemplateFieldOptionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeasurementTemplateFieldOptionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeasurementTemplateFieldOptionModel value)  $default,){
final _that = this;
switch (_that) {
case _MeasurementTemplateFieldOptionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeasurementTemplateFieldOptionModel value)?  $default,){
final _that = this;
switch (_that) {
case _MeasurementTemplateFieldOptionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'option_key')  String optionKey, @JsonKey(name: 'label_en')  String labelEn, @JsonKey(name: 'label_ur')  String? labelUr, @JsonKey(name: 'display_order')  int displayOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeasurementTemplateFieldOptionModel() when $default != null:
return $default(_that.id,_that.optionKey,_that.labelEn,_that.labelUr,_that.displayOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'option_key')  String optionKey, @JsonKey(name: 'label_en')  String labelEn, @JsonKey(name: 'label_ur')  String? labelUr, @JsonKey(name: 'display_order')  int displayOrder)  $default,) {final _that = this;
switch (_that) {
case _MeasurementTemplateFieldOptionModel():
return $default(_that.id,_that.optionKey,_that.labelEn,_that.labelUr,_that.displayOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'option_key')  String optionKey, @JsonKey(name: 'label_en')  String labelEn, @JsonKey(name: 'label_ur')  String? labelUr, @JsonKey(name: 'display_order')  int displayOrder)?  $default,) {final _that = this;
switch (_that) {
case _MeasurementTemplateFieldOptionModel() when $default != null:
return $default(_that.id,_that.optionKey,_that.labelEn,_that.labelUr,_that.displayOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeasurementTemplateFieldOptionModel implements MeasurementTemplateFieldOptionModel {
  const _MeasurementTemplateFieldOptionModel({required this.id, @JsonKey(name: 'option_key') required this.optionKey, @JsonKey(name: 'label_en') required this.labelEn, @JsonKey(name: 'label_ur') this.labelUr, @JsonKey(name: 'display_order') required this.displayOrder});
  factory _MeasurementTemplateFieldOptionModel.fromJson(Map<String, dynamic> json) => _$MeasurementTemplateFieldOptionModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'option_key') final  String optionKey;
@override@JsonKey(name: 'label_en') final  String labelEn;
@override@JsonKey(name: 'label_ur') final  String? labelUr;
@override@JsonKey(name: 'display_order') final  int displayOrder;

/// Create a copy of MeasurementTemplateFieldOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeasurementTemplateFieldOptionModelCopyWith<_MeasurementTemplateFieldOptionModel> get copyWith => __$MeasurementTemplateFieldOptionModelCopyWithImpl<_MeasurementTemplateFieldOptionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeasurementTemplateFieldOptionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeasurementTemplateFieldOptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.optionKey, optionKey) || other.optionKey == optionKey)&&(identical(other.labelEn, labelEn) || other.labelEn == labelEn)&&(identical(other.labelUr, labelUr) || other.labelUr == labelUr)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,optionKey,labelEn,labelUr,displayOrder);

@override
String toString() {
  return 'MeasurementTemplateFieldOptionModel(id: $id, optionKey: $optionKey, labelEn: $labelEn, labelUr: $labelUr, displayOrder: $displayOrder)';
}


}

/// @nodoc
abstract mixin class _$MeasurementTemplateFieldOptionModelCopyWith<$Res> implements $MeasurementTemplateFieldOptionModelCopyWith<$Res> {
  factory _$MeasurementTemplateFieldOptionModelCopyWith(_MeasurementTemplateFieldOptionModel value, $Res Function(_MeasurementTemplateFieldOptionModel) _then) = __$MeasurementTemplateFieldOptionModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'option_key') String optionKey,@JsonKey(name: 'label_en') String labelEn,@JsonKey(name: 'label_ur') String? labelUr,@JsonKey(name: 'display_order') int displayOrder
});




}
/// @nodoc
class __$MeasurementTemplateFieldOptionModelCopyWithImpl<$Res>
    implements _$MeasurementTemplateFieldOptionModelCopyWith<$Res> {
  __$MeasurementTemplateFieldOptionModelCopyWithImpl(this._self, this._then);

  final _MeasurementTemplateFieldOptionModel _self;
  final $Res Function(_MeasurementTemplateFieldOptionModel) _then;

/// Create a copy of MeasurementTemplateFieldOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? optionKey = null,Object? labelEn = null,Object? labelUr = freezed,Object? displayOrder = null,}) {
  return _then(_MeasurementTemplateFieldOptionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,optionKey: null == optionKey ? _self.optionKey : optionKey // ignore: cast_nullable_to_non_nullable
as String,labelEn: null == labelEn ? _self.labelEn : labelEn // ignore: cast_nullable_to_non_nullable
as String,labelUr: freezed == labelUr ? _self.labelUr : labelUr // ignore: cast_nullable_to_non_nullable
as String?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
