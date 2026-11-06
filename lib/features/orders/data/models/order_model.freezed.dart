// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderModel {

 String get id;@JsonKey(name: 'shop_id') String get shopId;@JsonKey(name: 'customer_id') String get customerId;@JsonKey(name: 'order_number') int get orderNumber; String get status;@JsonKey(name: 'due_date') DateTime? get dueDate; String? get notes;@JsonKey(name: 'total_amount') double get totalAmount;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderModelCopyWith<OrderModel> get copyWith => _$OrderModelCopyWithImpl<OrderModel>(this as OrderModel, _$identity);

  /// Serializes this OrderModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,customerId,orderNumber,status,dueDate,notes,totalAmount,createdAt);

@override
String toString() {
  return 'OrderModel(id: $id, shopId: $shopId, customerId: $customerId, orderNumber: $orderNumber, status: $status, dueDate: $dueDate, notes: $notes, totalAmount: $totalAmount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $OrderModelCopyWith<$Res>  {
  factory $OrderModelCopyWith(OrderModel value, $Res Function(OrderModel) _then) = _$OrderModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId,@JsonKey(name: 'customer_id') String customerId,@JsonKey(name: 'order_number') int orderNumber, String status,@JsonKey(name: 'due_date') DateTime? dueDate, String? notes,@JsonKey(name: 'total_amount') double totalAmount,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$OrderModelCopyWithImpl<$Res>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._self, this._then);

  final OrderModel _self;
  final $Res Function(OrderModel) _then;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? customerId = null,Object? orderNumber = null,Object? status = null,Object? dueDate = freezed,Object? notes = freezed,Object? totalAmount = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderModel].
extension OrderModelPatterns on OrderModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderModel value)  $default,){
final _that = this;
switch (_that) {
case _OrderModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'order_number')  int orderNumber,  String status, @JsonKey(name: 'due_date')  DateTime? dueDate,  String? notes, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
return $default(_that.id,_that.shopId,_that.customerId,_that.orderNumber,_that.status,_that.dueDate,_that.notes,_that.totalAmount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'order_number')  int orderNumber,  String status, @JsonKey(name: 'due_date')  DateTime? dueDate,  String? notes, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _OrderModel():
return $default(_that.id,_that.shopId,_that.customerId,_that.orderNumber,_that.status,_that.dueDate,_that.notes,_that.totalAmount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'order_number')  int orderNumber,  String status, @JsonKey(name: 'due_date')  DateTime? dueDate,  String? notes, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
return $default(_that.id,_that.shopId,_that.customerId,_that.orderNumber,_that.status,_that.dueDate,_that.notes,_that.totalAmount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderModel implements OrderModel {
  const _OrderModel({required this.id, @JsonKey(name: 'shop_id') required this.shopId, @JsonKey(name: 'customer_id') required this.customerId, @JsonKey(name: 'order_number') required this.orderNumber, required this.status, @JsonKey(name: 'due_date') this.dueDate, this.notes, @JsonKey(name: 'total_amount') required this.totalAmount, @JsonKey(name: 'created_at') required this.createdAt});
  factory _OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'shop_id') final  String shopId;
@override@JsonKey(name: 'customer_id') final  String customerId;
@override@JsonKey(name: 'order_number') final  int orderNumber;
@override final  String status;
@override@JsonKey(name: 'due_date') final  DateTime? dueDate;
@override final  String? notes;
@override@JsonKey(name: 'total_amount') final  double totalAmount;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderModelCopyWith<_OrderModel> get copyWith => __$OrderModelCopyWithImpl<_OrderModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,customerId,orderNumber,status,dueDate,notes,totalAmount,createdAt);

@override
String toString() {
  return 'OrderModel(id: $id, shopId: $shopId, customerId: $customerId, orderNumber: $orderNumber, status: $status, dueDate: $dueDate, notes: $notes, totalAmount: $totalAmount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OrderModelCopyWith<$Res> implements $OrderModelCopyWith<$Res> {
  factory _$OrderModelCopyWith(_OrderModel value, $Res Function(_OrderModel) _then) = __$OrderModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId,@JsonKey(name: 'customer_id') String customerId,@JsonKey(name: 'order_number') int orderNumber, String status,@JsonKey(name: 'due_date') DateTime? dueDate, String? notes,@JsonKey(name: 'total_amount') double totalAmount,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$OrderModelCopyWithImpl<$Res>
    implements _$OrderModelCopyWith<$Res> {
  __$OrderModelCopyWithImpl(this._self, this._then);

  final _OrderModel _self;
  final $Res Function(_OrderModel) _then;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? customerId = null,Object? orderNumber = null,Object? status = null,Object? dueDate = freezed,Object? notes = freezed,Object? totalAmount = null,Object? createdAt = null,}) {
  return _then(_OrderModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
