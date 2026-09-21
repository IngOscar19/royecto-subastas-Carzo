import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auctions/presentation/catalog_provider.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../theme/app_theme.dart';
import 'logo_badge.dart';

/// Sidebar / Navigation Drawer en rojo, negro y blanco con selector de
/// categorías por tipo de vehículo y accesos rápidos de cuenta.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionUser = ref.watch(authControllerProvider).valueOrNull;
    final selectedCategory = ref.watch(vehicleCategoryProvider);
    final isSeller = sessionUser?.role.name == 'seller';

    return Drawer(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Oscuro de Marca
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.paddingOf(context).top + 20,
              20,
              22,
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const LogoBadge(size: 48),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isSeller ? 'VENDEDOR' : 'COMPRADOR',
                        style: const TextStyle(
                          fontFamily: AppFonts.label,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  sessionUser?.name ?? 'Usuario Subastas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppFonts.headline,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sessionUser?.email ?? 'subastas@auto.com',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12,
                    color: AppColors.border.withAlpha(220),
                  ),
                ),
              ],
            ),
          ),

          // Divisor Rojo de Acento
          Container(
            height: 3,
            width: double.infinity,
            color: AppColors.secondary,
          ),

          // Lista de Categorías y Navegación
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: [
                const _DrawerSectionHeader('CATEGORÍAS DE VEHÍCULOS'),
                const SizedBox(height: 6),
                _CategoryTile(
                  title: VehicleCategory.all.label,
                  icon: VehicleCategory.all.icon,
                  category: VehicleCategory.all,
                  selected: selectedCategory == VehicleCategory.all,
                  onTap: () => _onSelectCategory(
                    context,
                    ref,
                    VehicleCategory.all,
                    isSeller,
                  ),
                ),
                _CategoryTile(
                  title: VehicleCategory.sports.label,
                  icon: VehicleCategory.sports.icon,
                  category: VehicleCategory.sports,
                  selected: selectedCategory == VehicleCategory.sports,
                  onTap: () => _onSelectCategory(
                    context,
                    ref,
                    VehicleCategory.sports,
                    isSeller,
                  ),
                ),
                _CategoryTile(
                  title: VehicleCategory.sedan.label,
                  icon: VehicleCategory.sedan.icon,
                  category: VehicleCategory.sedan,
                  selected: selectedCategory == VehicleCategory.sedan,
                  onTap: () => _onSelectCategory(
                    context,
                    ref,
                    VehicleCategory.sedan,
                    isSeller,
                  ),
                ),
                _CategoryTile(
                  title: VehicleCategory.suvElectric.label,
                  icon: VehicleCategory.suvElectric.icon,
                  category: VehicleCategory.suvElectric,
                  selected: selectedCategory == VehicleCategory.suvElectric,
                  onTap: () => _onSelectCategory(
                    context,
                    ref,
                    VehicleCategory.suvElectric,
                    isSeller,
                  ),
                ),
                _CategoryTile(
                  title: VehicleCategory.pickup.label,
                  icon: VehicleCategory.pickup.icon,
                  category: VehicleCategory.pickup,
                  selected: selectedCategory == VehicleCategory.pickup,
                  onTap: () => _onSelectCategory(
                    context,
                    ref,
                    VehicleCategory.pickup,
                    isSeller,
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(color: AppColors.border),
                ),

                const _DrawerSectionHeader('MI CUENTA'),
                const SizedBox(height: 6),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Mi Perfil & Historial',
                    style: TextStyle(
                      fontFamily: AppFonts.headline,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.neutral,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(isSeller ? '/seller/profile' : '/bidder/profile');
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.secondary,
                  ),
                  title: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      fontFamily: AppFonts.headline,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(authControllerProvider.notifier).logout();
                  },
                ),
              ],
            ),
          ),

          // Footer de Versión
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: const Text(
              'Carzo v1.0.0 · Edición Rojo & Negro',
              style: TextStyle(
                fontFamily: AppFonts.label,
                fontSize: 10,
                color: AppColors.neutral,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSelectCategory(
    BuildContext context,
    WidgetRef ref,
    VehicleCategory category,
    bool isSeller,
  ) {
    ref.read(vehicleCategoryProvider.notifier).state = category;
    Navigator.pop(context);

    // Si el usuario comprador no está en la pantalla principal del catálogo, navegar a ella
    if (!isSeller) {
      final location = GoRouterState.of(context).matchedLocation;
      if (location != '/bidder') {
        context.go('/bidder');
      }
    }
  }
}

class _DrawerSectionHeader extends StatelessWidget {
  const _DrawerSectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: AppFonts.label,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: AppColors.neutral,
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.title,
    required this.icon,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VehicleCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected
            ? AppColors.secondary.withAlpha(20)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? AppColors.secondary : Colors.transparent,
            width: 1,
          ),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(
            icon,
            color: selected ? AppColors.secondary : AppColors.primary,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: AppFonts.headline,
              fontSize: 13.5,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected ? AppColors.secondary : AppColors.textPrimary,
            ),
          ),
          trailing: selected
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}

