import 'package:freezed_annotation/freezed_annotation.dart';

part 'auction_started.freezed.dart';
part 'auction_started.g.dart';

/// Evento broadcast emitido cuando una subasta pasa de 'scheduled' a 'active'.
@freezed
abstract class AuctionStarted with _$AuctionStarted {
  const factory AuctionStarted({
    required String auctionId,
    required double currentPrice,
    @JsonKey(name: 'endTime') required int endTime,
  }) = _AuctionStarted;

  factory AuctionStarted.fromJson(Map<String, dynamic> json) =>
      _$AuctionStartedFromJson(json);
}
