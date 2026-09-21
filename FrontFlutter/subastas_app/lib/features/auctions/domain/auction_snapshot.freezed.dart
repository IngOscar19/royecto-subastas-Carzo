// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auction_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuctionSnapshot {

 String get auctionId; double get currentPrice;@JsonKey(name: 'endTime') int get endTime; List<BidModel> get lastBids; String get status;
/// Create a copy of AuctionSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuctionSnapshotCopyWith<AuctionSnapshot> get copyWith => _$AuctionSnapshotCopyWithImpl<AuctionSnapshot>(this as AuctionSnapshot, _$identity);

  /// Serializes this AuctionSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuctionSnapshot&&(identical(other.auctionId, auctionId) || other.auctionId == auctionId)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other.lastBids, lastBids)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,auctionId,currentPrice,endTime,const DeepCollectionEquality().hash(lastBids),status);

@override
String toString() {
  return 'AuctionSnapshot(auctionId: $auctionId, currentPrice: $currentPrice, endTime: $endTime, lastBids: $lastBids, status: $status)';
}


}

/// @nodoc
abstract mixin class $AuctionSnapshotCopyWith<$Res>  {
  factory $AuctionSnapshotCopyWith(AuctionSnapshot value, $Res Function(AuctionSnapshot) _then) = _$AuctionSnapshotCopyWithImpl;
@useResult
$Res call({
 String auctionId, double currentPrice,@JsonKey(name: 'endTime') int endTime, List<BidModel> lastBids, String status
});




}
/// @nodoc
class _$AuctionSnapshotCopyWithImpl<$Res>
    implements $AuctionSnapshotCopyWith<$Res> {
  _$AuctionSnapshotCopyWithImpl(this._self, this._then);

  final AuctionSnapshot _self;
  final $Res Function(AuctionSnapshot) _then;

/// Create a copy of AuctionSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? auctionId = null,Object? currentPrice = null,Object? endTime = null,Object? lastBids = null,Object? status = null,}) {
  return _then(AuctionSnapshot(
auctionId: null == auctionId ? _self.auctionId : auctionId // ignore: cast_nullable_to_non_nullable
as String,currentPrice: null == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as double,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as int,lastBids: null == lastBids ? _self.lastBids : lastBids // ignore: cast_nullable_to_non_nullable
as List<BidModel>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuctionSnapshot].
extension AuctionSnapshotPatterns on AuctionSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuctionSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuctionSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuctionSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _AuctionSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuctionSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _AuctionSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String auctionId,  double currentPrice, @JsonKey(name: 'endTime')  int endTime,  List<BidModel> lastBids,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuctionSnapshot() when $default != null:
return $default(_that.auctionId,_that.currentPrice,_that.endTime,_that.lastBids,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String auctionId,  double currentPrice, @JsonKey(name: 'endTime')  int endTime,  List<BidModel> lastBids,  String status)  $default,) {final _that = this;
switch (_that) {
case _AuctionSnapshot():
return $default(_that.auctionId,_that.currentPrice,_that.endTime,_that.lastBids,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String auctionId,  double currentPrice, @JsonKey(name: 'endTime')  int endTime,  List<BidModel> lastBids,  String status)?  $default,) {final _that = this;
switch (_that) {
case _AuctionSnapshot() when $default != null:
return $default(_that.auctionId,_that.currentPrice,_that.endTime,_that.lastBids,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuctionSnapshot implements AuctionSnapshot {
  const _AuctionSnapshot({required this.auctionId, required this.currentPrice, @JsonKey(name: 'endTime') required this.endTime, required  List<BidModel> lastBids, required this.status}): _lastBids = lastBids;
  factory _AuctionSnapshot.fromJson(Map<String, dynamic> json) => _$AuctionSnapshotFromJson(json);

@override final  String auctionId;
@override final  double currentPrice;
@override@JsonKey(name: 'endTime') final  int endTime;
 final  List<BidModel> _lastBids;
@override List<BidModel> get lastBids {
  if (_lastBids is EqualUnmodifiableListView) return _lastBids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lastBids);
}

@override final  String status;

/// Create a copy of AuctionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuctionSnapshotCopyWith<_AuctionSnapshot> get copyWith => __$AuctionSnapshotCopyWithImpl<_AuctionSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuctionSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuctionSnapshot&&(identical(other.auctionId, auctionId) || other.auctionId == auctionId)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other._lastBids, _lastBids)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,auctionId,currentPrice,endTime,const DeepCollectionEquality().hash(_lastBids),status);

@override
String toString() {
  return 'AuctionSnapshot(auctionId: $auctionId, currentPrice: $currentPrice, endTime: $endTime, lastBids: $lastBids, status: $status)';
}


}

/// @nodoc
abstract mixin class _$AuctionSnapshotCopyWith<$Res> implements $AuctionSnapshotCopyWith<$Res> {
  factory _$AuctionSnapshotCopyWith(_AuctionSnapshot value, $Res Function(_AuctionSnapshot) _then) = __$AuctionSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String auctionId, double currentPrice,@JsonKey(name: 'endTime') int endTime, List<BidModel> lastBids, String status
});




}
/// @nodoc
class __$AuctionSnapshotCopyWithImpl<$Res>
    implements _$AuctionSnapshotCopyWith<$Res> {
  __$AuctionSnapshotCopyWithImpl(this._self, this._then);

  final _AuctionSnapshot _self;
  final $Res Function(_AuctionSnapshot) _then;

/// Create a copy of AuctionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? auctionId = null,Object? currentPrice = null,Object? endTime = null,Object? lastBids = null,Object? status = null,}) {
  return _then(_AuctionSnapshot(
auctionId: null == auctionId ? _self.auctionId : auctionId // ignore: cast_nullable_to_non_nullable
as String,currentPrice: null == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as double,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as int,lastBids: null == lastBids ? _self._lastBids : lastBids // ignore: cast_nullable_to_non_nullable
as List<BidModel>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
