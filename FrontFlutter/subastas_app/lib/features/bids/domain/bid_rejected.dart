import 'package:freezed_annotation/freezed_annotation.dart';

part 'bid_rejected.freezed.dart';
part 'bid_rejected.g.dart';

/// Rechazo de una oferta emitido por el servidor (`bid_rejected`). El
/// motivo viene como string del contrato: 'amount_too_low' | 'auction_closed'
/// | 'auction_not_active' | 'forbidden'.
@freezed
abstract class BidRejected with _$BidRejected {
  const factory BidRejected({
    required String reason,
    required double currentPrice,
  }) = _BidRejected;

  factory BidRejected.fromJson(Map<String, dynamic> json) =>
      _$BidRejectedFromJson(json);
}