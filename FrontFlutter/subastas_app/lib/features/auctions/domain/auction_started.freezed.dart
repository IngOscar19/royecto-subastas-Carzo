// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auction_started.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuctionStarted {

 String get auctionId; double get currentPrice;@JsonKey(name: 'endTime') int get endTime;
/// Create a copy of AuctionStarted
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuctionStartedCopyWith<AuctionStarted> get copyWith => _$AuctionStartedCopyWithImpl<AuctionStarted>(this as AuctionStarted, _$identity);

  /// Serializes this AuctionStarted to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuctionStarted&&(identical(other.auctionId, auctionId) || other.auctionId == auctionId)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,auctionId,currentPrice,endTime);

@override
String toString() {
  return 'AuctionStarted(auctionId: $auctionId, currentPrice: $currentPrice, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class $AuctionStartedCopyWith<$Res>  {
  factory $AuctionStartedCopyWith(AuctionStarted value, $Res Function(AuctionStarted) _then) = _$AuctionStartedCopyWithImpl;
@useResult
$Res call({
 String auctionId, double currentPrice,@JsonKey(name: 'endTime') int endTime
});




}
/// @nodoc
class _$AuctionStartedCopyWithImpl<$Res>
    implements $AuctionStartedCopyWith<$Res> {
  _$AuctionStartedCopyWithImpl(this._self, this._then);

  final AuctionStarted _self;
  final $Res Function(AuctionStarted) _then;

/// Create a copy of AuctionStarted
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? auctionId = null,Object? currentPrice = null,Object? endTime = null,}) {
  return _then(AuctionStarted(
auctionId: null == auctionId ? _self.auctionId : auctionId // ignore: cast_nullable_to_non_nullable
as String,currentPrice: null == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as double,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AuctionStarted].
extension AuctionStartedPatterns on AuctionStarted {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuctionStarted value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuctionStarted() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuctionStarted value)  $default,){
final _that = this;
switch (_that) {
case _AuctionStarted():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuctionStarted value)?  $default,){
final _that = this;
switch (_that) {
case _AuctionStarted() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String auctionId,  double currentPrice, @JsonKey(name: 'endTime')  int endTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuctionStarted() when $default != null:
return $default(_that.auctionId,_that.currentPrice,_that.endTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String auctionId,  double currentPrice, @JsonKey(name: 'endTime')  int endTime)  $default,) {final _that = this;
switch (_that) {
case _AuctionStarted():
return $default(_that.auctionId,_that.currentPrice,_that.endTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String auctionId,  double currentPrice, @JsonKey(name: 'endTime')  int endTime)?  $default,) {final _that = this;
switch (_that) {
case _AuctionStarted() when $default != null:
return $default(_that.auctionId,_that.currentPrice,_that.endTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuctionStarted implements AuctionStarted {
  const _AuctionStarted({required this.auctionId, required this.currentPrice, @JsonKey(name: 'endTime') required this.endTime});
  factory _AuctionStarted.fromJson(Map<String, dynamic> json) => _$AuctionStartedFromJson(json);

@override final  String auctionId;
@override final  double currentPrice;
@override@JsonKey(name: 'endTime') final  int endTime;

/// Create a copy of AuctionStarted
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuctionStartedCopyWith<_AuctionStarted> get copyWith => __$AuctionStartedCopyWithImpl<_AuctionStarted>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuctionStartedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuctionStarted&&(identical(other.auctionId, auctionId) || other.auctionId == auctionId)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,auctionId,currentPrice,endTime);

@override
String toString() {
  return 'AuctionStarted(auctionId: $auctionId, currentPrice: $currentPrice, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class _$AuctionStartedCopyWith<$Res> implements $AuctionStartedCopyWith<$Res> {
  factory _$AuctionStartedCopyWith(_AuctionStarted value, $Res Function(_AuctionStarted) _then) = __$AuctionStartedCopyWithImpl;
@override @useResult
$Res call({
 String auctionId, double currentPrice,@JsonKey(name: 'endTime') int endTime
});




}
/// @nodoc
class __$AuctionStartedCopyWithImpl<$Res>
    implements _$AuctionStartedCopyWith<$Res> {
  __$AuctionStartedCopyWithImpl(this._self, this._then);

  final _AuctionStarted _self;
  final $Res Function(_AuctionStarted) _then;

/// Create a copy of AuctionStarted
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? auctionId = null,Object? currentPrice = null,Object? endTime = null,}) {
  return _then(_AuctionStarted(
auctionId: null == auctionId ? _self.auctionId : auctionId // ignore: cast_nullable_to_non_nullable
as String,currentPrice: null == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as double,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
