import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../features/auctions/domain/auction_closed.dart';
import '../../features/auctions/domain/auction_snapshot.dart';
import '../../features/auctions/domain/auction_started.dart';
import '../../features/bids/domain/bid_model.dart';
import '../../features/bids/domain/bid_rejected.dart';
import '../../features/bids/domain/outbid_notification.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/data/token_storage.dart';
import 'env.dart';

/// Estado de conexión del WebSocket para el indicador de UI.
enum SocketStatus {
  connected,
  reconnecting,
  disconnected,
}

/// Cliente socket_io_client para subastas en tiempo real. Conecta a la
/// misma base URL que el API REST, adjunta el JWT en el handshake
/// (`auth: { token }`) y expone streams de snapshots, pujas nuevas,
/// rechazos de puja, notificaciones outbid y extensiones de tiempo.
final socketClientProvider = Provider<SocketClient>((ref) {
  // Reacciona a cambios de sesión para reconectar el socket con el token y rol del nuevo usuario
  ref.watch(authControllerProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  final client = SocketClient(
    baseUrl: Env.apiBaseUrl,
    tokenLookup: tokenStorage.getAccessToken,
  );
  ref.onDispose(client.dispose);
  return client;
});

/// Expone el estado de conexión del WebSocket como Stream.
final socketStatusProvider = StreamProvider<SocketStatus>((ref) {
  final client = ref.watch(socketClientProvider);
  return client.statusStream;
});

class SocketClient {
  SocketClient({
    required String baseUrl,
    required Future<String?> Function() tokenLookup,
  }) {
    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setReconnectionDelay(1000)
          // El JWT se resuelve de forma asíncrona (flutter_secure_storage)
          // y se incluye en el CONNECT packet del handshake.
          .setAuthFn((callback) {
            tokenLookup().then((token) {
              callback({'token': token ?? ''});
            });
          })
          .build(),
    );

    _socket.onConnect((_) {
      // Al (re)conectar, re-join de la subasta activa: el servidor es la
      // única fuente de verdad y nunca asumimos que no se perdió un evento.
      // El `auction_snapshot` que responde el join refresca todo el estado
      // (precio, endTime, lastBids) en el cliente.
      _setStatus(SocketStatus.connected);
      final auctionId = _joinedAuctionId;
      if (auctionId != null) {
        _socket.emit('join_auction', {'auctionId': auctionId});
      }
    });

    _socket.onDisconnect((_) {
      _setStatus(SocketStatus.disconnected);
    });

    _socket.onConnectError((_) {
      // socket_io_client reintenta solo; se marca como reconectando.
      _setStatus(SocketStatus.reconnecting);
    });

    _socket.onReconnectAttempt((_) {
      _setStatus(SocketStatus.reconnecting);
    });

    _socket.onReconnectFailed((_) {
      _setStatus(SocketStatus.disconnected);
    });

    _socket.on('auction_snapshot', (data) {
      if (data is! Map) return;
      try {
        final map = Map<String, dynamic>.from(data);
        _snapshotsController.add(AuctionSnapshot.fromJson(map));
      } on Object {
        // Ignorar snapshots que no cumplan el contrato; el siguiente
        // evento o reconexión refrescará el estado.
      }
    });

    _socket.on('new_bid', (data) {
      if (data is! Map) return;
      try {
        final map = Map<String, dynamic>.from(data);
        _newBidsController.add(BidModel.fromJson(map));
      } on Object {
        // Ignorar bid malformado; el snapshot siguiente lo reflejará.
      }
    });

    _socket.on('bid_rejected', (data) {
      if (data is! Map) return;
      try {
        final map = Map<String, dynamic>.from(data);
        _bidRejectionsController.add(BidRejected.fromJson(map));
      } on Object {
        // Ignorar rechazo malformado.
      }
    });

    _socket.on('time_extended', (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      final newEndTime = map['newEndTime'];
      if (newEndTime is num) {
        _timeExtensionsController.add(newEndTime.toInt());
      }
    });

    _socket.on('auction_closed', (data) {
      if (data is! Map) return;
      try {
        final map = Map<String, dynamic>.from(data);
        _auctionClosedController.add(AuctionClosed.fromJson(map));
      } on Object {
        // Ignorar cierre malformado; el snapshot siguiente lo reflejará.
      }
    });

    _socket.on('auction_started', (data) {
      if (data is! Map) return;
      try {
        final map = Map<String, dynamic>.from(data);
        _auctionStartedController.add(AuctionStarted.fromJson(map));
      } on Object {
        // Ignorar payload malformado.
      }
    });

    _socket.on('outbid_notification', (data) {
      if (data is! Map) return;
      try {
        final map = Map<String, dynamic>.from(data);
        _outbidNotificationsController.add(OutbidNotification.fromJson(map));
      } on Object {
        // Ignorar notificación malformada.
      }
    });
  }

  late final io.Socket _socket;
  bool _isDisposed = false;
  final _connectionStatus = ValueNotifier<SocketStatus>(SocketStatus.disconnected);
  final _statusController = StreamController<SocketStatus>.broadcast();
  final _snapshotsController = StreamController<AuctionSnapshot>.broadcast();
  final _newBidsController = StreamController<BidModel>.broadcast();
  final _bidRejectionsController = StreamController<BidRejected>.broadcast();
  final _timeExtensionsController = StreamController<int>.broadcast();
  final _auctionClosedController = StreamController<AuctionClosed>.broadcast();
  final _auctionStartedController = StreamController<AuctionStarted>.broadcast();
  final _outbidNotificationsController = StreamController<OutbidNotification>.broadcast();
  String? _joinedAuctionId;

  void _setStatus(SocketStatus status) {
    if (_isDisposed) return;
    if (_connectionStatus.value != status) {
      _connectionStatus.value = status;
      if (!_statusController.isClosed) {
        _statusController.add(status);
      }
    }
  }

  /// Estado actual de conexión expuesto como [ValueListenable].
  ValueListenable<SocketStatus> get connectionStatus => _connectionStatus;

  /// Stream continuo del estado de la conexión WebSocket.
  Stream<SocketStatus> get statusStream async* {
    yield _connectionStatus.value;
    yield* _statusController.stream;
  }

  /// Emite cada `auction_snapshot` recibido del servidor.
  Stream<AuctionSnapshot> get auctionSnapshots => _snapshotsController.stream;

  /// Emite cada `new_bid` confirmado por el servidor.
  Stream<BidModel> get newBids => _newBidsController.stream;

  /// Emite cada `bid_rejected` (puja rechazada con su motivo).
  Stream<BidRejected> get bidRejections => _bidRejectionsController.stream;

  /// Emite cada `time_extended` con el nuevo endTime (epoch ms UTC).
  Stream<int> get timeExtensions => _timeExtensionsController.stream;

  /// Emite cada `auction_closed` (ganador y precio final).
  Stream<AuctionClosed> get auctionClosed => _auctionClosedController.stream;

  /// Emite cada `auction_started` emitido en broadcast global por el servidor.
  Stream<AuctionStarted> get auctionStarted => _auctionStartedController.stream;

  /// Emite cada `outbid_notification` cuando la oferta del usuario es superada.
  Stream<OutbidNotification> get outbidNotifications =>
      _outbidNotificationsController.stream;

  /// Conecta al servidor (idempotente).
  void connect() {
    if (_isDisposed) return;
    if (_socket.connected) return;
    _socket.connect();
  }

  /// Entra en la room de la subasta y marca el auction activo para
  /// re-join automático ante reconexiones.
  void joinAuction(String auctionId) {
    if (_isDisposed) return;
    connect();
    _joinedAuctionId = auctionId;
    _socket.emit('join_auction', {'auctionId': auctionId});
  }

  /// Envía una oferta. El servidor valida y decide: la confirmación llega
  /// por [newBids] o el rechazo por [bidRejections].
  void placeBid({required String auctionId, required double amount}) {
    if (_isDisposed) return;
    connect();
    _socket.emit('place_bid', {'auctionId': auctionId, 'amount': amount});
  }

  /// Desconecta y libera recursos de forma segura.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    try {
      _socket.clearListeners();
      _socket.disconnect();
      _socket.dispose();
    } catch (_) {}
    _statusController.close();
    _connectionStatus.dispose();
    _snapshotsController.close();
    _newBidsController.close();
    _bidRejectionsController.close();
    _timeExtensionsController.close();
    _auctionClosedController.close();
    _auctionStartedController.close();
    _outbidNotificationsController.close();
  }
}