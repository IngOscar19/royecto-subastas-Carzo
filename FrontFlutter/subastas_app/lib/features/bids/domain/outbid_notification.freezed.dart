// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outbid_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OutbidNotification {

 String get auctionId; double get amount; String get newBidderName; String get message;
/// Create a copy of OutbidNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutbidNotificationCopyWith<OutbidNotification> get copyWith => _$OutbidNotificationCopyWithImpl<OutbidNotification>(this as OutbidNotification, _$identity);

  /// Serializes this OutbidNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutbidNotification&&(identical(other.auctionId, auctionId) || other.auctionId == auctionId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.newBidderName, newBidderName) || other.newBidderName == newBidderName)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,auctionId,amount,newBidderName,message);

@override
String toString() {
  return 'OutbidNotification(auctionId: $auctionId, amount: $amount, newBidderName: $newBidderName, message: $message)';
}


}

/// @nodoc
abstract mixin class $OutbidNotificationCopyWith<$Res>  {
  factory $OutbidNotificationCopyWith(OutbidNotification value, $Res Function(OutbidNotification) _then) = _$OutbidNotificationCopyWithImpl;
@useResult
$Res call({
 String auctionId, double amount, String newBidderName, String message
});




}
/// @nodoc
class _$OutbidNotificationCopyWithImpl<$Res>
    implements $OutbidNotificationCopyWith<$Res> {
  _$OutbidNotificationCopyWithImpl(this._self, this._then);

  final OutbidNotification _self;
  final $Res Function(OutbidNotification) _then;

/// Create a copy of OutbidNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? auctionId = null,Object? amount = null,Object? newBidderName = null,Object? message = null,}) {
  return _then(OutbidNotification(
auctionId: null == auctionId ? _self.auctionId : auctionId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,newBidderName: null == newBidderName ? _self.newBidderName : newBidderName // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OutbidNotification].
extension OutbidNotificationPatterns on OutbidNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutbidNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutbidNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutbidNotification value)  $default,){
final _that = this;
switch (_that) {
case _OutbidNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutbidNotification value)?  $default,){
final _that = this;
switch (_that) {
case _OutbidNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String auctionId,  double amount,  String newBidderName,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutbidNotification() when $default != null:
return $default(_that.auctionId,_that.amount,_that.newBidderName,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String auctionId,  double amount,  String newBidderName,  String message)  $default,) {final _that = this;
switch (_that) {
case _OutbidNotification():
return $default(_that.auctionId,_that.amount,_that.newBidderName,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String auctionId,  double amount,  String newBidderName,  String message)?  $default,) {final _that = this;
switch (_that) {
case _OutbidNotification() when $default != null:
return $default(_that.auctionId,_that.amount,_that.newBidderName,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutbidNotification implements OutbidNotification {
  const _OutbidNotification({required this.auctionId, required this.amount, required this.newBidderName, required this.message});
  factory _OutbidNotification.fromJson(Map<String, dynamic> json) => _$OutbidNotificationFromJson(json);

@override final  String auctionId;
@override final  double amount;
@override final  String newBidderName;
@override final  String message;

/// Create a copy of OutbidNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutbidNotificationCopyWith<_OutbidNotification> get copyWith => __$OutbidNotificationCopyWithImpl<_OutbidNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutbidNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutbidNotification&&(identical(other.auctionId, auctionId) || other.auctionId == auctionId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.newBidderName, newBidderName) || other.newBidderName == newBidderName)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,auctionId,amount,newBidderName,message);

@override
String toString() {
  return 'OutbidNotification(auctionId: $auctionId, amount: $amount, newBidderName: $newBidderName, message: $message)';
}


}

/// @nodoc
abstract mixin class _$OutbidNotificationCopyWith<$Res> implements $OutbidNotificationCopyWith<$Res> {
  factory _$OutbidNotificationCopyWith(_OutbidNotification value, $Res Function(_OutbidNotification) _then) = __$OutbidNotificationCopyWithImpl;
@override @useResult
$Res call({
 String auctionId, double amount, String newBidderName, String message
});




}
/// @nodoc
class __$OutbidNotificationCopyWithImpl<$Res>
    implements _$OutbidNotificationCopyWith<$Res> {
  __$OutbidNotificationCopyWithImpl(this._self, this._then);

  final _OutbidNotification _self;
  final $Res Function(_OutbidNotification) _then;

/// Create a copy of OutbidNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? auctionId = null,Object? amount = null,Object? newBidderName = null,Object? message = null,}) {
  return _then(_OutbidNotification(
auctionId: null == auctionId ? _self.auctionId : auctionId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,newBidderName: null == newBidderName ? _self.newBidderName : newBidderName // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
