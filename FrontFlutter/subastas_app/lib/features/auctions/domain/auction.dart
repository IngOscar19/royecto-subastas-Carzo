import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/network/env.dart';
export 'vehicle_category.dart';

part 'auction.freezed.dart';
part 'auction.g.dart';

@freezed
abstract class Auction with _$Auction {
  const factory Auction({
    required String id,
    @JsonKey(name: 'seller_id') String? sellerId,
    @JsonKey(name: 'winner_id') String? winnerId,
    @JsonKey(name: 'seller_name') String? sellerName,
    @JsonKey(name: 'seller_email') String? sellerEmail,
    @JsonKey(name: 'seller_phone') String? sellerPhone,
    required String title,
    String? description,
    required List<String> images,
    @JsonKey(name: 'starting_price') required double startingPrice,
    @JsonKey(name: 'current_price') required double currentPrice,
    @JsonKey(name: 'min_increment') required double minIncrement,
    @JsonKey(name: 'buy_out_price') double? buyOutPrice,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    required String status,
  }) = _Auction;

  factory Auction.fromJson(Map<String, dynamic> json) =>
      _$AuctionFromJson(json);
}

extension AuctionCover on Auction {
  /// URL completa de la imagen de portada. El backend devuelve rutas
  /// relativas (`/images/...`), así que se resuelven contra la base URL.
  String? get coverUrl {
    if (images.isEmpty) return null;
    final path = images.first;
    if (path.startsWith('http')) return path;
    return '${Env.apiBaseUrl}$path';
  }

  /// URLs completas de todas las imágenes (hasta 3 por vehículo).
  /// Resuelve cada ruta relativa contra la base URL y descarta vacíos.
  List<String> get imageUrls {
    return images
        .where((path) => path.trim().isNotEmpty)
        .map((path) => path.startsWith('http') ? path : '${Env.apiBaseUrl}$path')
        .toList();
  }

  /// Estado dinámico calculado para reflejar si ya inició o finalizó.
  String get effectiveStatus {
    if (status == 'closed') return 'closed';
    final now = DateTime.now().toUtc();
    final startUtc = startTime.toUtc();
    final endUtc = endTime.toUtc();

    if (now.isAfter(endUtc)) {
      return 'closed';
    }
    if (now.isAfter(startUtc) || now.isAtSameMomentAs(startUtc) || status == 'active') {
      return 'active';
    }
    return 'scheduled';
  }
}
