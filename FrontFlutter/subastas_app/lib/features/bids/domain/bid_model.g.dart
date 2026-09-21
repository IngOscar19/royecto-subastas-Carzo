// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BidModel _$BidModelFromJson(Map<String, dynamic> json) => _BidModel(
  bidId: json['bidId'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  amount: (json['amount'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BidModelToJson(_BidModel instance) => <String, dynamic>{
  'bidId': instance.bidId,
  'userId': instance.userId,
  'userName': instance.userName,
  'amount': instance.amount,
  'createdAt': instance.createdAt.toIso8601String(),
};
