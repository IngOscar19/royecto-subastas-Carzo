// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction_closed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuctionClosed _$AuctionClosedFromJson(Map<String, dynamic> json) =>
    _AuctionClosed(
      winnerId: json['winnerId'] as String?,
      winnerName: json['winnerName'] as String?,
      finalPrice: (json['finalPrice'] as num).toDouble(),
    );

Map<String, dynamic> _$AuctionClosedToJson(_AuctionClosed instance) =>
    <String, dynamic>{
      'winnerId': instance.winnerId,
      'winnerName': instance.winnerName,
      'finalPrice': instance.finalPrice,
    };
