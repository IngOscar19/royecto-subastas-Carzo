import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Badge de marca reutilizado en splash, login y registro.
///
/// Círculo con gradiente oscuro, anillo esmeralda e icono de martillo.
class LogoBadge extends StatelessWidget {
  const LogoBadge({super.key, this.size = 72, this.iconSize});

  /// Diámetro total del badge.
  final double size;

  /// Tamaño del icono interno. Por defecto la mitad del badge.
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.secondary, width: 2),
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryInverted],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(
          Icons.gavel_rounded,
          size: iconSize ?? size * 0.45,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
