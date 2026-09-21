import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_nav_bar.dart';
import '../../../core/widgets/state_views.dart';
import '../../auctions/data/auctions_repository.dart';
import '../../auctions/domain/auction.dart';
import '../../auctions/presentation/catalog_provider.dart';
import '../domain/user_role.dart';
import 'auth_controller.dart';

final wonAuctionsProvider =
    FutureProvider.autoDispose.family<List<Auction>, String>((ref, userId) async {
  ref.watch(authControllerProvider);
  final repository = ref.watch(auctionsRepositoryProvider);
  return repository.fetchWonAuctions(userId);
});


class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  int _bidderTabIndex = 0; // 0: Mis Ofertas, 1: Ganadas
  String _sellerFilterStatus = 'all'; // all, active, closed
  final Set<String> _paidAuctionIds = {};

  void _markAsPaid(String auctionId) {
    setState(() {
      _paidAuctionIds.add(auctionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isSeller = user.role == UserRole.seller;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppNavBar(
          title: 'Perfil de Usuario',
          icon: isSeller ? Icons.sell_outlined : Icons.person_outline,
          showBackButton: true,
          onBackPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(isSeller ? '/seller' : '/bidder');
            }
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile Header Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSeller
                              ? AppColors.primary
                              : AppColors.secondary,
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: isSeller
                            ? AppColors.primary
                            : AppColors.secondary,
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontFamily: AppFonts.headline,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontFamily: AppFonts.headline,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isSeller
                                ? AppColors.primary
                                : AppColors.secondary)
                            .withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (isSeller
                                  ? AppColors.primary
                                  : AppColors.secondary)
                              .withAlpha(80),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSeller ? Icons.sell_outlined : Icons.gavel,
                            size: 16,
                            color: isSeller
                                ? AppColors.primary
                                : AppColors.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isSeller
                                ? 'Vendedor Autorizado'
                                : 'Comprador Activo',
                            style: TextStyle(
                              fontFamily: AppFonts.label,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSeller
                                  ? AppColors.primary
                                  : AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section Header & History List based on Role
            if (isSeller) ...[
              _buildSellerHistory(user.id),
            ] else ...[
              _buildBidderHistory(user.id),
            ],

            const SizedBox(height: 24),

            // Account Details Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shield_outlined,
                              size: 18, color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Información de la Cuenta',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: AppFonts.headline,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _ProfileDetailRow(
                      icon: Icons.fingerprint,
                      label: 'ID de Usuario',
                      value: user.id,
                      isMonospace: true,
                    ),
                    const Divider(color: AppColors.border, height: 24),
                    _ProfileDetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Miembro Desde',
                      value: user.createdAt.toLocal().toString().split(' ')[0],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Logout Action
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.tertiary,
                  side: const BorderSide(color: AppColors.tertiary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    fontFamily: AppFonts.headline,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerHistory(String sellerId) {
    final sellerAuctionsAsync = ref.watch(sellerAuctionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            const Text(
              'Mis Subastas Creadas',
              style: TextStyle(
                fontFamily: AppFonts.headline,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FilterChip(
                  label: 'Todas',
                  isSelected: _sellerFilterStatus == 'all',
                  onTap: () => setState(() => _sellerFilterStatus = 'all'),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: 'Activas',
                  isSelected: _sellerFilterStatus == 'active',
                  onTap: () => setState(() => _sellerFilterStatus = 'active'),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: 'Cerradas',
                  isSelected: _sellerFilterStatus == 'closed',
                  onTap: () => setState(() => _sellerFilterStatus = 'closed'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        sellerAuctionsAsync.when(
          data: (auctions) {
            final filtered = auctions.where((a) {
              if (_sellerFilterStatus == 'active') return a.status == 'active';
              if (_sellerFilterStatus == 'closed') return a.status == 'closed';
              return true;
            }).toList();

            if (filtered.isEmpty) {
              return const _EmptyStateCard(
                icon: Icons.inventory_2_outlined,
                message: 'No tienes subastas registradas en este estado.',
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final auction = filtered[index];
                return _HistoryAuctionTile(
                  title: auction.title,
                  coverUrl: auction.coverUrl,
                  status: auction.status,
                  priceLabel: 'Precio actual: \$${auction.currentPrice.toStringAsFixed(2)}',
                  onTap: () => context.push('/seller/auction/${auction.id}'),
                );
              },
            );
          },
          loading: () => _buildShimmerPlaceholderList(count: 2),
          error: (err, _) => Text('Error al cargar subastas: $err'),
        ),
      ],
    );
  }

  Widget _buildBidderHistory(String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _bidderTabIndex = 0),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _bidderTabIndex == 0
                        ? AppColors.secondary
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _bidderTabIndex == 0
                          ? AppColors.secondary
                          : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Mis Ofertas Enviadas',
                      style: TextStyle(
                        fontFamily: AppFonts.headline,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _bidderTabIndex == 0
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _bidderTabIndex = 1),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _bidderTabIndex == 1
                        ? AppColors.secondary
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _bidderTabIndex == 1
                          ? AppColors.secondary
                          : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Subastas Ganadas 🏆',
                      style: TextStyle(
                        fontFamily: AppFonts.headline,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _bidderTabIndex == 1
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_bidderTabIndex == 0) _buildMyBidsList() else _buildWonAuctionsList(userId),
      ],
    );
  }

  Widget _buildMyBidsList() {
    final bidsAsync = ref.watch(myBidsProvider);

    return bidsAsync.when(
      data: (bids) {
        if (bids.isEmpty) {
          return const _EmptyStateCard(
            icon: Icons.gavel_outlined,
            message: 'Aún no has realizado ninguna oferta en subastas.',
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bids.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = bids[index];
            final coverUrl = item.coverUrl;

            return _HistoryAuctionTile(
              title: item.auctionTitle,
              coverUrl: coverUrl,
              status: item.auctionStatus,
              priceLabel: 'Mi Oferta: \$${item.myHighestBid.toStringAsFixed(2)} | Actual: \$${item.currentPrice.toStringAsFixed(2)}',
              onTap: () => context.push('/bidder/auction/${item.auctionId}'),
            );
          },
        );
      },
      loading: () => _buildShimmerPlaceholderList(count: 2),
      error: (err, stack) => Text('Error al cargar historial de ofertas: $err'),
    );
  }

  Widget _buildWonAuctionsList(String userId) {
    final wonAsync = ref.watch(wonAuctionsProvider(userId));

    return wonAsync.when(
      data: (auctions) {
        if (auctions.isEmpty) {
          return const _EmptyStateCard(
            icon: Icons.emoji_events_outlined,
            message: 'Aún no has ganado ninguna subasta. ¡Sigue participando y ofertando en el catálogo!',
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: auctions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final auction = auctions[index];
            final isPaid = _paidAuctionIds.contains(auction.id);

            return _WonAuctionCard(
              auction: auction,
              isPaid: isPaid,
              onPayPressed: () => _showPaymentSheet(context, auction),
              onContactPressed: () => _showContactSheet(context, auction),
              onViewDetails: () => context.push('/bidder/auction/${auction.id}'),
            );
          },
        );
      },
      loading: () => _buildShimmerPlaceholderList(count: 2),
      error: (err, stack) => Text('Error al cargar subastas ganadas: $err'),
    );
  }

  Widget _buildShimmerPlaceholderList({int count = 2}) {
    return ShimmerLoading(
      child: Column(
        children: [
          for (var i = 0; i < count; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 90,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, Auction auction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SimulatedPaymentSheet(
        auction: auction,
        onPaymentSuccess: () {
          _markAsPaid(auction.id);
        },
      ),
    );
  }

  void _showContactSheet(BuildContext context, Auction auction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ContactSellerSheet(auction: auction),
    );
  }
}

class _WonAuctionCard extends StatelessWidget {
  const _WonAuctionCard({
    required this.auction,
    required this.isPaid,
    required this.onPayPressed,
    required this.onContactPressed,
    required this.onViewDetails,
  });

  final Auction auction;
  final bool isPaid;
  final VoidCallback onPayPressed;
  final VoidCallback onContactPressed;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final coverUrl = auction.coverUrl;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPaid ? AppColors.secondary.withAlpha(120) : const Color(0xFFEAB308),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E0F172A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de Victoria
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPaid
                    ? [const Color(0xFF059669), const Color(0xFF10B981)]
                    : [const Color(0xFFB45309), const Color(0xFFF59E0B)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  isPaid ? Icons.verified_rounded : Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isPaid ? '¡VEHÍCULO LIQUIDADO & ADJUDICADO!' : '¡SUBASTA GANADA · PENDIENTE DE PAGO!',
                    style: const TextStyle(
                      fontFamily: AppFonts.headline,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPaid ? 'PAGADO' : 'GANADOR',
                    style: const TextStyle(
                      fontFamily: AppFonts.label,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Información del Vehículo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: coverUrl != null
                            ? Image.network(
                                coverUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: AppColors.surfaceVariant,
                                  child: const Icon(Icons.directions_car, size: 32, color: AppColors.neutral),
                                ),
                              )
                            : Container(
                                color: AppColors.surfaceVariant,
                                child: const Icon(Icons.directions_car, size: 32, color: AppColors.neutral),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auction.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppFonts.headline,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Precio Final Ganado:',
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 11,
                              color: AppColors.neutral.withAlpha(220),
                            ),
                          ),
                          Text(
                            '\$${auction.currentPrice.toStringAsFixed(2)} MXN',
                            style: const TextStyle(
                              fontFamily: AppFonts.label,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 14),

                // Botones de Acción
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: FilledButton.icon(
                        onPressed: onPayPressed,
                        style: FilledButton.styleFrom(
                          backgroundColor: isPaid ? const Color(0xFF059669) : AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          isPaid ? Icons.receipt_long_rounded : Icons.credit_card_rounded,
                          size: 18,
                        ),
                        label: Text(
                          isPaid ? 'Ver Comprobante' : 'Pagar / Liquidar',
                          style: const TextStyle(
                            fontFamily: AppFonts.headline,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: onContactPressed,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColors.border, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.chat_outlined, size: 16, color: AppColors.secondary),
                        label: const Text(
                          'Contactar',
                          style: TextStyle(
                            fontFamily: AppFonts.headline,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                      onPressed: onViewDetails,
                      tooltip: 'Ver sala de subasta',
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceVariant,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SimulatedPaymentSheet extends StatefulWidget {
  const _SimulatedPaymentSheet({
    required this.auction,
    required this.onPaymentSuccess,
  });

  final Auction auction;
  final VoidCallback onPaymentSuccess;

  @override
  State<_SimulatedPaymentSheet> createState() => _SimulatedPaymentSheetState();
}

class _SimulatedPaymentSheetState extends State<_SimulatedPaymentSheet> {
  int _paymentMethod = 0; // 0: Tarjeta, 1: SPEI / Transferencia, 2: Sucursal
  bool _isProcessing = false;
  bool _isSuccess = false;
  late final String _folioNumber;

  final _cardNumberCtrl = TextEditingController(text: '4532 •••• •••• 8821');
  final _cardExpCtrl = TextEditingController(text: '12/28');
  final _cardCvvCtrl = TextEditingController(text: '884');
  final _cardNameCtrl = TextEditingController(text: 'Oscar Romero');

  @override
  void initState() {
    super.initState();
    _folioNumber = 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
  }

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardExpCtrl.dispose();
    _cardCvvCtrl.dispose();
    _cardNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _isSuccess = true;
    });
    widget.onPaymentSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final basePrice = widget.auction.currentPrice;
    const fee = 150.0;
    final total = basePrice + fee;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.90,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(30),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.payment_rounded, size: 22, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pasarela de Liquidación',
                          style: TextStyle(
                            fontFamily: AppFonts.headline,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Pago seguro simulado de adjudicación',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 12,
                            color: AppColors.neutral.withAlpha(240),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: _isSuccess
                    ? _buildSuccessReceipt(total)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Resumen del Vehículo y Montos
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.auction.title,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.headline,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _priceSummaryRow('Precio Adjudicado (Oferta Ganadora)', '\$${basePrice.toStringAsFixed(2)}'),
                                const SizedBox(height: 6),
                                _priceSummaryRow('Comisión de Trámite & Plataforma', '\$${fee.toStringAsFixed(2)}'),
                                const Divider(height: 18, color: AppColors.border),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total a Liquidar:',
                                      style: TextStyle(
                                        fontFamily: AppFonts.headline,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '\$${total.toStringAsFixed(2)} MXN',
                                      style: const TextStyle(
                                        fontFamily: AppFonts.label,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Text(
                            'MÉTODO DE PAGO SIMULADO',
                            style: TextStyle(
                              fontFamily: AppFonts.label,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: AppColors.neutral,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: _paymentMethodOption(0, 'Tarjeta', Icons.credit_card),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _paymentMethodOption(1, 'SPEI / Bancario', Icons.account_balance),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _paymentMethodOption(2, 'Sucursal', Icons.storefront),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          if (_paymentMethod == 0) ...[
                            TextField(
                              controller: _cardNumberCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Número de Tarjeta',
                                prefixIcon: Icon(Icons.credit_card),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _cardExpCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Vencimiento (MM/AA)',
                                      prefixIcon: Icon(Icons.calendar_month),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _cardCvvCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'CVV',
                                      prefixIcon: Icon(Icons.lock_outline),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _cardNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Nombre del Titular',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                          ] else if (_paymentMethod == 1) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CLABE Interbancaria Simulada:',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 4),
                                  SelectableText(
                                    '6461 8012 3456 7890 12',
                                    style: TextStyle(fontFamily: AppFonts.label, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Banco: BBVA · Beneficiario: Subastas Vehiculares S.A.',
                                    style: TextStyle(fontSize: 11, color: AppColors.neutral),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Puedes liquidar en efectivo o cheque certificado en nuestras oficinas centrales de 9:00 a 18:00 hrs.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ),

            if (!_isSuccess)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.lock_rounded, size: 18),
                    label: Text(
                      _isProcessing
                          ? 'Procesando Transacción...'
                          : 'Confirmar y Liquidar (\$${total.toStringAsFixed(2)})',
                      style: const TextStyle(
                        fontFamily: AppFonts.headline,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessReceipt(double total) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF059669).withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 64),
        ),
        const SizedBox(height: 16),
        const Text(
          '¡Pago Completado con Éxito!',
          style: TextStyle(
            fontFamily: AppFonts.headline,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Comprobante emitido para ${widget.auction.title}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.neutral),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _priceSummaryRow('Folio de Operación', _folioNumber),
              const SizedBox(height: 8),
              _priceSummaryRow('Fecha y Hora', DateTime.now().toString().split('.')[0]),
              const SizedBox(height: 8),
              _priceSummaryRow('Método', _paymentMethod == 0 ? 'Tarjeta de Crédito' : 'Transferencia'),
              const SizedBox(height: 8),
              _priceSummaryRow('Monto Total Pagado', '\$${total.toStringAsFixed(2)} MXN'),
              const Divider(height: 20, color: AppColors.border),
              const Row(
                children: [
                  Icon(Icons.shield_rounded, size: 16, color: Color(0xFF059669)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Adjudicación formalizada. El vendedor ha sido notificado.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Listo / Volver a mi Perfil'),
          ),
        ),
      ],
    );
  }

  Widget _paymentMethodOption(int index, String label, IconData icon) {
    final selected = _paymentMethod == index;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary.withAlpha(20) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.secondary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: selected ? AppColors.secondary : AppColors.neutral),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.headline,
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? AppColors.secondary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.neutral)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: AppFonts.label)),
      ],
    );
  }
}

class _ContactSellerSheet extends StatelessWidget {
  const _ContactSellerSheet({required this.auction});

  final Auction auction;

  @override
  Widget build(BuildContext context) {
    final sellerName = (auction.sellerName?.trim().isNotEmpty == true)
        ? auction.sellerName!
        : 'Vendedor Certificado';
    final rawPhone = auction.sellerPhone?.trim() ?? '';
    final sellerPhone = rawPhone.isNotEmpty
        ? (rawPhone.startsWith('+') ? rawPhone : '+52 $rawPhone')
        : '+52 55 4160 8800';
    final sellerEmail = (auction.sellerEmail?.trim().isNotEmpty == true)
        ? auction.sellerEmail!
        : 'ventas@subastas-mexico.com';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.support_agent_rounded, size: 22, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contacto con el Vendedor',
                          style: TextStyle(
                            fontFamily: AppFonts.headline,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Coordinación de entrega y documentación',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 12,
                            color: AppColors.neutral,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjeta del Vendedor
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.store_rounded, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        sellerName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: AppFonts.headline,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified, size: 16, color: Color(0xFF059669)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Vehículo ganado: ${auction.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: AppColors.neutral),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'CANALES DIRECTOS DE COMUNICACIÓN',
                      style: TextStyle(
                        fontFamily: AppFonts.label,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: AppColors.neutral,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _contactOptionTile(
                      icon: Icons.phone_in_talk_rounded,
                      title: sellerPhone,
                      subtitle: 'Llamada directa · $sellerName',
                      buttonLabel: 'Llamar',
                      onTap: () {
                        showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            title: const Row(
                              children: [
                                Icon(Icons.phone_forwarded_rounded, color: AppColors.secondary),
                                SizedBox(width: 10),
                                Text('Llamar al Vendedor'),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Número telefónico registrado de $sellerName:',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        sellerPhone,
                                        style: const TextStyle(
                                          fontFamily: AppFonts.label,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const Icon(Icons.call, color: Color(0xFF059669), size: 20),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Vehículo a coordinar:',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  auction.title,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton.icon(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFF059669),
                                      content: Text('Marcando a $sellerName ($sellerPhone)...'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.phone, size: 16),
                                label: const Text('Iniciar Llamada'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _contactOptionTile(
                      icon: Icons.chat_rounded,
                      title: 'WhatsApp Directo',
                      subtitle: '$sellerPhone · Mensaje instantáneo',
                      buttonLabel: 'WhatsApp',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF059669),
                            content: Text(
                              'Abriendo chat de WhatsApp con $sellerName ($sellerPhone) para coordinar "${auction.title}"...',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _contactOptionTile(
                      icon: Icons.mail_outline_rounded,
                      title: sellerEmail,
                      subtitle: 'Correo registrado de $sellerName',
                      buttonLabel: 'Escribir',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Abriendo redactor de correo para $sellerEmail...')),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _contactOptionTile(
                      icon: Icons.location_on_outlined,
                      title: 'Oficina Central de Entregas',
                      subtitle: 'Av. Insurgentes Sur 1602, CDMX',
                      buttonLabel: 'Ver Mapa',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Abriendo ubicación de la sucursal de entrega...')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.neutral),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(buttonLabel, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _HistoryAuctionTile extends StatelessWidget {
  const _HistoryAuctionTile({
    required this.title,
    this.coverUrl,
    required this.status,
    required this.priceLabel,
    required this.onTap,
  });

  final String title;
  final String? coverUrl;
  final String status;
  final String priceLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isClosed = status == 'closed';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          onTap: onTap,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: coverUrl != null
                  ? Image.network(
                      coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.directions_car, size: 24, color: AppColors.neutral),
                      ),
                    )
                  : Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.directions_car, size: 24, color: AppColors.neutral),
                    ),
            ),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppFonts.headline,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                priceLabel,
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isClosed
                      ? AppColors.neutral.withAlpha(20)
                      : AppColors.secondary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isClosed ? 'Cerrada' : 'En Vivo',
                  style: TextStyle(
                    fontFamily: AppFonts.label,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isClosed ? AppColors.neutral : AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: AppColors.neutral),
            ],
          ),
        ),
      ),
    );
  }
}


class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.label,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.neutral),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isMonospace = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isMonospace;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.neutral),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  color: AppColors.neutral,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: isMonospace ? AppFonts.label : AppFonts.body,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
