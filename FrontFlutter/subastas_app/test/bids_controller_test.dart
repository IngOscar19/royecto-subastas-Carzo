import 'package:flutter_test/flutter_test.dart';
import 'package:subastas_app/core/network/api_client.dart';
import 'package:subastas_app/features/bids/data/bids_repository.dart';
import 'package:subastas_app/features/bids/domain/auction_bids_page.dart';
import 'package:subastas_app/features/bids/domain/bid_model.dart';
import 'package:subastas_app/features/bids/presentation/bids_controller.dart';

class FakeBidsRepository implements BidsRepository {
  FakeBidsRepository(this.pages);

  final List<BidModel> pages;

  @override
  ApiClient get apiClient => throw UnimplementedError();

  @override
  Future<AuctionBidsPage> getAuctionBids({
    required String auctionId,
    int limit = 20,
    int offset = 0,
  }) async {
    final slice = pages.skip(offset).take(limit).toList();
    return AuctionBidsPage(
      items: slice,
      total: pages.length,
      limit: limit,
      offset: offset,
    );
  }
}

void main() {
  group('BidsNotifier tests', () {
    late List<BidModel> mockBids;

    setUp(() {
      mockBids = List.generate(
        25,
        (i) => BidModel(
          bidId: 'bid-$i',
          userId: 'user-1',
          userName: 'User 1',
          amount: 1000.0 + i * 50,
          createdAt: DateTime.utc(2026, 8, 13, 10, i),
        ),
      );
    });

    test('loadInitial loads page 0 (20 items)', () async {
      final fakeRepo = FakeBidsRepository(mockBids);
      final notifier = BidsNotifier(
        repository: fakeRepo,
        auctionId: 'auction-1',
        pageSize: 20,
      );

      await Future.delayed(Duration.zero);

      expect(notifier.state.bids.length, equals(20));
      expect(notifier.state.total, equals(25));
      expect(notifier.state.hasMore, isTrue);
    });

    test('loadMore loads remaining items (5 items)', () async {
      final fakeRepo = FakeBidsRepository(mockBids);
      final notifier = BidsNotifier(
        repository: fakeRepo,
        auctionId: 'auction-1',
        pageSize: 20,
      );

      await Future.delayed(Duration.zero);
      await notifier.loadMore();

      expect(notifier.state.bids.length, equals(25));
      expect(notifier.state.hasMore, isFalse);
    });

    test('addLiveBid prepends new bid and does not duplicate', () {
      final fakeRepo = FakeBidsRepository([]);
      final notifier = BidsNotifier(
        repository: fakeRepo,
        auctionId: 'auction-1',
      );

      final liveBid = BidModel(
        bidId: 'live-1',
        userId: 'user-2',
        userName: 'User 2',
        amount: 2500,
        createdAt: DateTime.now(),
      );

      notifier.addLiveBid(liveBid);
      expect(notifier.state.bids.length, equals(1));
      expect(notifier.state.bids.first.bidId, equals('live-1'));

      // Re-adding the same bidId should be ignored
      notifier.addLiveBid(liveBid);
      expect(notifier.state.bids.length, equals(1));
    });

    test('syncFromSnapshot merges snapshot bids without duplicating', () {
      final fakeRepo = FakeBidsRepository([]);
      final notifier = BidsNotifier(
        repository: fakeRepo,
        auctionId: 'auction-1',
      );

      final snapshotBids = [
        BidModel(
          bidId: 'snap-1',
          userId: 'u1',
          userName: 'User 1',
          amount: 3000,
          createdAt: DateTime.utc(2026, 8, 13, 12, 0),
        ),
      ];

      notifier.syncFromSnapshot(snapshotBids);
      expect(notifier.state.bids.length, equals(1));

      // Second sync with same bidId
      notifier.syncFromSnapshot(snapshotBids);
      expect(notifier.state.bids.length, equals(1));
    });
  });
}
