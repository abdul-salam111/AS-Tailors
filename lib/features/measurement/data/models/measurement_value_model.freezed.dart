// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'measurement_value_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MeasurementValueModel {

 String get fieldId; String get fieldKey; String get labelEn; String? get labelUr; MeasurementFieldInputType get inputType; double? get value; String? get unit; String? get selectedOptionLabelEn; String? get selectedOptionLabelUr;
/// Create a copy of MeasurementValueModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeasurementValueModelCopyWith<MeasurementValueModel> get copyWith => _$MeasurementValueModelCopyWithImpl<MeasurementValueModel>(this as MeasurementValueModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeasurementValueModel&&(identical(other.fieldId, fieldId) || other.fieldId == fieldId)&&(identical(other.fieldKey, fieldKey) || other.fieldKey == fieldKey)&&(identical(other.labelEn, labelEn) || other.labelEn == labelEn)&&(identical(other.labelUr, labelUr) || other.labelUr == labelUr)&&(identical(other.inputType, inputType) || other.inputType == inputType)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.selectedOptionLabelEn, selectedOptionLabelEn) || other.selectedOptionLabelEn == selectedOptionLabelEn)&&(identical(other.selectedOptionLabelUr, selectedOptionLabelUr) || other.selectedOptionLabelUr == selectedOptionLabelUr));
}


@override
int get hashCode => Object.hash(runtimeType,fieldId,fieldKey,labelEn,labelUr,inputType,value,unit,selectedOptionLabelEn,selectedOptionLabelUr);

@override
String toString() {
  return 'MeasurementValueModel(fieldId: $fieldId, fieldKey: $fieldKey, labelEn: $labelEn, labelUr: $labelUr, inputType: $inputType, value: $value, unit: $unit, selectedOptionLabelEn: $selectedOptionLabelEn, selectedOptionLabelUr: $selectedOptionLabelUr)';
}


}

/// @nodoc
abstract mixin class $MeasurementValueModelCopyWith<$Res>  {
  factory $MeasurementValueModelCopyWith(MeasurementValueModel value, $Res Function(MeasurementValueModel) _then) = _$MeasurementValueModelCopyWithImpl;
@useResult
$Res call({
 String fieldId, String fieldKey, String labelEn, String? labelUr, MeasurementFieldInputType inputType, double? value, String? unit, String? selectedOptionLabelEn, String? selectedOptionLabelUr
});




}
/// @nodoc
class _$MeasurementValueModelCopyWithImpl<$Res>
    implements $MeasurementValueModelCopyWith<$Res> {
  _$MeasurementValueModelCopyWithImpl(this._self, this._then);

  final MeasurementValueModel _self;
  final $Res Function(MeasurementValueModel) _then;

/// Create a copy of MeasurementValueModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fieldId = null,Object? fieldKey = null,Object? labelEn = null,Object? labelUr = freezed,Object? inputType = null,Object? value = freezed,Object? unit = freezed,Object? selectedOptionLabelEn = freezed,Object? selectedOptionLabelUr = freezed,}) {
  return _then(_self.copyWith(
fieldId: null == fieldId ? _self.fieldId : fieldId // ignore: cast_nullable_to_non_nullable
as String,fieldKey: null == fieldKey ? _self.fieldKey : fieldKey // ignore: cast_nullable_to_non_nullable
as String,labelEn: null == labelEn ? _self.labelEn : labelEn // ignore: cast_nullable_to_non_nullable
as String,labelUr: freezed == labelUr ? _self.labelUr : labelUr // ignore: cast_nullable_to_non_nullable
as String?,inputType: null == inputType ? _self.inputType : inputType // ignore: cast_nullable_to_non_nullable
as MeasurementFieldInputType,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,selectedOptionLabelEn: freezed == selectedOptionLabelEn ? _self.selectedOptionLabelEn : selectedOptionLabelEn // ignore: cast_nullable_to_non_nullable
as String?,selectedOptionLabelUr: freezed == selectedOptionLabelUr ? _self.selectedOptionLabelUr : selectedOptionLabelUr // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MeasurementValueModel].
extension MeasurementValueModelPatterns on MeasurementValueModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeasurementValueModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeasurementValueModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeasurementValueModel value)  $default,){
final _that = this;
switch (_that) {
case _MeasurementValueModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeasurementValueModel value)?  $default,){
final _that = this;
switch (_that) {
case _MeasurementValueModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fieldId,  String fieldKey,  String labelEn,  String? labelUr,  MeasurementFieldInputType inputType,  double? value,  String? unit,  String? selectedOptionLabelEn,  String? selectedOptionLabelUr)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeasurementValueModel() when $default != null:
return $default(_that.fieldId,_that.fieldKey,_that.labelEn,_that.labelUr,_that.inputType,_that.value,_that.unit,_that.selectedOptionLabelEn,_that.selectedOptionLabelUr);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fieldId,  String fieldKey,  String labelEn,  String? labelUr,  MeasurementFieldInputType inputType,  double? value,  String? unit,  String? selectedOptionLabelEn,  String? selectedOptionLabelUr)  $default,) {final _that = this;
switch (_that) {
case _MeasurementValueModel():
return $default(_that.fieldId,_that.fieldKey,_that.labelEn,_that.labelUr,_that.inputType,_that.value,_that.unit,_that.selectedOptionLabelEn,_that.selectedOptionLabelUr);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fieldId,  String fieldKey,  String labelEn,  String? labelUr,  MeasurementFieldInputType inputType,  double? value,  String? unit,  String? selectedOptionLabelEn,  String? selectedOptionLabelUr)?  $default,) {final _that = this;
switch (_that) {
case _MeasurementValueModel() when $default != null:
return $default(_that.fieldId,_that.fieldKey,_that.labelEn,_that.labelUr,_that.inputType,_that.value,_that.unit,_that.selectedOptionLabelEn,_that.selectedOptionLabelUr);case _:
  return null;

}
}

}

