// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'measurement_template_field_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MeasurementTemplateFieldModel {

 String get id;@JsonKey(name: 'field_key') String get fieldKey;@JsonKey(name: 'label_en') String get labelEn;@JsonKey(name: 'label_ur') String? get labelUr;@JsonKey(name: 'section_key') String? get sectionKey;@JsonKey(name: 'section_label_en') String? get sectionLabelEn;@JsonKey(name: 'section_label_ur') String? get sectionLabelUr;@JsonKey(name: 'display_order') int get displayOrder;@JsonKey(name: 'is_required') bool get isRequired;@JsonKey(name: 'input_type') MeasurementFieldInputType get inputType;@JsonKey(name: 'default_unit') String get defaultUnit;@JsonKey(includeFromJson: false, includeToJson: false) List<MeasurementTemplateFieldOptionModel> get options;
/// Create a copy of MeasurementTemplateFieldModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeasurementTemplateFieldModelCopyWith<MeasurementTemplateFieldModel> get copyWith => _$MeasurementTemplateFieldModelCopyWithImpl<MeasurementTemplateFieldModel>(this as MeasurementTemplateFieldModel, _$identity);

  /// Serializes this MeasurementTemplateFieldModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeasurementTemplateFieldModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fieldKey, fieldKey) || other.fieldKey == fieldKey)&&(identical(other.labelEn, labelEn) || other.labelEn == labelEn)&&(identical(other.labelUr, labelUr) || other.labelUr == labelUr)&&(identical(other.sectionKey, sectionKey) || other.sectionKey == sectionKey)&&(identical(other.sectionLabelEn, sectionLabelEn) || other.sectionLabelEn == sectionLabelEn)&&(identical(other.sectionLabelUr, sectionLabelUr) || other.sectionLabelUr == sectionLabelUr)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&(identical(other.inputType, inputType) || other.inputType == inputType)&&(identical(other.defaultUnit, defaultUnit) || other.defaultUnit == defaultUnit)&&const DeepCollectionEquality().equals(other.options, options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fieldKey,labelEn,labelUr,sectionKey,sectionLabelEn,sectionLabelUr,displayOrder,isRequired,inputType,defaultUnit,const DeepCollectionEquality().hash(options));

@override
String toString() {
  return 'MeasurementTemplateFieldModel(id: $id, fieldKey: $fieldKey, labelEn: $labelEn, labelUr: $labelUr, sectionKey: $sectionKey, sectionLabelEn: $sectionLabelEn, sectionLabelUr: $sectionLabelUr, displayOrder: $displayOrder, isRequired: $isRequired, inputType: $inputType, defaultUnit: $defaultUnit, options: $options)';
}


}

