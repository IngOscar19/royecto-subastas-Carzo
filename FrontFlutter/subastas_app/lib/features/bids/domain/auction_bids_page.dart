import 'bid_model.dart';

/// DTO para la respuesta paginada de `GET /auctions/:id/bids`.
class AuctionBidsPage {
  const AuctionBidsPage({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
  });

  final List<BidModel> items;
  final int total;
  final int limit;
  final int offset;

  factory AuctionBidsPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return AuctionBidsPage(
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map((e) => BidModel.fromJson(e))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
    );
  }
}
