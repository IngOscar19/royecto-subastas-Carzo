// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuctionSnapshot _$AuctionSnapshotFromJson(Map<String, dynamic> json) =>
    _AuctionSnapshot(
      auctionId: json['auctionId'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      endTime: (json['endTime'] as num).toInt(),
      lastBids: (json['lastBids'] as List<dynamic>)
          .map((e) => BidModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$AuctionSnapshotToJson(_AuctionSnapshot instance) =>
    <String, dynamic>{
      'auctionId': instance.auctionId,
      'currentPrice': instance.currentPrice,
      'endTime': instance.endTime,
      'lastBids': instance.lastBids,
      'status': instance.status,
    };
