import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/socket_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_nav_bar.dart';
import '../../../core/widgets/state_views.dart';
import '../../auctions/presentation/auction_catalog_widgets.dart';
import '../../auctions/presentation/catalog_provider.dart';

/// Catálogo de subastas activas para el comprador.
class BidderHomeScreen extends ConsumerStatefulWidget {
  const BidderHomeScreen({super.key});

  @override
  ConsumerState<BidderHomeScreen> createState() => _BidderHomeScreenState();
}

class _BidderHomeScreenState extends ConsumerState<BidderHomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  StreamSubscription? _startedSub;
  StreamSubscription? _newBidsSub;
  StreamSubscription? _closedSub;

  @override
  void initState() {
    super.initState();
    final socket = ref.read(socketClientProvider);
    // Broadcast global: una subasta pasó de 'scheduled' a 'active'.
    _startedSub = socket.auctionStarted.listen((_) {
      if (!mounted) return;
      ref.invalidate(activeAuctionsProvider);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryInverted,
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child:
                      Text('¡Una nueva subasta acaba de comenzar en vivo!'),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
    });

    _newBidsSub = socket.newBids.listen((_) {
      if (mounted) {
        ref.invalidate(activeAuctionsProvider);
        ref.invalidate(myBidsProvider);
      }
    }, onError: (_) {});

    _closedSub = socket.auctionClosed.listen((_) {
      if (mounted) {
        ref.invalidate(activeAuctionsProvider);
        ref.invalidate(myBidsProvider);
      }
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _startedSub?.cancel();
    _newBidsSub?.cancel();
    _closedSub?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<VehicleCategory>(vehicleCategoryProvider, (previous, next) {
      if (previous != next && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });

    final filteredAuctionsAsync = ref.watch(filteredActiveAuctionsProvider);
    final selectedSort = ref.watch(catalogSortOptionProvider);
    final selectedCategory = ref.watch(vehicleCategoryProvider);
    final myBidsAsync = ref.watch(myBidsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppNavBar(
        actions: [
          NavBarIconButton(
            icon: Icons.person_outline_rounded,
            tooltip: 'Mi Perfil',
            onPressed: () => context.go('/bidder/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.secondary,
          onRefresh: () async {
            ref.invalidate(myBidsProvider);
            ref.invalidate(activeAuctionsProvider);
            await ref.read(activeAuctionsProvider.future);
          },
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              if (selectedCategory != VehicleCategory.all) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(22),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.secondary, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Icon(selectedCategory.icon,
                          size: 18, color: AppColors.secondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FILTRADO POR CATEGORÍA',
                              style: TextStyle(
                                fontFamily: AppFonts.label,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              selectedCategory.label,
                              style: const TextStyle(
                                fontFamily: AppFonts.headline,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => ref
                            .read(vehicleCategoryProvider.notifier)
                            .state = VehicleCategory.all,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              _buildSearchField(),
              const SizedBox(height: 16),
              if (selectedCategory == VehicleCategory.all)
                myBidsAsync.maybeWhen(
                  data: (bids) {
                    if (bids.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyBidsCarousel(bids: bids),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              SectionHeader(
                selectedCategory == VehicleCategory.all
                    ? 'Todas las subastas'
                    : selectedCategory.label,
                trailing: CountBadge(
                  filteredAuctionsAsync.valueOrNull?.length ?? 0,
                ),
              ),
              const SizedBox(height: 14),
              _buildSortChips(selectedSort),
              const SizedBox(height: 16),
              filteredAuctionsAsync.when(
                loading: () => const AuctionCardSkeletonList(),
                error: (error, _) => ErrorStateView(
                  message: '$error',
                  title: 'No se pudo cargar el catálogo',
                  onRetry: () => ref.invalidate(activeAuctionsProvider),
                ),
                data: (auctions) {
                  if (auctions.isEmpty) {
                    final hasQuery = _searchController.text.isNotEmpty;
                    final isCategoryFiltered =
                        selectedCategory != VehicleCategory.all;

                    return EmptyStateView(
                      icon: isCategoryFiltered
                          ? selectedCategory.icon
                          : Icons.search_off_rounded,
                      title: isCategoryFiltered
                          ? 'Sin vehículos en "${selectedCategory.label}"'
                          : 'Sin resultados',
                      message: isCategoryFiltered
                          ? 'No se encontraron subastas activas para esta categoría actualmente.'
                          : 'No se encontraron subastas que coincidan con tu búsqueda.',
                      actionLabel: isCategoryFiltered
                          ? 'Ver todas las categorías'
                          : (hasQuery ? 'Limpiar búsqueda' : null),
                      onAction: () {
                        if (isCategoryFiltered) {
                          ref
                              .read(vehicleCategoryProvider.notifier)
                              .state = VehicleCategory.all;
                        }
                        if (hasQuery) {
                          _searchController.clear();
                          ref
                              .read(catalogSearchQueryProvider.notifier)
                              .state = '';
                        }
                      },
                    );
                  }
                  return Column(
                    children: [
                      for (final auction in auctions)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: AuctionCard(auction: auction),
                        ),
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

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (text) =>
          ref.read(catalogSearchQueryProvider.notifier).state = text,
      decoration: InputDecoration(
        hintText: 'Buscar por marca, modelo o descripción…',
        hintStyle: const TextStyle(
          fontFamily: AppFonts.body,
          color: AppColors.neutral,
          fontSize: 14,
        ),
        prefixIcon:
            const Icon(Icons.search_rounded, color: AppColors.neutral),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  _searchController.clear();
                  ref.read(catalogSearchQueryProvider.notifier).state = '';
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildSortChips(CatalogSortOption current) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _sortChip('Todas', CatalogSortOption.all, current),
          const SizedBox(width: 8),
          _sortChip('Terminando pronto', CatalogSortOption.endingSoon, current),
          const SizedBox(width: 8),
          _sortChip('Menor precio', CatalogSortOption.lowestPrice, current),
          const SizedBox(width: 8),
          _sortChip('Mayor precio', CatalogSortOption.highestPrice, current),
        ],
      ),
    );
  }

  Widget _sortChip(
    String label,
    CatalogSortOption option,
    CatalogSortOption current,
  ) {
    final isSelected = option == current;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (selected) {
        if (selected) {
          ref.read(catalogSortOptionProvider.notifier).state = option;
        }
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
