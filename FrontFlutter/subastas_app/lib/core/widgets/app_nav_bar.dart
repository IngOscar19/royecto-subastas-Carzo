import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

/// Barra de navegación moderna y compartida por todas las vistas.
///
/// Estilo "floating": gradiente oscuro, esquinas inferiores redondeadas y
/// sombra suave. Muestra automáticamente el botón de retroceso cuando la
/// ruta actual puede hacer pop (rutas empujadas con go_router).
class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavBar({
    super.key,
    this.title = 'CARZO',
    this.subtitle,
    this.icon,
    this.actions = const [],
    this.showBackButton,
    this.onBackPressed,
  });

  /// Título principal de la vista (por defecto marca 'CARZO').
  final String title;

  /// Línea secundaria opcional bajo el título.
  final String? subtitle;

  /// Icono opcional mostrado en un badge junto al título.
  final IconData? icon;

  /// Acciones a la derecha.
  final List<Widget> actions;

  /// Fuerza mostrar/ocultar el botón de retroceso.
  final bool? showBackButton;

  /// Callback personalizado para la acción del botón de retroceso.
  final VoidCallback? onBackPressed;

  static const double _height = 62;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final canPop = Navigator.of(context).canPop();
    final showBack = showBackButton ?? canPop;
    final hasDrawer = Scaffold.maybeOf(context)?.hasDrawer ?? false;
    final isBrandTitle = title.toUpperCase() == 'CARZO' || title == 'Catálogo de Subastas' || title == 'Panel de Vendedor';

    return Container(
      height: _height + topPadding,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF27272A),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                // Botón Izquierdo: Back o Menú Hamburguesa
                if (showBack)
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    tooltip: 'Volver',
                    onPressed: onBackPressed ??
                        () {
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                  )
                else if (hasDrawer)
                  IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    tooltip: 'Menú y Categorías',
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  )
                else
                  const SizedBox(width: 8),

                const SizedBox(width: 6),

                // Centro / Título
                Expanded(
                  child: isBrandTitle
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontFamily: AppFonts.headline,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'CAR',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: 'ZO',
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 3, top: 4),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: AppFonts.headline,
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 1),
                              Text(
                                subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: AppFonts.body,
                                  fontSize: 11,
                                  color: AppColors.neutral,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),

                // Acciones a la Derecha
                if (actions.isNotEmpty) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions,
                  ),
                ] else ...[
                  const SizedBox(width: 44), // Para equilibrar el centro cuando hay botón a la izq
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón minimalista de acción para la barra de navegación.
class NavBarIconButton extends StatelessWidget {
  const NavBarIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 20,
    this.color = Colors.white,
    this.tint,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final Color color;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: size, color: color),
      style: IconButton.styleFrom(
        backgroundColor: tint != null ? tint!.withAlpha(25) : Colors.white.withAlpha(15),
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(36, 36),
      ),
    );
  }
}
