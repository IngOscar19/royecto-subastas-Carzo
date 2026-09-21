import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/env.dart';
import '../domain/auction.dart';

final auctionsRepositoryProvider = Provider<AuctionsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuctionsRepository(apiClient: apiClient);
});

/// Repositorio REST del catálogo y gestión de subastas.
class AuctionsRepository {
  AuctionsRepository({required this.apiClient});

  final ApiClient apiClient;

  /// Sube hasta 20 imágenes locales al servidor y retorna sus URLs relativas.
  Future<List<String>> uploadImages(List<XFile> files) async {
    if (files.isEmpty) return const [];

    final formData = FormData();
    for (final file in files) {
      final bytes = await file.readAsBytes();
      formData.files.add(
        MapEntry(
          'images',
          MultipartFile.fromBytes(
            bytes,
            filename: file.name.isNotEmpty ? file.name : 'image.jpg',
          ),
        ),
      );
    }

    final response = await apiClient.dio.post<Map<String, dynamic>>(
      '/auctions/upload-images',
      data: formData,
    );

    final data = response.data;
    if (data == null || data['urls'] == null) {
      throw Exception('Respuesta inválida al subir imágenes');
    }

    final urls = (data['urls'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    return urls;
  }

  /// Lista las subastas activas (catálogo del comprador) con búsqueda opcional.
  Future<List<Auction>> fetchActive({String? search}) async {
    final queryParams = <String, dynamic>{'status': 'active'};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await apiClient.dio.get<List<dynamic>>(
      '/auctions',
      queryParameters: queryParams,
    );

    final data = response.data;
    if (data == null) return const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(Auction.fromJson)
        .toList();
  }

  /// Lista las subastas publicadas por un vendedor específico.
  Future<List<Auction>> fetchSellerAuctions(String sellerId) async {
    final response = await apiClient.dio.get<List<dynamic>>(
      '/auctions',
      queryParameters: {'sellerId': sellerId},
    );

    final data = response.data;
    if (data == null) return const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(Auction.fromJson)
        .toList();
  }

  /// Detalle de una subasta por id (título, descripción e imágenes).
  Future<Auction> fetchById(String auctionId) async {
    final response =
        await apiClient.dio.get<Map<String, dynamic>>('/auctions/$auctionId');

    final data = response.data;
    if (data == null) {
      throw Exception('Respuesta vacía al obtener la subasta');
    }
    return Auction.fromJson(data);
  }

  /// Crea una nueva subasta como vendedor.
  Future<Auction> createAuction({
    required String title,
    String? description,
    required double startingPrice,
    required double minIncrement,
    double? buyOutPrice,
    required DateTime startTime,
    required DateTime endTime,
    List<String>? images,
  }) async {
    final response = await apiClient.dio.post<Map<String, dynamic>>(
      '/auctions',
      data: {
        'title': title,
        'description': description,
        'startingPrice': startingPrice,
        'minIncrement': minIncrement,
        if (buyOutPrice != null && buyOutPrice > 0) 'buyOutPrice': buyOutPrice,
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
        if (images != null && images.isNotEmpty) 'images': images,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Error al crear la subasta: respuesta vacía');
    }
    return Auction.fromJson(data);
  }

  /// Ejecuta la compra directa ("Cómpralo Ya") de una subasta activa.
  Future<Auction> buyNow(String auctionId) async {
    final response = await apiClient.dio.post<Map<String, dynamic>>(
      '/auctions/$auctionId/buy-now',
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Error al realizar la compra directa');
    }
    return Auction.fromJson(data);
  }

  /// Finaliza manualmente una subasta anticipadamente (acción del vendedor).
  Future<Auction> closeAuction(String auctionId) async {
    final response = await apiClient.dio.post<Map<String, dynamic>>(
      '/auctions/$auctionId/close',
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Error al finalizar la subasta');
    }
    return Auction.fromJson(data);
  }

  /// Lista las subastas ganadas por un comprador específico.
  Future<List<Auction>> fetchWonAuctions(String userId) async {
    final response = await apiClient.dio.get<List<dynamic>>(
      '/auctions',
      queryParameters: {'winnerId': userId},
    );

    final data = response.data;
    if (data == null) return const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(Auction.fromJson)
        .toList();
  }

  /// Lista el historial de pujas realizadas por el comprador.
  Future<List<UserBidItem>> fetchMyBids() async {
    final response = await apiClient.dio.get<List<dynamic>>('/bids/my-bids');

    final data = response.data;
    if (data == null) return const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(UserBidItem.fromJson)
        .toList();
  }
}

class UserBidItem {
  const UserBidItem({
    required this.bidId,
    required this.auctionId,
    required this.auctionTitle,
    required this.images,
    required this.auctionStatus,
    required this.currentPrice,
    required this.myHighestBid,
    required this.createdAt,
  });

  factory UserBidItem.fromJson(Map<String, dynamic> json) {
    return UserBidItem(
      bidId: json['bidId'] as String? ?? '',
      auctionId: json['auctionId'] as String? ?? '',
      auctionTitle: json['auctionTitle'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      auctionStatus: json['auctionStatus'] as String? ?? '',
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0,
      myHighestBid: (json['myHighestBid'] as num?)?.toDouble() ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  final String bidId;
  final String auctionId;
  final String auctionTitle;
  final List<String> images;
  final String auctionStatus;
  final double currentPrice;
  final double myHighestBid;
  final String createdAt;
}

extension UserBidItemCover on UserBidItem {
  /// URL completa de la imagen de portada.
  String? get coverUrl {
    if (images.isEmpty) return null;
    final path = images.first;
    if (path.startsWith('http')) return path;
    return '${Env.apiBaseUrl}$path';
  }

  /// URLs completas de todas las imágenes.
  List<String> get imageUrls {
    return images
        .where((path) => path.trim().isNotEmpty)
        .map((path) => path.startsWith('http') ? path : '${Env.apiBaseUrl}$path')
        .toList();
  }
}


