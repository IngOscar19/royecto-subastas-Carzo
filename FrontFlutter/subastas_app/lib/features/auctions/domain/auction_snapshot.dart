import 'package:freezed_annotation/freezed_annotation.dart';

import '../../bids/domain/bid_model.dart';

part 'auction_snapshot.freezed.dart';
part 'auction_snapshot.g.dart';

@freezed
abstract class AuctionSnapshot with _$AuctionSnapshot {
  const factory AuctionSnapshot({
    required String auctionId,
    required double currentPrice,
    @JsonKey(name: 'endTime') required int endTime,
    required List<BidModel> lastBids,
    required String status,
  }) = _AuctionSnapshot;

  factory AuctionSnapshot.fromJson(Map<String, dynamic> json) =>
      _$AuctionSnapshotFromJson(json);
}
