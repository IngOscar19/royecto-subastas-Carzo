import 'package:freezed_annotation/freezed_annotation.dart';

part 'bid_model.freezed.dart';
part 'bid_model.g.dart';

@freezed
abstract class BidModel with _$BidModel {
  const factory BidModel({
    required String bidId,
    required String userId,
    required String userName,
    required double amount,
    required DateTime createdAt,
  }) = _BidModel;

  factory BidModel.fromJson(Map<String, dynamic> json) => _$BidModelFromJson(json);
}
