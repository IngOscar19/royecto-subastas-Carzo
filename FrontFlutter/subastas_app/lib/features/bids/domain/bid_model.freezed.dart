// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bid_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BidModel {

 String get bidId; String get userId; String get userName; double get amount; DateTime get createdAt;
/// Create a copy of BidModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BidModelCopyWith<BidModel> get copyWith => _$BidModelCopyWithImpl<BidModel>(this as BidModel, _$identity);

  /// Serializes this BidModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BidModel&&(identical(other.bidId, bidId) || other.bidId == bidId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bidId,userId,userName,amount,createdAt);

@override
String toString() {
  return 'BidModel(bidId: $bidId, userId: $userId, userName: $userName, amount: $amount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BidModelCopyWith<$Res>  {
  factory $BidModelCopyWith(BidModel value, $Res Function(BidModel) _then) = _$BidModelCopyWithImpl;
@useResult
$Res call({
 String bidId, String userId, String userName, double amount, DateTime createdAt
});




}
/// @nodoc
class _$BidModelCopyWithImpl<$Res>
    implements $BidModelCopyWith<$Res> {
  _$BidModelCopyWithImpl(this._self, this._then);

  final BidModel _self;
  final $Res Function(BidModel) _then;

/// Create a copy of BidModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bidId = null,Object? userId = null,Object? userName = null,Object? amount = null,Object? createdAt = null,}) {
  return _then(BidModel(
bidId: null == bidId ? _self.bidId : bidId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BidModel].
extension BidModelPatterns on BidModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BidModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BidModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BidModel value)  $default,){
final _that = this;
switch (_that) {
case _BidModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BidModel value)?  $default,){
final _that = this;
switch (_that) {
case _BidModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bidId,  String userId,  String userName,  double amount,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BidModel() when $default != null:
return $default(_that.bidId,_that.userId,_that.userName,_that.amount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bidId,  String userId,  String userName,  double amount,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _BidModel():
return $default(_that.bidId,_that.userId,_that.userName,_that.amount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bidId,  String userId,  String userName,  double amount,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BidModel() when $default != null:
return $default(_that.bidId,_that.userId,_that.userName,_that.amount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BidModel implements BidModel {
  const _BidModel({required this.bidId, required this.userId, required this.userName, required this.amount, required this.createdAt});
  factory _BidModel.fromJson(Map<String, dynamic> json) => _$BidModelFromJson(json);

@override final  String bidId;
@override final  String userId;
@override final  String userName;
@override final  double amount;
@override final  DateTime createdAt;

/// Create a copy of BidModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BidModelCopyWith<_BidModel> get copyWith => __$BidModelCopyWithImpl<_BidModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BidModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BidModel&&(identical(other.bidId, bidId) || other.bidId == bidId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bidId,userId,userName,amount,createdAt);

@override
String toString() {
  return 'BidModel(bidId: $bidId, userId: $userId, userName: $userName, amount: $amount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BidModelCopyWith<$Res> implements $BidModelCopyWith<$Res> {
  factory _$BidModelCopyWith(_BidModel value, $Res Function(_BidModel) _then) = __$BidModelCopyWithImpl;
@override @useResult
$Res call({
 String bidId, String userId, String userName, double amount, DateTime createdAt
});




}
/// @nodoc
class __$BidModelCopyWithImpl<$Res>
    implements _$BidModelCopyWith<$Res> {
  __$BidModelCopyWithImpl(this._self, this._then);

  final _BidModel _self;
  final $Res Function(_BidModel) _then;

/// Create a copy of BidModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bidId = null,Object? userId = null,Object? userName = null,Object? amount = null,Object? createdAt = null,}) {
  return _then(_BidModel(
bidId: null == bidId ? _self.bidId : bidId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
