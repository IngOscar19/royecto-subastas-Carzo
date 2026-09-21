import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/image_gallery.dart';
import '../../../core/widgets/live_countdown_badge.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../data/auctions_repository.dart';
import '../domain/auction.dart';

/// Tarjeta principal del catálogo: galería con overlays, precio destacado,
/// datos clave y CTA hacia la sala en vivo.
class AuctionCard extends StatelessWidget {
  const AuctionCard({super.key, required this.auction});

  final Auction auction;

  @override
  Widget build(BuildContext context) {
    final isClosed = auction.status == 'closed';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: () => context.go('/bidder/auction/${auction.id}'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C0F172A),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ImageGallery(
                    imageUrls: auction.imageUrls,
                    height: 180,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(17)),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusChip(
                          auction.effectiveStatus,
                          style: StatusChipStyle.translucent,
                        ),
                        CategoryChip(
                          category: auction.vehicleCategory,
                          style: CategoryChipStyle.translucent,
                        ),
                      ],
                    ),
                  ),
                  if (!isClosed)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: LiveCountdownBadge(
                        endTime: auction.endTime,
                        style: CountdownStyle.onImage,
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.headline,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (auction.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 5),
                      Text(
                        auction.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 11),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(10),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                  color: AppColors.secondary.withAlpha(60)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'OFERTA ACTUAL',
                                  style: TextStyle(
                                    fontFamily: AppFonts.label,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                    color: AppColors.neutral,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  formatCurrency(auction.currentPrice),
                                  style: const TextStyle(
                                    fontFamily: AppFonts.label,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondaryDeep,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _secondaryInfo(auction),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton.icon(
                        onPressed: () =>
                            context.go('/bidder/auction/${auction.id}'),
                        icon: Icon(
                          isClosed
                              ? Icons.visibility_outlined
                              : Icons.gavel_rounded,
                          size: 18,
                        ),
                        label: Text(
                          isClosed ? 'Ver Resultado' : 'Entrar y Pujar',
                          style: const TextStyle(
                            fontFamily: AppFonts.headline,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bloque derecho: compra directa si existe; si no, precio de salida.
  Widget _secondaryInfo(Auction auction) {
    final buyOut = auction.buyOutPrice;
    if (buyOut != null && buyOut > 0) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.secondary.withAlpha(22),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.secondary.withAlpha(70)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt_rounded,
                    size: 12, color: AppColors.secondaryDeep),
                const SizedBox(width: 4),
                const Text(
                  'COMPRA DIRECTA',
                  style: TextStyle(
                    fontFamily: AppFonts.label,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: AppColors.secondaryDeep,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              formatCurrency(buyOut),
              style: const TextStyle(
                fontFamily: AppFonts.label,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryDeep,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border.withAlpha(120)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRECIO DE SALIDA',
            style: TextStyle(
              fontFamily: AppFonts.label,
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
              color: AppColors.neutral,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            formatCurrency(auction.startingPrice),
            style: const TextStyle(
              fontFamily: AppFonts.label,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carrusel horizontal con las ofertas enviadas por el comprador.
class MyBidsCarousel extends StatelessWidget {
  const MyBidsCarousel({super.key, required this.bids});

  final List<UserBidItem> bids;

  @override
  Widget build(BuildContext context) {
    if (bids.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.gavel_rounded,
                    size: 15,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                const SectionTitle('Tus ofertas enviadas'),
              ],
            ),
            Row(
              children: [
                CountBadge(bids.length),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => context.push('/bidder/profile'),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    child: Text(
                      'Ver todas',
                      style: TextStyle(
                        fontFamily: AppFonts.label,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            itemCount: bids.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _MyBidCard(item: bids[index]),
          ),
        ),
      ],
    );
  }
}

class _MyBidCard extends StatelessWidget {
  const _MyBidCard({required this.item});

  final UserBidItem item;

  @override
  Widget build(BuildContext context) {
    final coverUrl = item.coverUrl;
    final isActive = item.auctionStatus == 'active';
    final isWinning =
        item.myHighestBid >= item.currentPrice && item.myHighestBid > 0;
    const winningColor = Color(0xFF16A34A);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/bidder/auction/${item.auctionId}'),
        child: Container(
          width: 236,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isWinning && isActive
                  ? winningColor.withAlpha(120)
                  : AppColors.border,
              width: isWinning && isActive ? 1.5 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C0F172A),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: coverUrl != null
                        ? Image.network(
                            coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const _BidFallbackImage(),
                          )
                        : const _BidFallbackImage(),
                  ),
                  Positioned(
                    top: 7,
                    left: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isActive
                                ? AppColors.secondary
                                : AppColors.primaryInverted)
                            .withAlpha(220),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isActive) ...[
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            isActive ? 'En vivo' : 'Finalizada',
                            style: const TextStyle(
                              fontFamily: AppFonts.label,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isWinning && isActive)
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: winningColor.withAlpha(230),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up_rounded,
                                size: 11, color: Colors.white),
                            SizedBox(width: 3),
                            Text(
                              'Ganando',
                              style: TextStyle(
                                fontFamily: AppFonts.label,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.auctionTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.headline,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tu oferta',
                                style: TextStyle(
                                  fontFamily: AppFonts.body,
                                  fontSize: 9.5,
                                  color: AppColors.neutral,
                                ),
                              ),
                              Text(
                                formatCurrency(item.myHighestBid),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: AppFonts.label,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Actual',
                                style: TextStyle(
                                  fontFamily: AppFonts.body,
                                  fontSize: 9.5,
                                  color: AppColors.neutral,
                                ),
                              ),
                              Text(
                                formatCurrency(item.currentPrice),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppFonts.label,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: isWinning && isActive
                                      ? winningColor
                                      : AppColors.secondaryDeep,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BidFallbackImage extends StatelessWidget {
  const _BidFallbackImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: const Icon(Icons.directions_car_rounded,
          color: AppColors.neutral, size: 28),
    );
  }
}

/// Carrusel horizontal "cierran primero": hasta 5 subastas ordenadas por
/// tiempo de cierre ascendente.
class FeaturedAuctionCarousel extends StatelessWidget {
  const FeaturedAuctionCarousel({super.key, required this.auctions});

  final List<Auction> auctions;

  @override
  Widget build(BuildContext context) {
    final featured = auctions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department_rounded,
                    size: 18, color: AppColors.warning),
                const SizedBox(width: 6),
                const SectionTitle('Cierran primero'),
              ],
            ),
            Text(
              'Desliza',
              style: TextStyle(
                fontFamily: AppFonts.label,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: AppColors.textLight.withAlpha(255),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 218,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            itemCount: featured.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _FeaturedCard(auction: featured[index]),
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppFonts.headline,
        fontSize: 17,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.auction});

  final Auction auction;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/bidder/auction/${auction.id}'),
        child: Container(
          width: 236,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C0F172A),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ImageGallery(
                    imageUrls: auction.imageUrls.take(1).toList(),
                    height: 118,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15)),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: CategoryChip(
                      category: auction.vehicleCategory,
                      style: CategoryChipStyle.translucent,
                      compact: true,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: LiveCountdownBadge(
                        endTime: auction.endTime,
                        style: CountdownStyle.onImage,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.headline,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          'Actual ',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 11,
                            color: AppColors.neutral,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            formatCurrency(auction.currentPrice),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppFonts.label,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tira de métricas en vivo del catálogo.
class LiveMetricsStrip extends StatelessWidget {
  const LiveMetricsStrip({super.key, required this.auctions});

  final List<Auction> auctions;

  @override
  Widget build(BuildContext context) {
    final closingSoon = auctions
        .where((a) =>
            a.endTime.difference(DateTime.now()) <= const Duration(hours: 1))
        .length;
    final totalValue =
        auctions.fold<double>(0, (sum, a) => sum + a.currentPrice);

    return Row(
      children: [
        Expanded(
          child: MetricCard(
            icon: Icons.circle,
            iconColor: AppColors.secondary,
            value: '${auctions.length}',
            label: 'En vivo',
            pulse: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: MetricCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.warning,
            value: '$closingSoon',
            label: 'Cierran <1h',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: MetricCard(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.primary,
            value: formatCompactCurrency(totalValue),
            label: 'Valor total',
          ),
        ),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.pulse = false,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withAlpha(150)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pulse
              ? _PulsingDot(color: iconColor)
              : Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: AppFonts.label,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: iconColor == AppColors.warning
                    ? AppColors.textPrimary
                    : iconColor,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.35, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Icon(Icons.circle, size: 12, color: widget.color),
    );
  }
}
