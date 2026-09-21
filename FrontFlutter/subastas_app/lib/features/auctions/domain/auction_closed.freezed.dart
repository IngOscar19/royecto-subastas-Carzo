// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auction_closed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuctionClosed {

 String? get winnerId; String? get winnerName; double get finalPrice;
/// Create a copy of AuctionClosed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuctionClosedCopyWith<AuctionClosed> get copyWith => _$AuctionClosedCopyWithImpl<AuctionClosed>(this as AuctionClosed, _$identity);

  /// Serializes this AuctionClosed to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuctionClosed&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.winnerName, winnerName) || other.winnerName == winnerName)&&(identical(other.finalPrice, finalPrice) || other.finalPrice == finalPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,winnerId,winnerName,finalPrice);

@override
String toString() {
  return 'AuctionClosed(winnerId: $winnerId, winnerName: $winnerName, finalPrice: $finalPrice)';
}


}

/// @nodoc
abstract mixin class $AuctionClosedCopyWith<$Res>  {
  factory $AuctionClosedCopyWith(AuctionClosed value, $Res Function(AuctionClosed) _then) = _$AuctionClosedCopyWithImpl;
@useResult
$Res call({
 String? winnerId, String? winnerName, double finalPrice
});




}
/// @nodoc
class _$AuctionClosedCopyWithImpl<$Res>
    implements $AuctionClosedCopyWith<$Res> {
  _$AuctionClosedCopyWithImpl(this._self, this._then);

  final AuctionClosed _self;
  final $Res Function(AuctionClosed) _then;

/// Create a copy of AuctionClosed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? winnerId = freezed,Object? winnerName = freezed,Object? finalPrice = null,}) {
  return _then(AuctionClosed(
winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,winnerName: freezed == winnerName ? _self.winnerName : winnerName // ignore: cast_nullable_to_non_nullable
as String?,finalPrice: null == finalPrice ? _self.finalPrice : finalPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AuctionClosed].
extension AuctionClosedPatterns on AuctionClosed {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuctionClosed value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuctionClosed() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuctionClosed value)  $default,){
final _that = this;
switch (_that) {
case _AuctionClosed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuctionClosed value)?  $default,){
final _that = this;
switch (_that) {
case _AuctionClosed() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? winnerId,  String? winnerName,  double finalPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuctionClosed() when $default != null:
return $default(_that.winnerId,_that.winnerName,_that.finalPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? winnerId,  String? winnerName,  double finalPrice)  $default,) {final _that = this;
switch (_that) {
case _AuctionClosed():
return $default(_that.winnerId,_that.winnerName,_that.finalPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? winnerId,  String? winnerName,  double finalPrice)?  $default,) {final _that = this;
switch (_that) {
case _AuctionClosed() when $default != null:
return $default(_that.winnerId,_that.winnerName,_that.finalPrice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuctionClosed implements AuctionClosed {
  const _AuctionClosed({this.winnerId, this.winnerName, required this.finalPrice});
  factory _AuctionClosed.fromJson(Map<String, dynamic> json) => _$AuctionClosedFromJson(json);

@override final  String? winnerId;
@override final  String? winnerName;
@override final  double finalPrice;

/// Create a copy of AuctionClosed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuctionClosedCopyWith<_AuctionClosed> get copyWith => __$AuctionClosedCopyWithImpl<_AuctionClosed>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuctionClosedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuctionClosed&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.winnerName, winnerName) || other.winnerName == winnerName)&&(identical(other.finalPrice, finalPrice) || other.finalPrice == finalPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,winnerId,winnerName,finalPrice);

@override
String toString() {
  return 'AuctionClosed(winnerId: $winnerId, winnerName: $winnerName, finalPrice: $finalPrice)';
}


}

/// @nodoc
abstract mixin class _$AuctionClosedCopyWith<$Res> implements $AuctionClosedCopyWith<$Res> {
  factory _$AuctionClosedCopyWith(_AuctionClosed value, $Res Function(_AuctionClosed) _then) = __$AuctionClosedCopyWithImpl;
@override @useResult
$Res call({
 String? winnerId, String? winnerName, double finalPrice
});




}
/// @nodoc
class __$AuctionClosedCopyWithImpl<$Res>
    implements _$AuctionClosedCopyWith<$Res> {
  __$AuctionClosedCopyWithImpl(this._self, this._then);

  final _AuctionClosed _self;
  final $Res Function(_AuctionClosed) _then;

/// Create a copy of AuctionClosed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? winnerId = freezed,Object? winnerName = freezed,Object? finalPrice = null,}) {
  return _then(_AuctionClosed(
winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,winnerName: freezed == winnerName ? _self.winnerName : winnerName // ignore: cast_nullable_to_non_nullable
as String?,finalPrice: null == finalPrice ? _self.finalPrice : finalPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
