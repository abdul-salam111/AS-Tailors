// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'measurement_template_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MeasurementTemplateModel {

 String get id;@JsonKey(name: 'category_id') String get categoryId; String get name; int get version; List<MeasurementTemplateFieldModel> get fields;
/// Create a copy of MeasurementTemplateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeasurementTemplateModelCopyWith<MeasurementTemplateModel> get copyWith => _$MeasurementTemplateModelCopyWithImpl<MeasurementTemplateModel>(this as MeasurementTemplateModel, _$identity);

  /// Serializes this MeasurementTemplateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeasurementTemplateModel&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.fields, fields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoryId,name,version,const DeepCollectionEquality().hash(fields));

@override
String toString() {
  return 'MeasurementTemplateModel(id: $id, categoryId: $categoryId, name: $name, version: $version, fields: $fields)';
}


}

/// @nodoc
abstract mixin class $MeasurementTemplateModelCopyWith<$Res>  {
  factory $MeasurementTemplateModelCopyWith(MeasurementTemplateModel value, $Res Function(MeasurementTemplateModel) _then) = _$MeasurementTemplateModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'category_id') String categoryId, String name, int version, List<MeasurementTemplateFieldModel> fields
});




}
/// @nodoc
class _$MeasurementTemplateModelCopyWithImpl<$Res>
    implements $MeasurementTemplateModelCopyWith<$Res> {
  _$MeasurementTemplateModelCopyWithImpl(this._self, this._then);

  final MeasurementTemplateModel _self;
  final $Res Function(MeasurementTemplateModel) _then;

/// Create a copy of MeasurementTemplateModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? categoryId = null,Object? name = null,Object? version = null,Object? fields = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<MeasurementTemplateFieldModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [MeasurementTemplateModel].
extension MeasurementTemplateModelPatterns on MeasurementTemplateModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeasurementTemplateModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeasurementTemplateModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeasurementTemplateModel value)  $default,){
final _that = this;
switch (_that) {
case _MeasurementTemplateModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeasurementTemplateModel value)?  $default,){
final _that = this;
switch (_that) {
case _MeasurementTemplateModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'category_id')  String categoryId,  String name,  int version,  List<MeasurementTemplateFieldModel> fields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeasurementTemplateModel() when $default != null:
return $default(_that.id,_that.categoryId,_that.name,_that.version,_that.fields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'category_id')  String categoryId,  String name,  int version,  List<MeasurementTemplateFieldModel> fields)  $default,) {final _that = this;
switch (_that) {
case _MeasurementTemplateModel():
return $default(_that.id,_that.categoryId,_that.name,_that.version,_that.fields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'category_id')  String categoryId,  String name,  int version,  List<MeasurementTemplateFieldModel> fields)?  $default,) {final _that = this;
switch (_that) {
case _MeasurementTemplateModel() when $default != null:
return $default(_that.id,_that.categoryId,_that.name,_that.version,_that.fields);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeasurementTemplateModel implements MeasurementTemplateModel {
  const _MeasurementTemplateModel({required this.id, @JsonKey(name: 'category_id') required this.categoryId, required this.name, required this.version, final  List<MeasurementTemplateFieldModel> fields = const <MeasurementTemplateFieldModel>[]}): _fields = fields;
  factory _MeasurementTemplateModel.fromJson(Map<String, dynamic> json) => _$MeasurementTemplateModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'category_id') final  String categoryId;
@override final  String name;
@override final  int version;
 final  List<MeasurementTemplateFieldModel> _fields;
@override@JsonKey() List<MeasurementTemplateFieldModel> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}


/// Create a copy of MeasurementTemplateModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeasurementTemplateModelCopyWith<_MeasurementTemplateModel> get copyWith => __$MeasurementTemplateModelCopyWithImpl<_MeasurementTemplateModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeasurementTemplateModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeasurementTemplateModel&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other._fields, _fields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoryId,name,version,const DeepCollectionEquality().hash(_fields));

@override
String toString() {
  return 'MeasurementTemplateModel(id: $id, categoryId: $categoryId, name: $name, version: $version, fields: $fields)';
}


}

/// @nodoc
abstract mixin class _$MeasurementTemplateModelCopyWith<$Res> implements $MeasurementTemplateModelCopyWith<$Res> {
  factory _$MeasurementTemplateModelCopyWith(_MeasurementTemplateModel value, $Res Function(_MeasurementTemplateModel) _then) = __$MeasurementTemplateModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'category_id') String categoryId, String name, int version, List<MeasurementTemplateFieldModel> fields
});




}
/// @nodoc
class __$MeasurementTemplateModelCopyWithImpl<$Res>
    implements _$MeasurementTemplateModelCopyWith<$Res> {
  __$MeasurementTemplateModelCopyWithImpl(this._self, this._then);

  final _MeasurementTemplateModel _self;
  final $Res Function(_MeasurementTemplateModel) _then;

/// Create a copy of MeasurementTemplateModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? categoryId = null,Object? name = null,Object? version = null,Object? fields = null,}) {
  return _then(_MeasurementTemplateModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<MeasurementTemplateFieldModel>,
  ));
}


}

// dart format on
