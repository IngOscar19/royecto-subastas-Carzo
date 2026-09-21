import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/socket_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_nav_bar.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/image_gallery.dart';
import '../../../core/widgets/live_countdown_badge.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/domain/user_role.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../bids/domain/bid_model.dart';
import '../../bids/domain/bid_rejected.dart';
import '../../bids/presentation/bids_controller.dart';
import '../data/auctions_repository.dart';
import '../domain/auction_closed.dart';
import '../domain/auction_snapshot.dart';
import '../domain/auction.dart';
import 'auction_detail_widgets.dart';
import 'catalog_provider.dart';

/// Snapshot en tiempo real. Al escucharlo se conecta al socket y hace join
/// a la room; mientras no llega el primer `auction_snapshot` el estado es
/// loading ("conectando…").
final auctionSnapshotProvider = StreamProvider.autoDispose
    .family<AuctionSnapshot, String>((ref, auctionId) {
  final socket = ref.watch(socketClientProvider);
  socket.joinAuction(auctionId);
  return socket.auctionSnapshots;
});

class AuctionDetailScreen extends ConsumerStatefulWidget {
  const AuctionDetailScreen({super.key, required this.auctionId});

  final String auctionId;

  @override
  ConsumerState<AuctionDetailScreen> createState() =>
      _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends ConsumerState<AuctionDetailScreen> {
  /// Incremento mínimo usado solo como validación preventiva de UX.
  static const double _minIncrement = 100;

  Timer? _ticker;
  Timer? _flashTimer;
  DateTime? _endTime;
  Duration _remaining = Duration.zero;
  double _currentPrice = 0;
  bool _priceFlash = false;
  final _amountController = TextEditingController();
  bool _placingBid = false;
  bool _closed = false;
  AuctionClosed? _closedInfo;
  StreamSubscription<BidModel>? _newBidsSub;
  StreamSubscription<BidRejected>? _bidRejectionsSub;
  StreamSubscription<int>? _timeExtensionsSub;
  StreamSubscription<AuctionClosed>? _auctionClosedSub;

  @override
  void initState() {
    super.initState();
    // Ticker de UI: solo recalcula endTime - now(); la verdad siempre viene
    // del servidor vía snapshot / time_extended.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_endTime != null && mounted) {
        setState(() => _remaining = _endTime!.difference(DateTime.now()));
        if (_remaining.isNegative && _ticker != null) {
          _ticker!.cancel();
          _ticker = null;
        }
      }
    });

    final socket = ref.read(socketClientProvider);
    _newBidsSub = socket.newBids.listen(_handleNewBid, onError: (_) {});
    _bidRejectionsSub =
        socket.bidRejections.listen(_handleBidRejected, onError: (_) {});
    _timeExtensionsSub =
        socket.timeExtensions.listen(_handleTimeExtended, onError: (_) {});
    _auctionClosedSub =
        socket.auctionClosed.listen(_handleAuctionClosed, onError: (_) {});
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _flashTimer?.cancel();
    _amountController.dispose();
    _newBidsSub?.cancel();
    _bidRejectionsSub?.cancel();
    _timeExtensionsSub?.cancel();
    _auctionClosedSub?.cancel();
    super.dispose();
  }

  void _handleNewBid(BidModel bid) {
    if (!mounted) return;
    if (bid.amount > _currentPrice) {
      setState(() {
        _currentPrice = bid.amount;
        _placingBid = false;
        _priceFlash = true;
      });
      _flashTimer?.cancel();
      _flashTimer = Timer(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _priceFlash = false);
      });
    } else {
      setState(() => _placingBid = false);
    }
    ref
        .read(bidsControllerProvider(widget.auctionId).notifier)
        .addLiveBid(bid);
  }

  void _handleBidRejected(BidRejected rejected) {
    if (!mounted) return;
    setState(() {
      _currentPrice = rejected.currentPrice;
      _placingBid = false;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.tertiary,
          content: Row(
            children: [
              const Icon(Icons.gavel_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(_rejectMessage(rejected.reason))),
            ],
          ),
        ),
      );
  }

  void _handleTimeExtended(int newEndTime) {
    if (!mounted) return;
    setState(() {
      _endTime = DateTime.fromMillisecondsSinceEpoch(newEndTime);
      _remaining = _endTime!.difference(DateTime.now());
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryInverted,
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              const Icon(Icons.update_rounded,
                  color: AppColors.secondary, size: 18),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('¡Tiempo extendido! Nueva oferta al límite'),
              ),
            ],
          ),
        ),
      );
  }

  void _handleAuctionClosed(AuctionClosed closed) {
    if (!mounted) return;
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _closed = true;
      _closedInfo = closed;
      _placingBid = false;
      _remaining = Duration.zero;
      _currentPrice = closed.finalPrice;
    });
    ref.invalidate(auctionDetailProvider(widget.auctionId));
    ref.invalidate(bidsControllerProvider(widget.auctionId));
    ref.invalidate(activeAuctionsProvider);
    ref.invalidate(sellerAuctionsProvider);
  }

  String _rejectMessage(String reason) {
    return switch (reason) {
      'amount_too_low' => 'La oferta es menor a la mínima permitida.',
      'auction_closed' => 'La subasta ya finalizó.',
      'auction_not_active' => 'La subasta no está activa.',
      'forbidden' => 'Tu rol no permite pujar en esta subasta.',
      _ => 'La oferta fue rechazada.',
    };
  }

  void _submitBid(AuctionSnapshot snapshot, double minIncrement) {
    final raw = _amountController.text.trim();
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      _showMessage('Introduce un monto válido.');
      return;
    }
    final minimum = snapshot.currentPrice + minIncrement;
    if (amount < minimum) {
      _showMessage('La puja mínima es ${formatCurrency(minimum)}.');
      return;
    }
    // Feedback inmediato: se marca enviando antes de la respuesta server.
    setState(() => _placingBid = true);
    ref.read(socketClientProvider).placeBid(
          auctionId: widget.auctionId,
          amount: amount,
        );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = auctionSnapshotProvider(widget.auctionId);
    final snapshotAsync = ref.watch(provider);
    final detailAsync = ref.watch(auctionDetailProvider(widget.auctionId));

    ref.listen(provider, (_, next) {
      final snapshot = next.valueOrNull;
      if (snapshot != null) {
        setState(() {
          _currentPrice = snapshot.currentPrice;
          _endTime = DateTime.fromMillisecondsSinceEpoch(snapshot.endTime);
          _remaining = _endTime!.difference(DateTime.now());
        });
        ref
            .read(bidsControllerProvider(widget.auctionId).notifier)
            .syncFromSnapshot(snapshot.lastBids);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppNavBar(
        title: 'Sala de Subasta',
        subtitle: detailAsync.valueOrNull?.title,
        icon: Icons.gavel,
        showBackButton: true,
        onBackPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            final role = ref.read(authControllerProvider).valueOrNull?.role;
            context.go(role == UserRole.seller ? '/seller' : '/bidder');
          }
        },
        actions: [
          const SocketStatusPill(),
          NavBarIconButton(
            icon: Icons.close_rounded,
            tooltip: 'Salir de la Subasta',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                final role = ref.read(authControllerProvider).valueOrNull?.role;
                context.go(role == UserRole.seller ? '/seller' : '/bidder');
              }
            },
          ),
          NavBarIconButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Reintentar conexión',
            onPressed: () => ref.invalidate(provider),
          ),
        ],
      ),
      body: snapshotAsync.when(
        loading: () => const ConnectingIndicator(),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ErrorStateView(
              message: '$error',
              title: 'No se pudo conectar con la subasta',
              onRetry: () => ref.invalidate(provider),
            ),
          ),
        ),
        data: (snapshot) => _buildContent(snapshot, detailAsync),
      ),
    );
  }

  Widget _buildContent(
    AuctionSnapshot snapshot,
    AsyncValue<Auction> detailAsync,
  ) {
    final auctionObj = detailAsync.valueOrNull;
    final minIncrement = auctionObj?.minIncrement ?? _minIncrement;
    final buyOutPrice = auctionObj?.buyOutPrice;
    final sessionUser = ref.watch(authControllerProvider).valueOrNull;
    final isSeller = sessionUser?.role.name == 'seller' ||
        (auctionObj != null && sessionUser?.id == auctionObj.sellerId);

    final bidsState = ref.watch(bidsControllerProvider(widget.auctionId));
    final isAuctionClosed =
        _closed || snapshot.status == 'closed' || auctionObj?.status == 'closed';
    final topBidder =
        bidsState.bids.isNotEmpty ? bidsState.bids.first : null;
    final effectiveClosedInfo = _closedInfo ??
        (isAuctionClosed
            ? AuctionClosed(
                winnerId: auctionObj?.winnerId ?? topBidder?.userId,
                winnerName: topBidder?.userName,
                finalPrice: _currentPrice > 0
                    ? _currentPrice
                    : (snapshot.currentPrice > 0
                        ? snapshot.currentPrice
                        : (auctionObj?.currentPrice ?? 0)),
              )
            : null);

    final price = _currentPrice > 0
        ? _currentPrice
        : (effectiveClosedInfo != null && effectiveClosedInfo.finalPrice > 0
            ? effectiveClosedInfo.finalPrice
            : (snapshot.currentPrice > 0
                ? snapshot.currentPrice
                : (auctionObj?.currentPrice ?? 0)));

    final minimum = price + minIncrement;
    final topBidderName = effectiveClosedInfo?.winnerName ??
        (bidsState.bids.isNotEmpty ? bidsState.bids.first.userName : null);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Galería hero
        Stack(
          children: [
            ImageGallery(
              imageUrls: auctionObj?.imageUrls ?? const [],
              height: 240,
              borderRadius: BorderRadius.circular(18),
              title: auctionObj?.title,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Título + chips de estado
        if (auctionObj != null) ...[
          Text(
            auctionObj.title,
            style: const TextStyle(
              fontFamily: AppFonts.headline,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
          if (auctionObj.description?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              auctionObj.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13.5,
                height: 1.4,
                color: AppColors.textSecondary.withAlpha(255),
              ),
            ),
          ],
        ] else
          Container(
            height: 22,
            width: 220,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatusChip(_closed ? 'closed' : snapshot.status),
            if (auctionObj != null)
              CategoryChip(category: auctionObj.vehicleCategory),
            if (!isAuctionClosed)
              LiveCountdownBadge(
                endTime:
                    _endTime ?? DateTime.now().add(const Duration(hours: 1)),
                closed: isAuctionClosed,
                style: CountdownStyle.tinted,
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Panel de precio en vivo
        _LivePricePanel(
          price: price,
          remaining: _remaining,
          isClosed: isAuctionClosed,
          flash: _priceFlash,
          topBidderName: topBidderName,
          isMine: sessionUser != null &&
              ((topBidder != null && topBidder.userId == sessionUser.id) ||
                  (effectiveClosedInfo != null &&
                      effectiveClosedInfo.winnerId == sessionUser.id)),
        ),
        const SizedBox(height: 16),

        if (isAuctionClosed && effectiveClosedInfo != null) ...[
          ClosedResultBanner(closed: effectiveClosedInfo),
          const SizedBox(height: 16),
        ],

        if (snapshot.status == 'active' && !isAuctionClosed) ...[
          if (buyOutPrice != null && buyOutPrice > 0 && !isSeller) ...[
            _BuyNowCard(
              price: buyOutPrice,
              onConfirm: () => _confirmBuyNow(context, buyOutPrice),
            ),
            const SizedBox(height: 16),
          ],
          if (isSeller)
            _SellerActionCard(onClose: () => _confirmCloseAuction(context)),
          if (!isSeller) ...[
            _BidFormCard(
              controller: _amountController,
              placingBid: _placingBid,
              price: price,
              minIncrement: minIncrement,
              minimum: minimum,
              onSubmit: () => _submitBid(snapshot, minIncrement),
            ),
            const SizedBox(height: 16),
          ],
        ],

        // Ficha técnica
        if (auctionObj != null) ...[
          VehicleSpecsCard(auction: auctionObj),
          const SizedBox(height: 16),
        ],

        BidHistoryCard(
          state: bidsState,
          sessionUserId: sessionUser?.id,
          onLoadMore: () => ref
              .read(bidsControllerProvider(widget.auctionId).notifier)
              .loadMore(),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                final role = sessionUser?.role;
                context.go(role == UserRole.seller ? '/seller' : '/bidder');
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: Text(
              isSeller ? 'Volver al Panel de Vendedor' : 'Salir al Catálogo de Subastas',
              style: const TextStyle(
                fontFamily: AppFonts.headline,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _confirmBuyNow(BuildContext context, double price) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Compra Directa'),
        content: Text(
          '¿Deseas comprar este vehículo directamente por '
          '${formatCurrency(price)}?\n\n'
          'La subasta se cerrará inmediatamente y quedarás registrado '
          'como ganador.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondaryDeep,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar Compra'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(auctionsRepositoryProvider).buyNow(widget.auctionId);
      if (mounted) {
        setState(() {
          _closed = true;
          _currentPrice = price;
        });
      }
      ref.invalidate(auctionDetailProvider(widget.auctionId));
      ref.invalidate(bidsControllerProvider(widget.auctionId));
      ref.invalidate(activeAuctionsProvider);
      ref.invalidate(sellerAuctionsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primaryInverted,
              content: const Row(
                children: [
                  Icon(Icons.emoji_events_rounded,
                      color: AppColors.secondary, size: 20),
                  SizedBox(width: 10),
                  Expanded(child: Text('¡Compra directa exitosa!')),
                ],
              ),
            ),
          );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: AppColors.tertiary,
              content: Text('Error en compra directa: $e'),
            ),
          );
      }
    }
  }

  Future<void> _confirmCloseAuction(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Subasta'),
        content: const Text(
          '¿Estás seguro de que deseas finalizar la subasta ahora?\n\n'
          'Si existen pujas registradas, se adjudicará al mejor postor actual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Finalizar Ahora'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(auctionsRepositoryProvider)
          .closeAuction(widget.auctionId);
      ref.invalidate(sellerAuctionsProvider);
      ref.invalidate(activeAuctionsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: AppColors.tertiary,
              content: Text('Error al finalizar subasta: $e'),
            ),
          );
      }
    }
  }
}

/// Panel oscuro con el precio en vivo, countdown y mejor postor.
class _LivePricePanel extends StatelessWidget {
  const _LivePricePanel({
    required this.price,
    required this.remaining,
    required this.isClosed,
    required this.flash,
    required this.topBidderName,
    required this.isMine,
  });

  final double price;
  final Duration remaining;
  final bool isClosed;
  final bool flash;
  final String? topBidderName;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final urgent = !isClosed &&
        !remaining.isNegative &&
        remaining <= const Duration(minutes: 5);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: flash ? AppColors.secondary : Colors.transparent,
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: flash
                ? AppColors.secondary.withAlpha(90)
                : const Color(0x2E0F172A),
            blurRadius: flash ? 22 : 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.payments_rounded,
                      size: 15,
                      color: AppColors.secondary.withAlpha(220)),
                  const SizedBox(width: 7),
                  Text(
                    'OFERTA ACTUAL',
                    style: TextStyle(
                      fontFamily: AppFonts.label,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white.withAlpha(190),
                    ),
                  ),
                ],
              ),
              if (!isClosed)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: flash ? 0 : 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'EN VIVO',
                          style: TextStyle(
                            fontFamily: AppFonts.label,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.35),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            key: ValueKey(price),
            child: Text(
              formatCurrency(price),
              key: ValueKey(price),
              style: TextStyle(
                fontFamily: AppFonts.label,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.1,
                color: flash ? AppColors.secondary : Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            child:
                Divider(height: 1, color: Colors.white.withAlpha(38)),
          ),
          Row(
            children: [
              Expanded(
                child: _darkStat(
                  icon: Icons.timer_outlined,
                  label: 'TIEMPO RESTANTE',
                  value: isClosed
                      ? 'Finalizada'
                      : formatCountdown(remaining),
                  valueColor: isClosed
                      ? AppColors.textLight
                      : urgent
                          ? AppColors.tertiary
                          : AppColors.secondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _darkStat(
                  icon: Icons.sports_score_rounded,
                  label: 'MEJOR POSTOR',
                  value: topBidderName ?? 'Sin ofertas',
                  valueColor: isMine
                      ? AppColors.secondary
                      : Colors.white.withAlpha(230),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _darkStat({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: Colors.white.withAlpha(150)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.label,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: Colors.white.withAlpha(160),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.label,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Tarjeta de formulario de puja con incrementos rápidos.
class _BidFormCard extends StatelessWidget {
  const _BidFormCard({
    required this.controller,
    required this.placingBid,
    required this.price,
    required this.minIncrement,
    required this.minimum,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool placingBid;
  final double price;
  final double minIncrement;
  final double minimum;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withAlpha(80), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(35),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.gavel_rounded,
                        size: 17, color: AppColors.secondaryDeep),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Realizar una Oferta',
                    style: TextStyle(
                      fontFamily: AppFonts.headline,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Mín ${formatCurrency(minimum, decimals: 0)}',
                  style: const TextStyle(
                    fontFamily: AppFonts.label,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            enabled: !placingBid,
            style: const TextStyle(
              fontFamily: AppFonts.label,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: const TextStyle(
                fontFamily: AppFonts.label,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primary,
              ),
              hintText: minimum.toStringAsFixed(0),
              hintStyle: const TextStyle(
                fontFamily: AppFonts.label,
                fontWeight: FontWeight.bold,
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: AppColors.secondaryDeep, width: 1.8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            ),
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                _quickChip(context, price + minIncrement,
                    '+${formatCurrency(minIncrement, decimals: 0)}'),
                const SizedBox(width: 8),
                _quickChip(context, price + minIncrement * 2,
                    '+2× (${formatCurrency(minIncrement * 2, decimals: 0)})'),
                const SizedBox(width: 8),
                _quickChip(context, price + minIncrement * 5,
                    '+5× (${formatCurrency(minIncrement * 5, decimals: 0)})'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: placingBid ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondaryDeep,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.secondaryDeep.withAlpha(140),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: placingBid
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.gavel_rounded, size: 20),
              label: Text(
                placingBid ? 'Enviando oferta…' : 'Pujar Ahora',
                style: const TextStyle(
                  fontFamily: AppFonts.headline,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Confirmación instantánea vía WebSocket',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 11,
                color: AppColors.neutral.withAlpha(255),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickChip(BuildContext context, double target, String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () => controller.text = target.toStringAsFixed(0),
      backgroundColor: AppColors.surfaceVariant,
      side: const BorderSide(color: AppColors.border),
      labelPadding: const EdgeInsets.symmetric(horizontal: 10),
      labelStyle: const TextStyle(
        fontFamily: AppFonts.label,
        fontWeight: FontWeight.bold,
        fontSize: 11.5,
        color: AppColors.primary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

/// Tarjeta de compra directa (bidder, subasta activa).
class _BuyNowCard extends StatelessWidget {
  const _BuyNowCard({required this.price, required this.onConfirm});

  final double price;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.successGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withAlpha(70),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compra Directa Disponible',
                      style: TextStyle(
                        fontFamily: AppFonts.headline,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Gana la subasta al instante sin esperar el cierre',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 12,
                        color: Color(0xCCFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.secondaryDeep,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              icon: const Icon(Icons.shopping_bag_outlined, size: 19),
              label: Text(
                'Comprar por ${formatCurrency(price)}',
                style: const TextStyle(
                  fontFamily: AppFonts.headline,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Acciones del vendedor sobre su propia subasta activa.
class _SellerActionCard extends StatelessWidget {
  const _SellerActionCard({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.tertiary.withAlpha(110)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withAlpha(22),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.admin_panel_settings_outlined,
                color: AppColors.tertiary, size: 21),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acción del Vendedor',
                  style: TextStyle(
                    fontFamily: AppFonts.headline,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Puedes finalizar antes del tiempo límite',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onClose,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.tertiary,
              side: const BorderSide(color: AppColors.tertiary),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontFamily: AppFonts.headline,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }
}
