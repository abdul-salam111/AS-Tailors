// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'measurement_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MeasurementProfileModel {

 String get id;@JsonKey(name: 'shop_id') String get shopId;@JsonKey(name: 'customer_id') String get customerId;@JsonKey(name: 'template_id') String get templateId; String? get name; int get version; String get unit;@JsonKey(name: 'measured_at') DateTime get measuredAt; String? get notes;@JsonKey(name: 'created_at') DateTime get createdAt;/// Not a column on `measurement_profiles` — attached via `copyWith`
/// from a joined `measurement_templates(name)` select, same pattern as
/// `values`/`imageUrls` below.
 String? get templateName;@JsonKey(includeFromJson: false, includeToJson: false) List<MeasurementValueModel> get values; List<String> get imageUrls;
/// Create a copy of MeasurementProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeasurementProfileModelCopyWith<MeasurementProfileModel> get copyWith => _$MeasurementProfileModelCopyWithImpl<MeasurementProfileModel>(this as MeasurementProfileModel, _$identity);

  /// Serializes this MeasurementProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeasurementProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.templateName, templateName) || other.templateName == templateName)&&const DeepCollectionEquality().equals(other.values, values)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,customerId,templateId,name,version,unit,measuredAt,notes,createdAt,templateName,const DeepCollectionEquality().hash(values),const DeepCollectionEquality().hash(imageUrls));

@override
String toString() {
  return 'MeasurementProfileModel(id: $id, shopId: $shopId, customerId: $customerId, templateId: $templateId, name: $name, version: $version, unit: $unit, measuredAt: $measuredAt, notes: $notes, createdAt: $createdAt, templateName: $templateName, values: $values, imageUrls: $imageUrls)';
}


}

/// @nodoc
abstract mixin class $MeasurementProfileModelCopyWith<$Res>  {
  factory $MeasurementProfileModelCopyWith(MeasurementProfileModel value, $Res Function(MeasurementProfileModel) _then) = _$MeasurementProfileModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId,@JsonKey(name: 'customer_id') String customerId,@JsonKey(name: 'template_id') String templateId, String? name, int version, String unit,@JsonKey(name: 'measured_at') DateTime measuredAt, String? notes,@JsonKey(name: 'created_at') DateTime createdAt, String? templateName,@JsonKey(includeFromJson: false, includeToJson: false) List<MeasurementValueModel> values, List<String> imageUrls
});




}
/// @nodoc
class _$MeasurementProfileModelCopyWithImpl<$Res>
    implements $MeasurementProfileModelCopyWith<$Res> {
  _$MeasurementProfileModelCopyWithImpl(this._self, this._then);

  final MeasurementProfileModel _self;
  final $Res Function(MeasurementProfileModel) _then;

/// Create a copy of MeasurementProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? customerId = null,Object? templateId = null,Object? name = freezed,Object? version = null,Object? unit = null,Object? measuredAt = null,Object? notes = freezed,Object? createdAt = null,Object? templateName = freezed,Object? values = null,Object? imageUrls = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,measuredAt: null == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,templateName: freezed == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String?,values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as List<MeasurementValueModel>,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MeasurementProfileModel].
extension MeasurementProfileModelPatterns on MeasurementProfileModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeasurementProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeasurementProfileModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeasurementProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _MeasurementProfileModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeasurementProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _MeasurementProfileModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'template_id')  String templateId,  String? name,  int version,  String unit, @JsonKey(name: 'measured_at')  DateTime measuredAt,  String? notes, @JsonKey(name: 'created_at')  DateTime createdAt,  String? templateName, @JsonKey(includeFromJson: false, includeToJson: false)  List<MeasurementValueModel> values,  List<String> imageUrls)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeasurementProfileModel() when $default != null:
return $default(_that.id,_that.shopId,_that.customerId,_that.templateId,_that.name,_that.version,_that.unit,_that.measuredAt,_that.notes,_that.createdAt,_that.templateName,_that.values,_that.imageUrls);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'template_id')  String templateId,  String? name,  int version,  String unit, @JsonKey(name: 'measured_at')  DateTime measuredAt,  String? notes, @JsonKey(name: 'created_at')  DateTime createdAt,  String? templateName, @JsonKey(includeFromJson: false, includeToJson: false)  List<MeasurementValueModel> values,  List<String> imageUrls)  $default,) {final _that = this;
switch (_that) {
case _MeasurementProfileModel():
return $default(_that.id,_that.shopId,_that.customerId,_that.templateId,_that.name,_that.version,_that.unit,_that.measuredAt,_that.notes,_that.createdAt,_that.templateName,_that.values,_that.imageUrls);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'template_id')  String templateId,  String? name,  int version,  String unit, @JsonKey(name: 'measured_at')  DateTime measuredAt,  String? notes, @JsonKey(name: 'created_at')  DateTime createdAt,  String? templateName, @JsonKey(includeFromJson: false, includeToJson: false)  List<MeasurementValueModel> values,  List<String> imageUrls)?  $default,) {final _that = this;
switch (_that) {
case _MeasurementProfileModel() when $default != null:
return $default(_that.id,_that.shopId,_that.customerId,_that.templateId,_that.name,_that.version,_that.unit,_that.measuredAt,_that.notes,_that.createdAt,_that.templateName,_that.values,_that.imageUrls);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeasurementProfileModel implements MeasurementProfileModel {
  const _MeasurementProfileModel({required this.id, @JsonKey(name: 'shop_id') required this.shopId, @JsonKey(name: 'customer_id') required this.customerId, @JsonKey(name: 'template_id') required this.templateId, this.name, required this.version, required this.unit, @JsonKey(name: 'measured_at') required this.measuredAt, this.notes, @JsonKey(name: 'created_at') required this.createdAt, this.templateName, @JsonKey(includeFromJson: false, includeToJson: false) final  List<MeasurementValueModel> values = const <MeasurementValueModel>[], final  List<String> imageUrls = const <String>[]}): _values = values,_imageUrls = imageUrls;
  factory _MeasurementProfileModel.fromJson(Map<String, dynamic> json) => _$MeasurementProfileModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'shop_id') final  String shopId;
@override@JsonKey(name: 'customer_id') final  String customerId;
@override@JsonKey(name: 'template_id') final  String templateId;
@override final  String? name;
@override final  int version;
@override final  String unit;
@override@JsonKey(name: 'measured_at') final  DateTime measuredAt;
@override final  String? notes;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
/// Not a column on `measurement_profiles` — attached via `copyWith`
/// from a joined `measurement_templates(name)` select, same pattern as
/// `values`/`imageUrls` below.
@override final  String? templateName;
 final  List<MeasurementValueModel> _values;
@override@JsonKey(includeFromJson: false, includeToJson: false) List<MeasurementValueModel> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}

 final  List<String> _imageUrls;
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}


