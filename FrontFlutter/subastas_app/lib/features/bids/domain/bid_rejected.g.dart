// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid_rejected.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BidRejected _$BidRejectedFromJson(Map<String, dynamic> json) => _BidRejected(
  reason: json['reason'] as String,
  currentPrice: (json['currentPrice'] as num).toDouble(),
);

Map<String, dynamic> _$BidRejectedToJson(_BidRejected instance) =>
    <String, dynamic>{
      'reason': instance.reason,
      'currentPrice': instance.currentPrice,
    };
