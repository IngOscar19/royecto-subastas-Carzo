// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Auction {

 String get id;@JsonKey(name: 'seller_id') String? get sellerId;@JsonKey(name: 'winner_id') String? get winnerId;@JsonKey(name: 'seller_name') String? get sellerName;@JsonKey(name: 'seller_email') String? get sellerEmail;@JsonKey(name: 'seller_phone') String? get sellerPhone; String get title; String? get description; List<String> get images;@JsonKey(name: 'starting_price') double get startingPrice;@JsonKey(name: 'current_price') double get currentPrice;@JsonKey(name: 'min_increment') double get minIncrement;@JsonKey(name: 'buy_out_price') double? get buyOutPrice;@JsonKey(name: 'start_time') DateTime get startTime;@JsonKey(name: 'end_time') DateTime get endTime; String get status;
/// Create a copy of Auction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuctionCopyWith<Auction> get copyWith => _$AuctionCopyWithImpl<Auction>(this as Auction, _$identity);

  /// Serializes this Auction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Auction&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.sellerName, sellerName) || other.sellerName == sellerName)&&(identical(other.sellerEmail, sellerEmail) || other.sellerEmail == sellerEmail)&&(identical(other.sellerPhone, sellerPhone) || other.sellerPhone == sellerPhone)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.startingPrice, startingPrice) || other.startingPrice == startingPrice)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice)&&(identical(other.minIncrement, minIncrement) || other.minIncrement == minIncrement)&&(identical(other.buyOutPrice, buyOutPrice) || other.buyOutPrice == buyOutPrice)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sellerId,winnerId,sellerName,sellerEmail,sellerPhone,title,description,const DeepCollectionEquality().hash(images),startingPrice,currentPrice,minIncrement,buyOutPrice,startTime,endTime,status);

@override
String toString() {
  return 'Auction(id: $id, sellerId: $sellerId, winnerId: $winnerId, sellerName: $sellerName, sellerEmail: $sellerEmail, sellerPhone: $sellerPhone, title: $title, description: $description, images: $images, startingPrice: $startingPrice, currentPrice: $currentPrice, minIncrement: $minIncrement, buyOutPrice: $buyOutPrice, startTime: $startTime, endTime: $endTime, status: $status)';
}


}

