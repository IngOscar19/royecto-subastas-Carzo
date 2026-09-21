import 'package:freezed_annotation/freezed_annotation.dart';

part 'auction_closed.freezed.dart';
part 'auction_closed.g.dart';

/// Cierre de subasta emitido por el servidor (`auction_closed`). Cuando la
/// subasta no recibió ninguna oferta, [winnerId] y [winnerName] son `null`
/// (semántica "sin ganador"); [finalPrice] es el precio de salida.
@freezed
abstract class AuctionClosed with _$AuctionClosed {
  const factory AuctionClosed({
    String? winnerId,
    String? winnerName,
    required double finalPrice,
  }) = _AuctionClosed;

  factory AuctionClosed.fromJson(Map<String, dynamic> json) =>
      _$AuctionClosedFromJson(json);
}