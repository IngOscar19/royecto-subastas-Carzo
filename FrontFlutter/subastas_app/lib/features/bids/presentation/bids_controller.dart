import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bids_repository.dart';
import '../domain/bid_model.dart';

/// Estado del historial paginado de ofertas.
class BidsState {
  const BidsState({
    this.bids = const [],
    this.total = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  final List<BidModel> bids;
  final int total;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  bool get hasMore => bids.length < total;

  BidsState copyWith({
    List<BidModel>? bids,
    int? total,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return BidsState(
      bids: bids ?? this.bids,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

final bidsControllerProvider = StateNotifierProvider.family
    .autoDispose<BidsNotifier, BidsState, String>((ref, auctionId) {
  final repository = ref.watch(bidsRepositoryProvider);
  return BidsNotifier(repository: repository, auctionId: auctionId);
});

class BidsNotifier extends StateNotifier<BidsState> {
  BidsNotifier({
    required this.repository,
    required this.auctionId,
    this.pageSize = 20,
  })  : super(const BidsState()) {
    loadInitial();
  }

  final BidsRepository repository;
  final String auctionId;
  final int pageSize;

  /// Carga inicial de la primera página del historial de ofertas.
  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final page = await repository.getAuctionBids(
        auctionId: auctionId,
        limit: pageSize,
        offset: 0,
      );
      if (!mounted) return;
      state = state.copyWith(
        bids: page.items,
        total: page.total,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Carga la siguiente página de ofertas y la anexa al listado existente.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await repository.getAuctionBids(
        auctionId: auctionId,
        limit: pageSize,
        offset: state.bids.length,
      );
      if (!mounted) return;

      final existingIds = state.bids.map((b) => b.bidId).toSet();
      final newItems =
          page.items.where((b) => !existingIds.contains(b.bidId)).toList();

      state = state.copyWith(
        bids: [...state.bids, ...newItems],
        total: page.total,
        isLoadingMore: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Incorpora una nueva puja recibida en vivo vía WebSocket.
  void addLiveBid(BidModel bid) {
    if (!mounted) return;
    if (state.bids.any((b) => b.bidId == bid.bidId)) return;
    state = state.copyWith(
      bids: [bid, ...state.bids],
      total: state.total + 1,
    );
  }

  /// Sincroniza las ofertas destacadas del snapshot de reconexión.
  void syncFromSnapshot(List<BidModel> snapshotBids) {
    if (!mounted) return;
    if (snapshotBids.isEmpty) return;

    final existingIds = state.bids.map((b) => b.bidId).toSet();
    final missingFromSnapshot =
        snapshotBids.where((b) => !existingIds.contains(b.bidId)).toList();

    if (missingFromSnapshot.isEmpty) return;

    final merged = [...missingFromSnapshot, ...state.bids];
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final newTotal = state.total < merged.length ? merged.length : state.total;
    state = state.copyWith(bids: merged, total: newTotal);
  }
}