/// @nodoc
abstract mixin class $MeasurementTemplateFieldModelCopyWith<$Res>  {
  factory $MeasurementTemplateFieldModelCopyWith(MeasurementTemplateFieldModel value, $Res Function(MeasurementTemplateFieldModel) _then) = _$MeasurementTemplateFieldModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'field_key') String fieldKey,@JsonKey(name: 'label_en') String labelEn,@JsonKey(name: 'label_ur') String? labelUr,@JsonKey(name: 'section_key') String? sectionKey,@JsonKey(name: 'section_label_en') String? sectionLabelEn,@JsonKey(name: 'section_label_ur') String? sectionLabelUr,@JsonKey(name: 'display_order') int displayOrder,@JsonKey(name: 'is_required') bool isRequired,@JsonKey(name: 'input_type') MeasurementFieldInputType inputType,@JsonKey(name: 'default_unit') String defaultUnit,@JsonKey(includeFromJson: false, includeToJson: false) List<MeasurementTemplateFieldOptionModel> options
});




}
/// @nodoc
class _$MeasurementTemplateFieldModelCopyWithImpl<$Res>
    implements $MeasurementTemplateFieldModelCopyWith<$Res> {
  _$MeasurementTemplateFieldModelCopyWithImpl(this._self, this._then);

  final MeasurementTemplateFieldModel _self;
  final $Res Function(MeasurementTemplateFieldModel) _then;

/// Create a copy of MeasurementTemplateFieldModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fieldKey = null,Object? labelEn = null,Object? labelUr = freezed,Object? sectionKey = freezed,Object? sectionLabelEn = freezed,Object? sectionLabelUr = freezed,Object? displayOrder = null,Object? isRequired = null,Object? inputType = null,Object? defaultUnit = null,Object? options = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fieldKey: null == fieldKey ? _self.fieldKey : fieldKey // ignore: cast_nullable_to_non_nullable
as String,labelEn: null == labelEn ? _self.labelEn : labelEn // ignore: cast_nullable_to_non_nullable
as String,labelUr: freezed == labelUr ? _self.labelUr : labelUr // ignore: cast_nullable_to_non_nullable
as String?,sectionKey: freezed == sectionKey ? _self.sectionKey : sectionKey // ignore: cast_nullable_to_non_nullable
as String?,sectionLabelEn: freezed == sectionLabelEn ? _self.sectionLabelEn : sectionLabelEn // ignore: cast_nullable_to_non_nullable
as String?,sectionLabelUr: freezed == sectionLabelUr ? _self.sectionLabelUr : sectionLabelUr // ignore: cast_nullable_to_non_nullable
as String?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,inputType: null == inputType ? _self.inputType : inputType // ignore: cast_nullable_to_non_nullable
as MeasurementFieldInputType,defaultUnit: null == defaultUnit ? _self.defaultUnit : defaultUnit // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<MeasurementTemplateFieldOptionModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [MeasurementTemplateFieldModel].
extension MeasurementTemplateFieldModelPatterns on MeasurementTemplateFieldModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeasurementTemplateFieldModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeasurementTemplateFieldModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeasurementTemplateFieldModel value)  $default,){
final _that = this;
switch (_that) {
case _MeasurementTemplateFieldModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeasurementTemplateFieldModel value)?  $default,){
final _that = this;
switch (_that) {
case _MeasurementTemplateFieldModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'field_key')  String fieldKey, @JsonKey(name: 'label_en')  String labelEn, @JsonKey(name: 'label_ur')  String? labelUr, @JsonKey(name: 'section_key')  String? sectionKey, @JsonKey(name: 'section_label_en')  String? sectionLabelEn, @JsonKey(name: 'section_label_ur')  String? sectionLabelUr, @JsonKey(name: 'display_order')  int displayOrder, @JsonKey(name: 'is_required')  bool isRequired, @JsonKey(name: 'input_type')  MeasurementFieldInputType inputType, @JsonKey(name: 'default_unit')  String defaultUnit, @JsonKey(includeFromJson: false, includeToJson: false)  List<MeasurementTemplateFieldOptionModel> options)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeasurementTemplateFieldModel() when $default != null:
return $default(_that.id,_that.fieldKey,_that.labelEn,_that.labelUr,_that.sectionKey,_that.sectionLabelEn,_that.sectionLabelUr,_that.displayOrder,_that.isRequired,_that.inputType,_that.defaultUnit,_that.options);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'field_key')  String fieldKey, @JsonKey(name: 'label_en')  String labelEn, @JsonKey(name: 'label_ur')  String? labelUr, @JsonKey(name: 'section_key')  String? sectionKey, @JsonKey(name: 'section_label_en')  String? sectionLabelEn, @JsonKey(name: 'section_label_ur')  String? sectionLabelUr, @JsonKey(name: 'display_order')  int displayOrder, @JsonKey(name: 'is_required')  bool isRequired, @JsonKey(name: 'input_type')  MeasurementFieldInputType inputType, @JsonKey(name: 'default_unit')  String defaultUnit, @JsonKey(includeFromJson: false, includeToJson: false)  List<MeasurementTemplateFieldOptionModel> options)  $default,) {final _that = this;
switch (_that) {
case _MeasurementTemplateFieldModel():
return $default(_that.id,_that.fieldKey,_that.labelEn,_that.labelUr,_that.sectionKey,_that.sectionLabelEn,_that.sectionLabelUr,_that.displayOrder,_that.isRequired,_that.inputType,_that.defaultUnit,_that.options);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'field_key')  String fieldKey, @JsonKey(name: 'label_en')  String labelEn, @JsonKey(name: 'label_ur')  String? labelUr, @JsonKey(name: 'section_key')  String? sectionKey, @JsonKey(name: 'section_label_en')  String? sectionLabelEn, @JsonKey(name: 'section_label_ur')  String? sectionLabelUr, @JsonKey(name: 'display_order')  int displayOrder, @JsonKey(name: 'is_required')  bool isRequired, @JsonKey(name: 'input_type')  MeasurementFieldInputType inputType, @JsonKey(name: 'default_unit')  String defaultUnit, @JsonKey(includeFromJson: false, includeToJson: false)  List<MeasurementTemplateFieldOptionModel> options)?  $default,) {final _that = this;
switch (_that) {
case _MeasurementTemplateFieldModel() when $default != null:
return $default(_that.id,_that.fieldKey,_that.labelEn,_that.labelUr,_that.sectionKey,_that.sectionLabelEn,_that.sectionLabelUr,_that.displayOrder,_that.isRequired,_that.inputType,_that.defaultUnit,_that.options);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeasurementTemplateFieldModel implements MeasurementTemplateFieldModel {
  const _MeasurementTemplateFieldModel({required this.id, @JsonKey(name: 'field_key') required this.fieldKey, @JsonKey(name: 'label_en') required this.labelEn, @JsonKey(name: 'label_ur') this.labelUr, @JsonKey(name: 'section_key') this.sectionKey, @JsonKey(name: 'section_label_en') this.sectionLabelEn, @JsonKey(name: 'section_label_ur') this.sectionLabelUr, @JsonKey(name: 'display_order') required this.displayOrder, @JsonKey(name: 'is_required') required this.isRequired, @JsonKey(name: 'input_type') required this.inputType, @JsonKey(name: 'default_unit') required this.defaultUnit, @JsonKey(includeFromJson: false, includeToJson: false) final  List<MeasurementTemplateFieldOptionModel> options = const <MeasurementTemplateFieldOptionModel>[]}): _options = options;
  factory _MeasurementTemplateFieldModel.fromJson(Map<String, dynamic> json) => _$MeasurementTemplateFieldModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'field_key') final  String fieldKey;
@override@JsonKey(name: 'label_en') final  String labelEn;
@override@JsonKey(name: 'label_ur') final  String? labelUr;
@override@JsonKey(name: 'section_key') final  String? sectionKey;
@override@JsonKey(name: 'section_label_en') final  String? sectionLabelEn;
@override@JsonKey(name: 'section_label_ur') final  String? sectionLabelUr;
@override@JsonKey(name: 'display_order') final  int displayOrder;
@override@JsonKey(name: 'is_required') final  bool isRequired;
@override@JsonKey(name: 'input_type') final  MeasurementFieldInputType inputType;
@override@JsonKey(name: 'default_unit') final  String defaultUnit;
 final  List<MeasurementTemplateFieldOptionModel> _options;
@override@JsonKey(includeFromJson: false, includeToJson: false) List<MeasurementTemplateFieldOptionModel> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}


/// Create a copy of MeasurementTemplateFieldModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeasurementTemplateFieldModelCopyWith<_MeasurementTemplateFieldModel> get copyWith => __$MeasurementTemplateFieldModelCopyWithImpl<_MeasurementTemplateFieldModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeasurementTemplateFieldModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeasurementTemplateFieldModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fieldKey, fieldKey) || other.fieldKey == fieldKey)&&(identical(other.labelEn, labelEn) || other.labelEn == labelEn)&&(identical(other.labelUr, labelUr) || other.labelUr == labelUr)&&(identical(other.sectionKey, sectionKey) || other.sectionKey == sectionKey)&&(identical(other.sectionLabelEn, sectionLabelEn) || other.sectionLabelEn == sectionLabelEn)&&(identical(other.sectionLabelUr, sectionLabelUr) || other.sectionLabelUr == sectionLabelUr)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&(identical(other.inputType, inputType) || other.inputType == inputType)&&(identical(other.defaultUnit, defaultUnit) || other.defaultUnit == defaultUnit)&&const DeepCollectionEquality().equals(other._options, _options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fieldKey,labelEn,labelUr,sectionKey,sectionLabelEn,sectionLabelUr,displayOrder,isRequired,inputType,defaultUnit,const DeepCollectionEquality().hash(_options));

@override
String toString() {
  return 'MeasurementTemplateFieldModel(id: $id, fieldKey: $fieldKey, labelEn: $labelEn, labelUr: $labelUr, sectionKey: $sectionKey, sectionLabelEn: $sectionLabelEn, sectionLabelUr: $sectionLabelUr, displayOrder: $displayOrder, isRequired: $isRequired, inputType: $inputType, defaultUnit: $defaultUnit, options: $options)';
}


}

