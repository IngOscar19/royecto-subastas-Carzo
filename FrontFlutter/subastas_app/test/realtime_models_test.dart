import 'package:flutter_test/flutter_test.dart';
import 'package:subastas_app/features/auctions/domain/auction_started.dart';
import 'package:subastas_app/features/bids/domain/outbid_notification.dart';

void main() {
  group('Real-time Domain Models Tests', () {
    test('OutbidNotification fromJson serializes correctly', () {
      final json = {
        'auctionId': 'auc-123',
        'amount': 15000.0,
        'newBidderName': 'Carlos',
        'message': '¡Tu oferta ha sido superada por Carlos (\$15000)!',
      };

      final notif = OutbidNotification.fromJson(json);

      expect(notif.auctionId, 'auc-123');
      expect(notif.amount, 15000.0);
      expect(notif.newBidderName, 'Carlos');
      expect(notif.message, contains('superada'));
    });

    test('AuctionStarted fromJson serializes correctly', () {
      final json = {
        'auctionId': 'auc-456',
        'currentPrice': 8000.0,
        'endTime': 1700000000000,
      };

      final started = AuctionStarted.fromJson(json);

      expect(started.auctionId, 'auc-456');
      expect(started.currentPrice, 8000.0);
      expect(started.endTime, 1700000000000);
    });
  });
}
