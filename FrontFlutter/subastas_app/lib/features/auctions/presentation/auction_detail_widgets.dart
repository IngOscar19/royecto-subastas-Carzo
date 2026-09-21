import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/socket_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../bids/domain/bid_model.dart';
import '../../bids/presentation/bids_controller.dart';
import '../domain/auction.dart';
import '../domain/auction_closed.dart';

/// Indicador de conexión del WebSocket en forma de píldora para la navbar.
class SocketStatusPill extends ConsumerWidget {
  const SocketStatusPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(socketStatusProvider);
    final status = statusAsync.valueOrNull ?? SocketStatus.disconnected;

    final (color, label) = switch (status) {
      SocketStatus.connected => (AppColors.secondary, 'En vivo'),
      SocketStatus.reconnecting => (AppColors.warning, 'Reconectando'),
      SocketStatus.disconnected => (AppColors.tertiary, 'Sin conexión'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(36),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(110)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == SocketStatus.reconnecting)
            SizedBox(
              width: 11,
              height: 11,
              child: CircularProgressIndicator(strokeWidth: 1.6, color: color),
            )
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withAlpha(120), blurRadius: 6),
                ],
              ),
            ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.label,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner de resultado cuando la subasta cierra (ganador o sin pujas).
class ClosedResultBanner extends StatelessWidget {
  const ClosedResultBanner({super.key, required this.closed});

  final AuctionClosed closed;

  @override
  Widget build(BuildContext context) {
    final hasWinner = closed.winnerId != null && closed.winnerName != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: hasWinner ? AppColors.successGradient : null,
        color: hasWinner ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: hasWinner
            ? Border.all(color: AppColors.secondaryDeep.withAlpha(80))
            : Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: hasWinner
                ? AppColors.secondary.withAlpha(60)
                : const Color(0x0C0F172A),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: hasWinner
                  ? Colors.white.withAlpha(40)
                  : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasWinner ? Icons.emoji_events_rounded : Icons.flag_rounded,
              size: 36,
              color: hasWinner ? Colors.white : AppColors.neutral,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Subasta Finalizada',
            style: TextStyle(
              fontFamily: AppFonts.headline,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: hasWinner ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          if (hasWinner) ...[
            Text(
              closed.winnerName!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.headline,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD1FAE5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Precio final ${formatCurrency(closed.finalPrice)}',
              style: const TextStyle(
                fontFamily: AppFonts.label,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ] else
            Text(
              'No hubo pujas en esta subasta',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13,
                color: AppColors.neutral,
              ),
            ),
        ],
      ),
    );
  }
}

/// Pantalla de conexión inicial al socket con animación pulsante y halo orbital.
class ConnectingIndicator extends StatefulWidget {
  const ConnectingIndicator({super.key});

  @override
  State<ConnectingIndicator> createState() => _ConnectingIndicatorState();
}

