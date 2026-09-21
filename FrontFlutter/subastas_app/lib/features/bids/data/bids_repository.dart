import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/auction_bids_page.dart';

final bidsRepositoryProvider = Provider<BidsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BidsRepository(apiClient: apiClient);
});

/// Repositorio para la gestión y consulta REST de ofertas (bids).
class BidsRepository {
  BidsRepository({required this.apiClient});

  final ApiClient apiClient;

  /// Obtiene el historial paginado de ofertas para una subasta dada.
  Future<AuctionBidsPage> getAuctionBids({
    required String auctionId,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await apiClient.dio.get<Map<String, dynamic>>(
      '/auctions/$auctionId/bids',
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Respuesta vacía al obtener historial de ofertas');
    }

    return AuctionBidsPage.fromJson(data);
  }
}
