// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bid_rejected.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BidRejected {

 String get reason; double get currentPrice;
/// Create a copy of BidRejected
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BidRejectedCopyWith<BidRejected> get copyWith => _$BidRejectedCopyWithImpl<BidRejected>(this as BidRejected, _$identity);

  /// Serializes this BidRejected to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BidRejected&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,currentPrice);

@override
String toString() {
  return 'BidRejected(reason: $reason, currentPrice: $currentPrice)';
}


}

/// @nodoc
abstract mixin class $BidRejectedCopyWith<$Res>  {
  factory $BidRejectedCopyWith(BidRejected value, $Res Function(BidRejected) _then) = _$BidRejectedCopyWithImpl;
@useResult
$Res call({
 String reason, double currentPrice
});




}
/// @nodoc
class _$BidRejectedCopyWithImpl<$Res>
    implements $BidRejectedCopyWith<$Res> {
  _$BidRejectedCopyWithImpl(this._self, this._then);

  final BidRejected _self;
  final $Res Function(BidRejected) _then;

/// Create a copy of BidRejected
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reason = null,Object? currentPrice = null,}) {
  return _then(BidRejected(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,currentPrice: null == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BidRejected].
extension BidRejectedPatterns on BidRejected {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BidRejected value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BidRejected() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BidRejected value)  $default,){
final _that = this;
switch (_that) {
case _BidRejected():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BidRejected value)?  $default,){
final _that = this;
switch (_that) {
case _BidRejected() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String reason,  double currentPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BidRejected() when $default != null:
return $default(_that.reason,_that.currentPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String reason,  double currentPrice)  $default,) {final _that = this;
switch (_that) {
case _BidRejected():
return $default(_that.reason,_that.currentPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String reason,  double currentPrice)?  $default,) {final _that = this;
switch (_that) {
case _BidRejected() when $default != null:
return $default(_that.reason,_that.currentPrice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BidRejected implements BidRejected {
  const _BidRejected({required this.reason, required this.currentPrice});
  factory _BidRejected.fromJson(Map<String, dynamic> json) => _$BidRejectedFromJson(json);

@override final  String reason;
@override final  double currentPrice;

/// Create a copy of BidRejected
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BidRejectedCopyWith<_BidRejected> get copyWith => __$BidRejectedCopyWithImpl<_BidRejected>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BidRejectedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BidRejected&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,currentPrice);

@override
String toString() {
  return 'BidRejected(reason: $reason, currentPrice: $currentPrice)';
}


}

/// @nodoc
abstract mixin class _$BidRejectedCopyWith<$Res> implements $BidRejectedCopyWith<$Res> {
  factory _$BidRejectedCopyWith(_BidRejected value, $Res Function(_BidRejected) _then) = __$BidRejectedCopyWithImpl;
@override @useResult
$Res call({
 String reason, double currentPrice
});




}
/// @nodoc
class __$BidRejectedCopyWithImpl<$Res>
    implements _$BidRejectedCopyWith<$Res> {
  __$BidRejectedCopyWithImpl(this._self, this._then);

  final _BidRejected _self;
  final $Res Function(_BidRejected) _then;

/// Create a copy of BidRejected
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reason = null,Object? currentPrice = null,}) {
  return _then(_BidRejected(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,currentPrice: null == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
