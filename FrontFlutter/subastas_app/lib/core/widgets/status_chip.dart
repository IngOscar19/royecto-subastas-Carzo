import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Chip de estado de una subasta, unificado en toda la app.
///
/// Variantes visuales:
/// - [StatusChipStyle.translucent]: fondo blanco translúcido para ir sobre
///   imágenes (tarjetas del catálogo, hero del detalle).
/// - [StatusChipStyle.tinted]: fondo del color al 10% para ir sobre
///   superficies claras.
enum StatusChipStyle { translucent, tinted }

class StatusChip extends StatelessWidget {
  const StatusChip(
    this.status, {
    super.key,
    this.style = StatusChipStyle.tinted,
  });

  /// Estado crudo del backend: `active`, `scheduled`, `closed`.
  final String status;

  final StatusChipStyle style;

  (Color, String) get _data => switch (status) {
        'active' => (AppColors.secondary, 'EN VIVO'),
        'closed' => (AppColors.neutral, 'FINALIZADA'),
        'scheduled' => (AppColors.warning, 'PROGRAMADA'),
        _ => (AppColors.neutral, status.toUpperCase()),
      };

  @override
  Widget build(BuildContext context) {
    final (color, label) = _data;
    final isTranslucent = style == StatusChipStyle.translucent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isTranslucent ? Colors.white.withAlpha(235) : color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTranslucent ? color.withAlpha(120) : color.withAlpha(70),
        ),
        boxShadow: isTranslucent
            ? const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.label,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
              color: isTranslucent ? color : _onTint(color),
            ),
          ),
        ],
      ),
    );
  }

  Color _onTint(Color color) =>
      color == AppColors.neutral ? AppColors.textSecondary : color;
}