/// Create a copy of MeasurementProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeasurementProfileModelCopyWith<_MeasurementProfileModel> get copyWith => __$MeasurementProfileModelCopyWithImpl<_MeasurementProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeasurementProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeasurementProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.templateName, templateName) || other.templateName == templateName)&&const DeepCollectionEquality().equals(other._values, _values)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,customerId,templateId,name,version,unit,measuredAt,notes,createdAt,templateName,const DeepCollectionEquality().hash(_values),const DeepCollectionEquality().hash(_imageUrls));

@override
String toString() {
  return 'MeasurementProfileModel(id: $id, shopId: $shopId, customerId: $customerId, templateId: $templateId, name: $name, version: $version, unit: $unit, measuredAt: $measuredAt, notes: $notes, createdAt: $createdAt, templateName: $templateName, values: $values, imageUrls: $imageUrls)';
}


}

/// @nodoc
abstract mixin class _$MeasurementProfileModelCopyWith<$Res> implements $MeasurementProfileModelCopyWith<$Res> {
  factory _$MeasurementProfileModelCopyWith(_MeasurementProfileModel value, $Res Function(_MeasurementProfileModel) _then) = __$MeasurementProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId,@JsonKey(name: 'customer_id') String customerId,@JsonKey(name: 'template_id') String templateId, String? name, int version, String unit,@JsonKey(name: 'measured_at') DateTime measuredAt, String? notes,@JsonKey(name: 'created_at') DateTime createdAt, String? templateName,@JsonKey(includeFromJson: false, includeToJson: false) List<MeasurementValueModel> values, List<String> imageUrls
});




}
/// @nodoc
class __$MeasurementProfileModelCopyWithImpl<$Res>
    implements _$MeasurementProfileModelCopyWith<$Res> {
  __$MeasurementProfileModelCopyWithImpl(this._self, this._then);

  final _MeasurementProfileModel _self;
  final $Res Function(_MeasurementProfileModel) _then;

/// Create a copy of MeasurementProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? customerId = null,Object? templateId = null,Object? name = freezed,Object? version = null,Object? unit = null,Object? measuredAt = null,Object? notes = freezed,Object? createdAt = null,Object? templateName = freezed,Object? values = null,Object? imageUrls = null,}) {
  return _then(_MeasurementProfileModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,measuredAt: null == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,templateName: freezed == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String?,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<MeasurementValueModel>,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