class _ConnectingIndicatorState extends State<ConnectingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.20, end: 0.65).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Halo exterior pulsante
                  Container(
                    width: 96 * _scaleAnimation.value,
                    height: 96 * _scaleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary.withAlpha((_pulseAnimation.value * 90).toInt()),
                    ),
                  ),
                  // Anillo intermedio con sombra
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(
                        color: AppColors.secondary.withAlpha(115),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withAlpha(50),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.gavel_rounded,
                        size: 32,
                        color: AppColors.secondaryDeep,
                      ),
                    ),
                  ),
                  // Spinner orbital
                  const SizedBox(
                    width: 86,
                    height: 86,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Conectando con la sala en vivo…',
            style: TextStyle(
              fontFamily: AppFonts.headline,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sincronizando pujas y tiempo real',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12.5,
              color: AppColors.neutral,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ficha técnica del vehículo con los datos estructurados estilo Facebook Marketplace y condiciones de subasta.
class VehicleSpecsCard extends StatelessWidget {
  const VehicleSpecsCard({super.key, required this.auction});

  final Auction auction;

  @override
  Widget build(BuildContext context) {
    final desc = auction.description ?? '';

    // Parsear o deducir especificaciones
    final specs = _extractSpecs(auction.title, desc);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C0F172A),
            blurRadius: 14,
            offset: Offset(0, 4),
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
                  color: AppColors.secondary.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car_rounded, size: 18, color: AppColors.secondaryDeep),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Características del Vehículo',
                      style: TextStyle(
                        fontFamily: AppFonts.headline,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Ficha técnica y estado de publicación',
                      style: TextStyle(
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
          const SizedBox(height: 16),

          // Cuadrícula de características clave
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (specs['year'] != null)
                _specBadge(Icons.calendar_today_rounded, 'Año', specs['year']!),
              if (specs['mileage'] != null)
                _specBadge(Icons.speed_rounded, 'Kilometraje', specs['mileage']!),
              if (specs['transmission'] != null)
                _specBadge(Icons.settings_suggest_rounded, 'Transmisión', specs['transmission']!),
              if (specs['fuel'] != null)
                _specBadge(Icons.local_gas_station_rounded, 'Combustible', specs['fuel']!),
              if (specs['body'] != null)
                _specBadge(Icons.directions_car_filled_rounded, 'Carrocería', specs['body']!),
              if (specs['color'] != null)
                _specBadge(Icons.palette_rounded, 'Color', specs['color']!),
              if (specs['condition'] != null)
                _specBadge(Icons.verified_rounded, 'Condición', specs['condition']!),
            ],
          ),

          if (_getCleanNotes(desc).isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Descripción y Observaciones:',
              style: TextStyle(
                fontFamily: AppFonts.headline,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withAlpha(80)),
              ),
              child: Text(
                _getCleanNotes(desc),
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),

          const Text(
            'Condiciones de la Subasta',
            style: TextStyle(
              fontFamily: AppFonts.headline,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          _specRow(
            Icons.play_circle_outline_rounded,
            'Inicio',
            formatDateTimeEs(auction.startTime),
          ),
          _divider(),
          _specRow(
            Icons.timer_outlined,
            'Cierre programado',
            formatDateTimeEs(auction.endTime),
          ),
          _divider(),
          _specRow(
            Icons.trending_up_rounded,
            'Incremento mínimo por puja',
            formatCurrency(auction.minIncrement, decimals: 0),
          ),
          _divider(),
          _specRow(
            Icons.flag_outlined,
            'Precio de salida',
            formatCurrency(auction.startingPrice),
          ),
          if (auction.buyOutPrice != null) ...[
            _divider(),
            _specRow(
              Icons.bolt_rounded,
              'Compra directa / Cómpralo Ya',
              formatCurrency(auction.buyOutPrice!),
              highlight: true,
            ),
          ],
        ],
      ),
    );
  }

  Map<String, String> _extractSpecs(String title, String description) {
    final map = <String, String>{};

    // Intentar extraer año del título si empieza o tiene 4 dígitos (2000-2029)
    final yearRegex = RegExp(r'\b(19\d\d|20\d\d)\b');
    final matchYear = yearRegex.firstMatch(title) ?? yearRegex.firstMatch(description);
    if (matchYear != null) {
      map['year'] = matchYear.group(1)!;
    }

    // Extraer campos estructurados de la descripción
    for (final line in description.split('\n')) {
      final parts = line.split('|');
      for (final p in parts) {
        final trimmed = p.replaceAll(RegExp(r'^[^\w]+'), '').trim();
        if (trimmed.toLowerCase().contains('año:')) {
          map['year'] = trimmed.split(':').last.trim();
        } else if (trimmed.toLowerCase().contains('transmisión:') || trimmed.toLowerCase().contains('transmision:')) {
          map['transmission'] = trimmed.split(':').last.trim();
        } else if (trimmed.toLowerCase().contains('combustible:')) {
          map['fuel'] = trimmed.split(':').last.trim();
        } else if (trimmed.toLowerCase().contains('kilometraje:')) {
          map['mileage'] = trimmed.split(':').last.trim();
        } else if (trimmed.toLowerCase().contains('carrocería:') || trimmed.toLowerCase().contains('carroceria:')) {
          map['body'] = trimmed.split(':').last.trim();
        } else if (trimmed.toLowerCase().contains('color:')) {
          map['color'] = trimmed.split(':').last.trim();
        } else if (trimmed.toLowerCase().contains('estado:') || trimmed.toLowerCase().contains('condición:')) {
          map['condition'] = trimmed.split(':').last.trim();
        }
      }
    }

    // Fallbacks si no se encontraron en descripción
    if (!map.containsKey('transmission')) map['transmission'] = 'Automática';
    if (!map.containsKey('fuel')) map['fuel'] = 'Gasolina';
    if (!map.containsKey('condition')) map['condition'] = 'Excelente';

    return map;
  }

  String _getCleanNotes(String desc) {
    if (desc.isEmpty) return '';
    if (desc.contains('📝 Observaciones:')) {
      return desc.split('📝 Observaciones:').last.trim();
    }
    // Si no tiene emojis estructurados, toda la descripción son notas
    if (!desc.contains('🚗') && !desc.contains('⚡') && !desc.contains('🛣️')) {
      return desc.trim();
    }
    return '';
  }

  Widget _specBadge(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.secondaryDeep),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppFonts.label,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: AppFonts.headline,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(height: 1),
      );

  Widget _specRow(IconData icon, String label, String value, {bool highlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: highlight ? AppColors.secondary.withAlpha(30) : AppColors.primary.withAlpha(14),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 15, color: highlight ? AppColors.secondaryDeep : AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.label,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: highlight ? AppColors.secondaryDeep : AppColors.neutral,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13.5,
                  fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                  color: highlight ? AppColors.secondaryDeep : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Historial de pujas en vivo: feed con avatares, marca de "TÚ",
/// badge de líder y paginación.
class BidHistoryCard extends StatelessWidget {
  const BidHistoryCard({
    super.key,
    required this.state,
    required this.sessionUserId,
    required this.onLoadMore,
  });

  final BidsState state;
  final String? sessionUserId;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionHeader('Historial de ofertas'),
              if (state.total > 0) CountBadge(state.total),
            ],
          ),
          const SizedBox(height: 16),
          if (state.isLoading && state.bids.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.bids.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(Icons.sports_score_outlined,
                      size: 34, color: AppColors.textLight),
                  const SizedBox(height: 10),
                  Text(
                    'Todavía no hay pujas registradas.',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 13,
                      color: AppColors.neutral.withAlpha(255),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¡Sé el primero en ofertar!',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 12,
                      color: AppColors.secondaryDeep.withAlpha(255),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            for (var i = 0; i < state.bids.length; i++)
              _BidTile(
                bid: state.bids[i],
                isLeader: i == 0,
                isMine:
                    sessionUserId != null && state.bids[i].userId == sessionUserId,
              ),
            if (state.hasMore) ...[
              const SizedBox(height: 12),
              Center(
                child: OutlinedButton.icon(
                  onPressed: state.isLoadingMore ? null : onLoadMore,
                  icon: state.isLoadingMore
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.expand_more_rounded),
                  label: Text(
                    state.isLoadingMore ? 'Cargando…' : 'Cargar más ofertas',
                    style: const TextStyle(
                      fontFamily: AppFonts.headline,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _BidTile extends StatelessWidget {
  const _BidTile({
    required this.bid,
    required this.isLeader,
    required this.isMine,
  });

  final BidModel bid;
  final bool isLeader;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final avatarColor = isMine
        ? AppColors.secondary
        : (isLeader ? AppColors.primary : AppColors.primaryInverted);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: isLeader
            ? AppColors.secondary.withAlpha(16)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isLeader
              ? AppColors.secondary.withAlpha(90)
              : AppColors.border.withAlpha(120),
          width: isLeader ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: avatarColor,
            child: Text(
              bid.userName.isNotEmpty ? bid.userName[0].toUpperCase() : '?',
              style: const TextStyle(
                fontFamily: AppFonts.headline,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        bid.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppFonts.headline,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 6),
                      _miniChip('TÚ', AppColors.secondary),
                    ],
                    if (isLeader && !isMine) ...[
                      const SizedBox(width: 6),
                      _miniChip('LÍDER', AppColors.primary),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  timeAgoEs(bid.createdAt),
                  style: const TextStyle(
                    fontFamily: AppFonts.label,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(bid.amount),
            style: TextStyle(
              fontFamily: AppFonts.label,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: isLeader ? AppColors.secondaryDeep : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: AppFonts.label,
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
      ),
    );
  }
}
