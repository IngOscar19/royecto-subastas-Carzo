// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction_started.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuctionStarted _$AuctionStartedFromJson(Map<String, dynamic> json) =>
    _AuctionStarted(
      auctionId: json['auctionId'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      endTime: (json['endTime'] as num).toInt(),
    );

Map<String, dynamic> _$AuctionStartedToJson(_AuctionStarted instance) =>
    <String, dynamic>{
      'auctionId': instance.auctionId,
      'currentPrice': instance.currentPrice,
      'endTime': instance.endTime,
    };
