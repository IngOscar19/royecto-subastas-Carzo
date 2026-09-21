import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/auctions_repository.dart';
import '../domain/auction.dart';

export '../data/auctions_repository.dart' show UserBidItem, UserBidItemCover;
export '../domain/vehicle_category.dart';

enum CatalogSortOption {
  all,
  endingSoon,
  lowestPrice,
  highestPrice,
}

/// Query de texto actual para el buscador de subastas.
final catalogSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Categoría de vehículo seleccionada desde el Sidebar.
final vehicleCategoryProvider =
    StateProvider.autoDispose<VehicleCategory>((ref) => VehicleCategory.all);

/// Filtro / orden seleccionado en el catálogo.
final catalogSortOptionProvider =
    StateProvider.autoDispose<CatalogSortOption>((ref) => CatalogSortOption.all);

/// Subastas activas filtradas por categoría de vehículo.
final categoryActiveAuctionsProvider =
    Provider.autoDispose<AsyncValue<List<Auction>>>((ref) {
  final auctionsAsync = ref.watch(activeAuctionsProvider);
  final category = ref.watch(vehicleCategoryProvider);

  return auctionsAsync.whenData((auctions) {
    if (category == VehicleCategory.all) return auctions;
    return auctions.where((a) => category.matches(a)).toList();
  });
});

/// Catálogo de subastas activas para la pantalla del comprador.
final activeAuctionsProvider = FutureProvider.autoDispose<List<Auction>>(
  (ref) => ref.watch(auctionsRepositoryProvider).fetchActive(),
);

/// Lista de subastas activas filtradas por categoría, búsqueda y ordenadas.
final filteredActiveAuctionsProvider =
    Provider.autoDispose<AsyncValue<List<Auction>>>((ref) {
  final auctionsAsync = ref.watch(activeAuctionsProvider);
  final query = ref.watch(catalogSearchQueryProvider).trim().toLowerCase();
  final sortOption = ref.watch(catalogSortOptionProvider);
  final category = ref.watch(vehicleCategoryProvider);

  return auctionsAsync.whenData((auctions) {
    var filtered = auctions;
    if (category != VehicleCategory.all) {
      filtered = filtered.where((a) => category.matches(a)).toList();
    }

    if (query.isNotEmpty) {
      filtered = filtered.where((a) {
        final title = a.title.toLowerCase();
        final desc = (a.description ?? '').toLowerCase();
        return title.contains(query) || desc.contains(query);
      }).toList();
    }

    final sorted = [...filtered];
    switch (sortOption) {
      case CatalogSortOption.endingSoon:
        sorted.sort((a, b) => a.endTime.compareTo(b.endTime));
        break;
      case CatalogSortOption.lowestPrice:
        sorted.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
        break;
      case CatalogSortOption.highestPrice:
        sorted.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
        break;
      case CatalogSortOption.all:
        break;
    }
    return sorted;
  });
});

/// Detalle REST de una subasta (título, descripción e imágenes) para la
/// pantalla de detalle; el precio/tiempo en vivo vienen del WebSocket.
final auctionDetailProvider = FutureProvider.autoDispose
    .family<Auction, String>(
      (ref, auctionId) =>
          ref.watch(auctionsRepositoryProvider).fetchById(auctionId),
    );

/// Subastas publicadas por el vendedor autenticado.
final sellerAuctionsProvider = FutureProvider.autoDispose<List<Auction>>((ref) async {
  final user = ref.watch(authControllerProvider).valueOrNull;
  if (user == null) return const [];
  return ref.watch(auctionsRepositoryProvider).fetchSellerAuctions(user.id);
});

/// Historial de ofertas enviadas por el comprador autenticado.
final myBidsProvider = FutureProvider.autoDispose<List<UserBidItem>>((ref) async {
  final user = ref.watch(authControllerProvider).valueOrNull;
  if (user == null) return const [];
  return ref.watch(auctionsRepositoryProvider).fetchMyBids();
});


