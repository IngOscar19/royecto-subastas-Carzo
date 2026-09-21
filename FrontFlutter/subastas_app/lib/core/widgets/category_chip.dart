import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../../features/auctions/domain/auction.dart';
import '../../features/auctions/presentation/catalog_provider.dart';

/// Estilo visual del chip de categoría
enum CategoryChipStyle { translucent, tinted, solid }

/// Chip/Etiqueta visual que muestra la categoría de un vehículo (Deportivo, Sedán, SUV, etc.)
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    this.style = CategoryChipStyle.tinted,
    this.compact = false,
  });

  final VehicleCategory category;
  final CategoryChipStyle style;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (category == VehicleCategory.all) return const SizedBox.shrink();

    final label = compact ? category.shortLabel : category.shortLabel;
    final icon = category.icon;

    switch (style) {
      case CategoryChipStyle.translucent:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xCC0B111E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withAlpha(50),
              width: 0.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x28000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: AppColors.secondary),
              const SizedBox(width: 4.5),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppFonts.label,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );

      case CategoryChipStyle.tinted:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(16),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withAlpha(45),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: AppColors.primary),
              const SizedBox(width: 4.5),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppFonts.label,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );

      case CategoryChipStyle.solid:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                category.label,
                style: const TextStyle(
                  fontFamily: AppFonts.label,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
    }
  }
}
