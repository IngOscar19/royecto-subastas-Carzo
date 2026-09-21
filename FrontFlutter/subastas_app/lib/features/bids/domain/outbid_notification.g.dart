// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbid_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OutbidNotification _$OutbidNotificationFromJson(Map<String, dynamic> json) =>
    _OutbidNotification(
      auctionId: json['auctionId'] as String,
      amount: (json['amount'] as num).toDouble(),
      newBidderName: json['newBidderName'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$OutbidNotificationToJson(_OutbidNotification instance) =>
    <String, dynamic>{
      'auctionId': instance.auctionId,
      'amount': instance.amount,
      'newBidderName': instance.newBidderName,
      'message': instance.message,
    };
