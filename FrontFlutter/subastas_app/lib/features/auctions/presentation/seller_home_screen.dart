import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/socket_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_nav_bar.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/live_countdown_badge.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/auctions_repository.dart';
import '../domain/auction.dart';
import 'auction_catalog_widgets.dart' show MetricCard;
import 'catalog_provider.dart';
import 'publish_auction_sheet.dart';

enum SellerFilterStatus { all, active, scheduled, closed }

/// Panel del vendedor: banner de bienvenida, métricas del portafolio y
/// gestión de subastas publicadas.
class SellerHomeScreen extends ConsumerStatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  ConsumerState<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends ConsumerState<SellerHomeScreen> {
  SellerFilterStatus _selectedFilter = SellerFilterStatus.all;
  StreamSubscription? _newBidsSub;
  StreamSubscription? _closedSub;
  StreamSubscription? _startedSub;

  @override
  void initState() {
    super.initState();
    final socket = ref.read(socketClientProvider);
    _newBidsSub = socket.newBids.listen((_) {
      if (mounted) ref.invalidate(sellerAuctionsProvider);
    }, onError: (_) {});
    _closedSub = socket.auctionClosed.listen((_) {
      if (mounted) ref.invalidate(sellerAuctionsProvider);
    }, onError: (_) {});
    _startedSub = socket.auctionStarted.listen((_) {
      if (mounted) ref.invalidate(sellerAuctionsProvider);
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _newBidsSub?.cancel();
    _closedSub?.cancel();
    _startedSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).valueOrNull;
    final auctionsAsync = ref.watch(sellerAuctionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppNavBar(
        actions: [
          NavBarIconButton(
            icon: Icons.person_outline_rounded,
            tooltip: 'Mi Perfil',
            onPressed: () => context.go('/seller/profile'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => PublishAuctionSheet.show(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nueva Subasta',
          style: TextStyle(
            fontFamily: AppFonts.headline,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(sellerAuctionsProvider);
            await ref.read(sellerAuctionsProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              auctionsAsync.when(
                loading: () => const AuctionCardSkeletonList(count: 2),
                error: (error, _) => ErrorStateView(
                  message: '$error',
                  title: 'Error al cargar tus subastas',
                  onRetry: () => ref.invalidate(sellerAuctionsProvider),
                ),
                data: (allAuctions) {
                  if (allAuctions.isEmpty) {
                    return Column(
                      children: [
                        _SellerWelcomeBanner(name: session?.name),
                        const SizedBox(height: 20),
                        EmptyStateView(
                          icon: Icons.directions_car_filled_outlined,
                          title: 'Publica tu primera subasta',
                          message:
                              'Presiona "Nueva Subasta" para poner tu vehículo en venta en tiempo real.',
                          actionLabel: 'Publicar ahora',
                          onAction: () => PublishAuctionSheet.show(context),
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SellerWelcomeBanner(name: session?.name),
                      const SizedBox(height: 16),
                      _PortfolioMetrics(auctions: allAuctions),
                      const SizedBox(height: 24),
                      SectionHeader(
                        'Mis subastas publicadas',
                        trailing: CountBadge(
                          _filter(allAuctions).length,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildFilterChips(),
                      const SizedBox(height: 16),
                      ..._filter(allAuctions)
                          .map((auction) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _SellerAuctionCard(auction: auction),
                              ))
                          ,
                      const SizedBox(height: 80),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Auction> _filter(List<Auction> list) {
    switch (_selectedFilter) {
      case SellerFilterStatus.active:
        return list.where((a) => a.effectiveStatus == 'active').toList();
      case SellerFilterStatus.scheduled:
        return list.where((a) => a.effectiveStatus == 'scheduled').toList();
      case SellerFilterStatus.closed:
        return list.where((a) => a.effectiveStatus == 'closed').toList();
      case SellerFilterStatus.all:
        return list;
    }
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _chip('Todas', SellerFilterStatus.all),
          const SizedBox(width: 8),
          _chip('Activas', SellerFilterStatus.active),
          const SizedBox(width: 8),
          _chip('Programadas', SellerFilterStatus.scheduled),
          const SizedBox(width: 8),
          _chip('Finalizadas', SellerFilterStatus.closed),
        ],
      ),
    );
  }

  Widget _chip(String label, SellerFilterStatus status) {
    final isSelected = _selectedFilter == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilter = status);
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      labelStyle: TextStyle(
        fontFamily: AppFonts.label,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12.5,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SellerWelcomeBanner extends StatelessWidget {
  const _SellerWelcomeBanner({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/seller/profile'),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x200F172A),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary, width: 2),
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primaryInverted,
                backgroundImage: null,
                child: Text(
                  name?.isNotEmpty == true
                      ? name![0].toUpperCase()
                      : 'V',
                  style: const TextStyle(
                    fontFamily: AppFonts.headline,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '¡Hola, ${name?.split(' ').first ?? 'Vendedor'}!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppFonts.headline,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.stars_rounded,
                          size: 18, color: AppColors.secondary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Gestiona tus vehículos y publica nuevas subastas',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 13,
                      color: AppColors.border,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _PortfolioMetrics extends StatelessWidget {
  const _PortfolioMetrics({required this.auctions});

  final List<Auction> auctions;

  @override
  Widget build(BuildContext context) {
    final active =
        auctions.where((a) => a.effectiveStatus == 'active').toList();
    final scheduled =
        auctions.where((a) => a.effectiveStatus == 'scheduled').length;
    final closed = auctions.where((a) => a.effectiveStatus == 'closed').length;
    final liveValue = active.fold<double>(0, (s, a) => s + a.currentPrice);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Portafolio en vivo'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.circle,
                iconColor: AppColors.secondary,
                value: '${active.length}',
                label: 'Activas',
                pulse: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                icon: Icons.schedule_rounded,
                iconColor: AppColors.warning,
                value: '$scheduled',
                label: 'Programadas',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.emoji_events_outlined,
                iconColor: AppColors.primary,
                value: '$closed',
                label: 'Finalizadas',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.secondaryDeep,
                value: formatCompactCurrency(liveValue),
                label: 'Valor en pujas',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _SellerAuctionCard extends ConsumerWidget {
  const _SellerAuctionCard({required this.auction});

  final Auction auction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveStatus = auction.effectiveStatus;
    final isActive = effectiveStatus == 'active';
    final isScheduled = effectiveStatus == 'scheduled';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await context.push('/seller/auction/${auction.id}');
          ref.invalidate(sellerAuctionsProvider);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
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
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Miniatura
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: SizedBox(
                      width: 92,
                      height: 92,
                      child: auction.imageUrls.isNotEmpty
                          ? Image.network(
                              auction.imageUrls.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const _ThumbFallback(),
                            )
                          : const _ThumbFallback(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Info principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    auction.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: AppFonts.headline,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  CategoryChip(
                                    category: auction.vehicleCategory,
                                    style: CategoryChipStyle.tinted,
                                    compact: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusChip(auction.effectiveStatus),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              isActive ? 'Actual ' : 'Precio final ',
                              style: const TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 12,
                                color: AppColors.neutral,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                formatCurrency(auction.currentPrice),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppFonts.label,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isActive
                                      ? AppColors.secondaryDeep
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(width: 10),
                              Container(
                                width: 1,
                                height: 14,
                                color: AppColors.border,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  '+${formatCurrency(auction.minIncrement, decimals: 0)} mín.',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.label,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (isActive)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: LiveCountdownBadge(
                              endTime: auction.endTime,
                              style: CountdownStyle.tinted,
                            ),
                          )
                        else if (isScheduled)
                          Text(
                            'Cierra ${formatDateTimeEs(auction.endTime)}',
                            style: const TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 11.5,
                              color: AppColors.neutral,
                            ),
                          )
                        else
                          Text(
                            'Cerró el ${formatDateEs(auction.endTime)}',
                            style: const TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 11.5,
                              color: AppColors.neutral,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isActive) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await context.push('/seller/auction/${auction.id}');
                          ref.invalidate(sellerAuctionsProvider);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: AppFonts.headline,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: const Icon(Icons.visibility_outlined,
                            size: 16),
                        label: const Text('Ver Sala'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _confirmClose(context, ref, auction),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.tertiary,
                          side: const BorderSide(color: AppColors.tertiary),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: AppFonts.headline,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: const Icon(Icons.stop_circle_outlined,
                            size: 16),
                        label: const Text('Finalizar'),
                      ),
                    ),
                  ],
                ),
              ],
              if (!isActive && !isScheduled) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context.push('/seller/auction/${auction.id}');
                      ref.invalidate(sellerAuctionsProvider);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: AppFonts.headline,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const Icon(Icons.receipt_long_rounded, size: 16),
                    label: const Text('Ver Resultado / Sala'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClose(
    BuildContext context,
    WidgetRef ref,
    Auction auction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Subasta'),
        content: Text(
          '¿Deseas finalizar "${auction.title}" ahora?\n\n'
          'Si hay pujas registradas, se adjudicará al mejor postor actual '
          '(${formatCurrency(auction.currentPrice)}).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.stop_circle_outlined, size: 18),
            label: const Text('Finalizar Ahora'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(auctionsRepositoryProvider).closeAuction(auction.id);
      ref.invalidate(sellerAuctionsProvider);
      ref.invalidate(activeAuctionsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primaryInverted,
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      color: AppColors.secondary, size: 20),
                  SizedBox(width: 10),
                  Expanded(child: Text('Subasta finalizada exitosamente')),
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
              content: Text('Error al finalizar subasta: $e'),
            ),
          );
      }
    }
  }
}

class _ThumbFallback extends StatelessWidget {
  const _ThumbFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: const Icon(
        Icons.directions_car_filled_outlined,
        size: 30,
        color: AppColors.textLight,
      ),
    );
  }
}