/// @nodoc
abstract mixin class $AuctionCopyWith<$Res>  {
  factory $AuctionCopyWith(Auction value, $Res Function(Auction) _then) = _$AuctionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'seller_id') String? sellerId,@JsonKey(name: 'winner_id') String? winnerId,@JsonKey(name: 'seller_name') String? sellerName,@JsonKey(name: 'seller_email') String? sellerEmail,@JsonKey(name: 'seller_phone') String? sellerPhone, String title, String? description, List<String> images,@JsonKey(name: 'starting_price') double startingPrice,@JsonKey(name: 'current_price') double currentPrice,@JsonKey(name: 'min_increment') double minIncrement,@JsonKey(name: 'buy_out_price') double? buyOutPrice,@JsonKey(name: 'start_time') DateTime startTime,@JsonKey(name: 'end_time') DateTime endTime, String status
});




}
/// @nodoc
class _$AuctionCopyWithImpl<$Res>
    implements $AuctionCopyWith<$Res> {
  _$AuctionCopyWithImpl(this._self, this._then);

  final Auction _self;
  final $Res Function(Auction) _then;

/// Create a copy of Auction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sellerId = freezed,Object? winnerId = freezed,Object? sellerName = freezed,Object? sellerEmail = freezed,Object? sellerPhone = freezed,Object? title = null,Object? description = freezed,Object? images = null,Object? startingPrice = null,Object? currentPrice = null,Object? minIncrement = null,Object? buyOutPrice = freezed,Object? startTime = null,Object? endTime = null,Object? status = null,}) {
  return _then(Auction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: freezed == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String?,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,sellerName: freezed == sellerName ? _self.sellerName : sellerName // ignore: cast_nullable_to_non_nullable
as String?,sellerEmail: freezed == sellerEmail ? _self.sellerEmail : sellerEmail // ignore: cast_nullable_to_non_nullable
as String?,sellerPhone: freezed == sellerPhone ? _self.sellerPhone : sellerPhone // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,startingPrice: null == startingPrice ? _self.startingPrice : startingPrice // ignore: cast_nullable_to_non_nullable
as double,currentPrice: null == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as double,minIncrement: null == minIncrement ? _self.minIncrement : minIncrement // ignore: cast_nullable_to_non_nullable
as double,buyOutPrice: freezed == buyOutPrice ? _self.buyOutPrice : buyOutPrice // ignore: cast_nullable_to_non_nullable
as double?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Auction].
extension AuctionPatterns on Auction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Auction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Auction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Auction value)  $default,){
final _that = this;
switch (_that) {
case _Auction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Auction value)?  $default,){
final _that = this;
switch (_that) {
case _Auction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'seller_id')  String? sellerId, @JsonKey(name: 'winner_id')  String? winnerId, @JsonKey(name: 'seller_name')  String? sellerName, @JsonKey(name: 'seller_email')  String? sellerEmail, @JsonKey(name: 'seller_phone')  String? sellerPhone,  String title,  String? description,  List<String> images, @JsonKey(name: 'starting_price')  double startingPrice, @JsonKey(name: 'current_price')  double currentPrice, @JsonKey(name: 'min_increment')  double minIncrement, @JsonKey(name: 'buy_out_price')  double? buyOutPrice, @JsonKey(name: 'start_time')  DateTime startTime, @JsonKey(name: 'end_time')  DateTime endTime,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Auction() when $default != null:
return $default(_that.id,_that.sellerId,_that.winnerId,_that.sellerName,_that.sellerEmail,_that.sellerPhone,_that.title,_that.description,_that.images,_that.startingPrice,_that.currentPrice,_that.minIncrement,_that.buyOutPrice,_that.startTime,_that.endTime,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'seller_id')  String? sellerId, @JsonKey(name: 'winner_id')  String? winnerId, @JsonKey(name: 'seller_name')  String? sellerName, @JsonKey(name: 'seller_email')  String? sellerEmail, @JsonKey(name: 'seller_phone')  String? sellerPhone,  String title,  String? description,  List<String> images, @JsonKey(name: 'starting_price')  double startingPrice, @JsonKey(name: 'current_price')  double currentPrice, @JsonKey(name: 'min_increment')  double minIncrement, @JsonKey(name: 'buy_out_price')  double? buyOutPrice, @JsonKey(name: 'start_time')  DateTime startTime, @JsonKey(name: 'end_time')  DateTime endTime,  String status)  $default,) {final _that = this;
switch (_that) {
case _Auction():
return $default(_that.id,_that.sellerId,_that.winnerId,_that.sellerName,_that.sellerEmail,_that.sellerPhone,_that.title,_that.description,_that.images,_that.startingPrice,_that.currentPrice,_that.minIncrement,_that.buyOutPrice,_that.startTime,_that.endTime,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'seller_id')  String? sellerId, @JsonKey(name: 'winner_id')  String? winnerId, @JsonKey(name: 'seller_name')  String? sellerName, @JsonKey(name: 'seller_email')  String? sellerEmail, @JsonKey(name: 'seller_phone')  String? sellerPhone,  String title,  String? description,  List<String> images, @JsonKey(name: 'starting_price')  double startingPrice, @JsonKey(name: 'current_price')  double currentPrice, @JsonKey(name: 'min_increment')  double minIncrement, @JsonKey(name: 'buy_out_price')  double? buyOutPrice, @JsonKey(name: 'start_time')  DateTime startTime, @JsonKey(name: 'end_time')  DateTime endTime,  String status)?  $default,) {final _that = this;
switch (_that) {
case _Auction() when $default != null:
return $default(_that.id,_that.sellerId,_that.winnerId,_that.sellerName,_that.sellerEmail,_that.sellerPhone,_that.title,_that.description,_that.images,_that.startingPrice,_that.currentPrice,_that.minIncrement,_that.buyOutPrice,_that.startTime,_that.endTime,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Auction implements Auction {
  const _Auction({required this.id, @JsonKey(name: 'seller_id') this.sellerId, @JsonKey(name: 'winner_id') this.winnerId, @JsonKey(name: 'seller_name') this.sellerName, @JsonKey(name: 'seller_email') this.sellerEmail, @JsonKey(name: 'seller_phone') this.sellerPhone, required this.title, this.description, required  List<String> images, @JsonKey(name: 'starting_price') required this.startingPrice, @JsonKey(name: 'current_price') required this.currentPrice, @JsonKey(name: 'min_increment') required this.minIncrement, @JsonKey(name: 'buy_out_price') this.buyOutPrice, @JsonKey(name: 'start_time') required this.startTime, @JsonKey(name: 'end_time') required this.endTime, required this.status}): _images = images;
  factory _Auction.fromJson(Map<String, dynamic> json) => _$AuctionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'seller_id') final  String? sellerId;
@override@JsonKey(name: 'winner_id') final  String? winnerId;
@override@JsonKey(name: 'seller_name') final  String? sellerName;
@override@JsonKey(name: 'seller_email') final  String? sellerEmail;
@override@JsonKey(name: 'seller_phone') final  String? sellerPhone;
@override final  String title;
@override final  String? description;
 final  List<String> _images;
@override List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey(name: 'starting_price') final  double startingPrice;
@override@JsonKey(name: 'current_price') final  double currentPrice;
@override@JsonKey(name: 'min_increment') final  double minIncrement;
@override@JsonKey(name: 'buy_out_price') final  double? buyOutPrice;
@override@JsonKey(name: 'start_time') final  DateTime startTime;
@override@JsonKey(name: 'end_time') final  DateTime endTime;
@override final  String status;

/// Create a copy of Auction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuctionCopyWith<_Auction> get copyWith => __$AuctionCopyWithImpl<_Auction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuctionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Auction&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.sellerName, sellerName) || other.sellerName == sellerName)&&(identical(other.sellerEmail, sellerEmail) || other.sellerEmail == sellerEmail)&&(identical(other.sellerPhone, sellerPhone) || other.sellerPhone == sellerPhone)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.startingPrice, startingPrice) || other.startingPrice == startingPrice)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice)&&(identical(other.minIncrement, minIncrement) || other.minIncrement == minIncrement)&&(identical(other.buyOutPrice, buyOutPrice) || other.buyOutPrice == buyOutPrice)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sellerId,winnerId,sellerName,sellerEmail,sellerPhone,title,description,const DeepCollectionEquality().hash(_images),startingPrice,currentPrice,minIncrement,buyOutPrice,startTime,endTime,status);

@override
String toString() {
  return 'Auction(id: $id, sellerId: $sellerId, winnerId: $winnerId, sellerName: $sellerName, sellerEmail: $sellerEmail, sellerPhone: $sellerPhone, title: $title, description: $description, images: $images, startingPrice: $startingPrice, currentPrice: $currentPrice, minIncrement: $minIncrement, buyOutPrice: $buyOutPrice, startTime: $startTime, endTime: $endTime, status: $status)';
}


}

/// @nodoc
abstract mixin class _$AuctionCopyWith<$Res> implements $AuctionCopyWith<$Res> {
  factory _$AuctionCopyWith(_Auction value, $Res Function(_Auction) _then) = __$AuctionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'seller_id') String? sellerId,@JsonKey(name: 'winner_id') String? winnerId,@JsonKey(name: 'seller_name') String? sellerName,@JsonKey(name: 'seller_email') String? sellerEmail,@JsonKey(name: 'seller_phone') String? sellerPhone, String title, String? description, List<String> images,@JsonKey(name: 'starting_price') double startingPrice,@JsonKey(name: 'current_price') double currentPrice,@JsonKey(name: 'min_increment') double minIncrement,@JsonKey(name: 'buy_out_price') double? buyOutPrice,@JsonKey(name: 'start_time') DateTime startTime,@JsonKey(name: 'end_time') DateTime endTime, String status
});




}
/// @nodoc
class __$AuctionCopyWithImpl<$Res>
    implements _$AuctionCopyWith<$Res> {
  __$AuctionCopyWithImpl(this._self, this._then);

  final _Auction _self;
  final $Res Function(_Auction) _then;

/// Create a copy of Auction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sellerId = freezed,Object? winnerId = freezed,Object? sellerName = freezed,Object? sellerEmail = freezed,Object? sellerPhone = freezed,Object? title = null,Object? description = freezed,Object? images = null,Object? startingPrice = null,Object? currentPrice = null,Object? minIncrement = null,Object? buyOutPrice = freezed,Object? startTime = null,Object? endTime = null,Object? status = null,}) {
  return _then(_Auction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: freezed == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String?,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,sellerName: freezed == sellerName ? _self.sellerName : sellerName // ignore: cast_nullable_to_non_nullable
as String?,sellerEmail: freezed == sellerEmail ? _self.sellerEmail : sellerEmail // ignore: cast_nullable_to_non_nullable
as String?,sellerPhone: freezed == sellerPhone ? _self.sellerPhone : sellerPhone // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,startingPrice: null == startingPrice ? _self.startingPrice : startingPrice // ignore: cast_nullable_to_non_nullable
as double,currentPrice: null == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as double,minIncrement: null == minIncrement ? _self.minIncrement : minIncrement // ignore: cast_nullable_to_non_nullable
as double,buyOutPrice: freezed == buyOutPrice ? _self.buyOutPrice : buyOutPrice // ignore: cast_nullable_to_non_nullable
as double?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