/// @nodoc


class _MeasurementValueModel implements MeasurementValueModel {
  const _MeasurementValueModel({required this.fieldId, required this.fieldKey, required this.labelEn, this.labelUr, required this.inputType, this.value, this.unit, this.selectedOptionLabelEn, this.selectedOptionLabelUr});
  

@override final  String fieldId;
@override final  String fieldKey;
@override final  String labelEn;
@override final  String? labelUr;
@override final  MeasurementFieldInputType inputType;
@override final  double? value;
@override final  String? unit;
@override final  String? selectedOptionLabelEn;
@override final  String? selectedOptionLabelUr;

/// Create a copy of MeasurementValueModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeasurementValueModelCopyWith<_MeasurementValueModel> get copyWith => __$MeasurementValueModelCopyWithImpl<_MeasurementValueModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeasurementValueModel&&(identical(other.fieldId, fieldId) || other.fieldId == fieldId)&&(identical(other.fieldKey, fieldKey) || other.fieldKey == fieldKey)&&(identical(other.labelEn, labelEn) || other.labelEn == labelEn)&&(identical(other.labelUr, labelUr) || other.labelUr == labelUr)&&(identical(other.inputType, inputType) || other.inputType == inputType)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.selectedOptionLabelEn, selectedOptionLabelEn) || other.selectedOptionLabelEn == selectedOptionLabelEn)&&(identical(other.selectedOptionLabelUr, selectedOptionLabelUr) || other.selectedOptionLabelUr == selectedOptionLabelUr));
}


@override
int get hashCode => Object.hash(runtimeType,fieldId,fieldKey,labelEn,labelUr,inputType,value,unit,selectedOptionLabelEn,selectedOptionLabelUr);

@override
String toString() {
  return 'MeasurementValueModel(fieldId: $fieldId, fieldKey: $fieldKey, labelEn: $labelEn, labelUr: $labelUr, inputType: $inputType, value: $value, unit: $unit, selectedOptionLabelEn: $selectedOptionLabelEn, selectedOptionLabelUr: $selectedOptionLabelUr)';
}


}

/// @nodoc
abstract mixin class _$MeasurementValueModelCopyWith<$Res> implements $MeasurementValueModelCopyWith<$Res> {
  factory _$MeasurementValueModelCopyWith(_MeasurementValueModel value, $Res Function(_MeasurementValueModel) _then) = __$MeasurementValueModelCopyWithImpl;
@override @useResult
$Res call({
 String fieldId, String fieldKey, String labelEn, String? labelUr, MeasurementFieldInputType inputType, double? value, String? unit, String? selectedOptionLabelEn, String? selectedOptionLabelUr
});




}
/// @nodoc
class __$MeasurementValueModelCopyWithImpl<$Res>
    implements _$MeasurementValueModelCopyWith<$Res> {
  __$MeasurementValueModelCopyWithImpl(this._self, this._then);

  final _MeasurementValueModel _self;
  final $Res Function(_MeasurementValueModel) _then;

/// Create a copy of MeasurementValueModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fieldId = null,Object? fieldKey = null,Object? labelEn = null,Object? labelUr = freezed,Object? inputType = null,Object? value = freezed,Object? unit = freezed,Object? selectedOptionLabelEn = freezed,Object? selectedOptionLabelUr = freezed,}) {
  return _then(_MeasurementValueModel(
fieldId: null == fieldId ? _self.fieldId : fieldId // ignore: cast_nullable_to_non_nullable
as String,fieldKey: null == fieldKey ? _self.fieldKey : fieldKey // ignore: cast_nullable_to_non_nullable
as String,labelEn: null == labelEn ? _self.labelEn : labelEn // ignore: cast_nullable_to_non_nullable
as String,labelUr: freezed == labelUr ? _self.labelUr : labelUr // ignore: cast_nullable_to_non_nullable
as String?,inputType: null == inputType ? _self.inputType : inputType // ignore: cast_nullable_to_non_nullable
as MeasurementFieldInputType,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,selectedOptionLabelEn: freezed == selectedOptionLabelEn ? _self.selectedOptionLabelEn : selectedOptionLabelEn // ignore: cast_nullable_to_non_nullable
as String?,selectedOptionLabelUr: freezed == selectedOptionLabelUr ? _self.selectedOptionLabelUr : selectedOptionLabelUr // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