/// @nodoc
abstract mixin class _$MeasurementTemplateFieldModelCopyWith<$Res> implements $MeasurementTemplateFieldModelCopyWith<$Res> {
  factory _$MeasurementTemplateFieldModelCopyWith(_MeasurementTemplateFieldModel value, $Res Function(_MeasurementTemplateFieldModel) _then) = __$MeasurementTemplateFieldModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'field_key') String fieldKey,@JsonKey(name: 'label_en') String labelEn,@JsonKey(name: 'label_ur') String? labelUr,@JsonKey(name: 'section_key') String? sectionKey,@JsonKey(name: 'section_label_en') String? sectionLabelEn,@JsonKey(name: 'section_label_ur') String? sectionLabelUr,@JsonKey(name: 'display_order') int displayOrder,@JsonKey(name: 'is_required') bool isRequired,@JsonKey(name: 'input_type') MeasurementFieldInputType inputType,@JsonKey(name: 'default_unit') String defaultUnit,@JsonKey(includeFromJson: false, includeToJson: false) List<MeasurementTemplateFieldOptionModel> options
});




}
/// @nodoc
class __$MeasurementTemplateFieldModelCopyWithImpl<$Res>
    implements _$MeasurementTemplateFieldModelCopyWith<$Res> {
  __$MeasurementTemplateFieldModelCopyWithImpl(this._self, this._then);

  final _MeasurementTemplateFieldModel _self;
  final $Res Function(_MeasurementTemplateFieldModel) _then;

/// Create a copy of MeasurementTemplateFieldModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fieldKey = null,Object? labelEn = null,Object? labelUr = freezed,Object? sectionKey = freezed,Object? sectionLabelEn = freezed,Object? sectionLabelUr = freezed,Object? displayOrder = null,Object? isRequired = null,Object? inputType = null,Object? defaultUnit = null,Object? options = null,}) {
  return _then(_MeasurementTemplateFieldModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fieldKey: null == fieldKey ? _self.fieldKey : fieldKey // ignore: cast_nullable_to_non_nullable
as String,labelEn: null == labelEn ? _self.labelEn : labelEn // ignore: cast_nullable_to_non_nullable
as String,labelUr: freezed == labelUr ? _self.labelUr : labelUr // ignore: cast_nullable_to_non_nullable
as String?,sectionKey: freezed == sectionKey ? _self.sectionKey : sectionKey // ignore: cast_nullable_to_non_nullable
as String?,sectionLabelEn: freezed == sectionLabelEn ? _self.sectionLabelEn : sectionLabelEn // ignore: cast_nullable_to_non_nullable
as String?,sectionLabelUr: freezed == sectionLabelUr ? _self.sectionLabelUr : sectionLabelUr // ignore: cast_nullable_to_non_nullable
as String?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,inputType: null == inputType ? _self.inputType : inputType // ignore: cast_nullable_to_non_nullable
as MeasurementFieldInputType,defaultUnit: null == defaultUnit ? _self.defaultUnit : defaultUnit // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<MeasurementTemplateFieldOptionModel>,
  ));
}


}

// dart format on
