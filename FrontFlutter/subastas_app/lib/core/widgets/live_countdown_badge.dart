import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Badge de cuenta regresiva auto-actualizado cada segundo.
///
/// El countdown se calcula localmente contra [endTime] (timestamp absoluto
/// del servidor) y solo anima la UI; la resincronización del server llega
/// por `time_extended` / `auction_snapshot` y simplemente actualiza
/// [endTime], tal como dicta el contrato.
class LiveCountdownBadge extends StatefulWidget {
  const LiveCountdownBadge({
    super.key,
    required this.endTime,
    this.closed = false,
    this.style = CountdownStyle.onImage,
  });

  final DateTime endTime;
  final bool closed;
  final CountdownStyle style;

  @override
  State<LiveCountdownBadge> createState() => _LiveCountdownBadgeState();
}

class _LiveCountdownBadgeState extends State<LiveCountdownBadge> {
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _update();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(_update);
    });
  }

  @override
  void didUpdateWidget(LiveCountdownBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endTime != widget.endTime) setState(_update);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _update() {
    final diff = widget.endTime.difference(DateTime.now());
    _remaining = diff.isNegative ? Duration.zero : diff;
  }

  bool get _urgent =>
      !widget.closed && !_remaining.isNegative && _remaining.inMinutes < 15;

  @override
  Widget build(BuildContext context) {
    if (widget.closed || _remaining == Duration.zero) {
      return _pill(
        color: AppColors.neutral,
        icon: Icons.flag_rounded,
        label: 'Finalizada',
      );
    }

    final color = _urgent ? AppColors.tertiary : AppColors.secondary;
    return _pill(
      color: color,
      icon: _urgent ? Icons.local_fire_department_rounded : Icons.timer_outlined,
      label: formatCountdown(_remaining),
      pulsing: _urgent,
    );
  }

  Widget _pill({
    required Color color,
    required IconData icon,
    required String label,
    bool pulsing = false,
  }) {
    final onImage = widget.style == CountdownStyle.onImage;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:
            onImage ? Colors.black.withAlpha(140) : color.withAlpha(24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: onImage ? Colors.white.withAlpha(50) : color.withAlpha(70),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: onImage ? Colors.white : color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.label,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
              color: onImage ? Colors.white : color,
            ),
          ),
          if (pulsing) ...[
            const SizedBox(width: 5),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withAlpha(120), blurRadius: 6),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum CountdownStyle { onImage, tinted }
