import 'package:flutter_test/flutter_test.dart';
import 'package:subastas_app/core/network/env.dart';
import 'package:subastas_app/features/auctions/domain/auction.dart';

void main() {
  group('Auction model', () {
    final json = <String, dynamic>{
      'id': '8b8624ba-d80c-4350-96e2-2624f786ff93',
      'title': 'Honda Civic LX 2022',
      'description': 'Sedán compacto, 41,000 km.',
      'images': ['/images/auctions/honda-civic-lx-2022.jpg'],
      'starting_price': 4200,
      'current_price': 4200,
      'min_increment': 150,
      'start_time': '2026-08-17T02:47:14.943Z',
      'end_time': '2026-08-19T03:17:14.943Z',
      'status': 'active',
    };

    test('fromJson parsea la respuesta del backend', () {
      final auction = Auction.fromJson(json);

      expect(auction.id, '8b8624ba-d80c-4350-96e2-2624f786ff93');
      expect(auction.title, 'Honda Civic LX 2022');
      expect(auction.images, ['/images/auctions/honda-civic-lx-2022.jpg']);
      expect(auction.startingPrice, 4200);
      expect(auction.currentPrice, 4200);
      expect(auction.minIncrement, 150);
      expect(auction.endTime, DateTime.parse('2026-08-19T03:17:14.943Z'));
      expect(auction.status, 'active');
    });

    test('coverUrl resuelve la ruta relativa contra la base URL', () {
      final auction = Auction.fromJson(json);
      expect(
        auction.coverUrl,
        '${Env.apiBaseUrl}/images/auctions/honda-civic-lx-2022.jpg',
      );
    });

    test('coverUrl devuelve null cuando no hay imágenes', () {
      final auction = Auction.fromJson({...json, 'images': <String>[]});
      expect(auction.coverUrl, isNull);
    });

    test('imageUrls resuelve todas las rutas contra la base URL', () {
      final multi = Auction.fromJson({
        ...json,
        'images': [
          '/images/auctions/honda-civic-lx-2022.jpg',
          '/images/auctions/honda-civic-lx-2022-2.jpg',
          '/images/auctions/honda-civic-lx-2022-3.jpg',
        ],
      });
      expect(multi.imageUrls, [
        '${Env.apiBaseUrl}/images/auctions/honda-civic-lx-2022.jpg',
        '${Env.apiBaseUrl}/images/auctions/honda-civic-lx-2022-2.jpg',
        '${Env.apiBaseUrl}/images/auctions/honda-civic-lx-2022-3.jpg',
      ]);
    });

    test('imageUrls respeta URLs absolutas y descarta vacíos', () {
      final mixed = Auction.fromJson({
        ...json,
        'images': [
          'https://cdn.ejemplo.com/coche.jpg',
          '  ',
          '/images/auctions/honda-civic-lx-2022.jpg',
        ],
      });
      expect(mixed.imageUrls, [
        'https://cdn.ejemplo.com/coche.jpg',
        '${Env.apiBaseUrl}/images/auctions/honda-civic-lx-2022.jpg',
      ]);
    });
  });
}