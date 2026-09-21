// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Auction _$AuctionFromJson(Map<String, dynamic> json) => _Auction(
  id: json['id'] as String,
  sellerId: json['seller_id'] as String?,
  winnerId: json['winner_id'] as String?,
  sellerName: json['seller_name'] as String?,
  sellerEmail: json['seller_email'] as String?,
  sellerPhone: json['seller_phone'] as String?,
  title: json['title'] as String,
  description: json['description'] as String?,
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  startingPrice: (json['starting_price'] as num).toDouble(),
  currentPrice: (json['current_price'] as num).toDouble(),
  minIncrement: (json['min_increment'] as num).toDouble(),
  buyOutPrice: (json['buy_out_price'] as num?)?.toDouble(),
  startTime: DateTime.parse(json['start_time'] as String),
  endTime: DateTime.parse(json['end_time'] as String),
  status: json['status'] as String,
);

Map<String, dynamic> _$AuctionToJson(_Auction instance) => <String, dynamic>{
  'id': instance.id,
  'seller_id': instance.sellerId,
  'winner_id': instance.winnerId,
  'seller_name': instance.sellerName,
  'seller_email': instance.sellerEmail,
  'seller_phone': instance.sellerPhone,
  'title': instance.title,
  'description': instance.description,
  'images': instance.images,
  'starting_price': instance.startingPrice,
  'current_price': instance.currentPrice,
  'min_increment': instance.minIncrement,
  'buy_out_price': instance.buyOutPrice,
  'start_time': instance.startTime.toIso8601String(),
  'end_time': instance.endTime.toIso8601String(),
  'status': instance.status,
};
