import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Galería de imágenes de un vehículo con:
/// 1. Fondo con desenfoque dinámico + `BoxFit.contain` para mostrar el vehículo
///    completo al 100% sin recortar ninguna parte.
/// 2. Visor interactivo a pantalla completa con soporte de zoom (Pinch-to-Zoom)
///    al tocar la imagen o el botón de expandir.
class ImageGallery extends StatefulWidget {
  const ImageGallery({
    super.key,
    required this.imageUrls,
    required this.height,
    this.borderRadius,
    this.overlayChips = const [],
    this.title,
  });

  final List<String> imageUrls;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final String? title;

  /// Widgets extra sobre la galería (chips de estado/countdown posicionados
  /// por el llamador dentro de su propio Stack).
  final List<Widget> overlayChips;

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  PageController? _controller;
  int _current = 0;

  @override
  void didUpdateWidget(ImageGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls.length != widget.imageUrls.length) {
      _current = 0;
      _controller?.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _openFullScreen(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => _FullScreenGalleryViewer(
          imageUrls: widget.imageUrls,
          initialIndex: initialIndex,
          title: widget.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(0);
    final hasMultiple = urls.length > 1;

    Widget image(Widget child) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: child,
        ),
      );
    }

    if (urls.isEmpty) {
      return image(const _VehicleFallback());
    }

    if (!hasMultiple) {
      return image(
        GestureDetector(
          onTap: () => _openFullScreen(context, 0),
          child: _NetworkImage(url: urls.first),
        ),
      );
    }

    _controller ??= PageController();

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          SizedBox(
            height: widget.height,
            width: double.infinity,
            child: PageView.builder(
              controller: _controller,
              itemCount: urls.length,
              onPageChanged: (index) => setState(() => _current = index),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => _openFullScreen(context, index),
                child: _NetworkImage(url: urls[index]),
              ),
            ),
          ),
          // Scrim inferior para legibilidad de los puntos indicadores.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(0),
                    Colors.black.withAlpha(120),
                  ],
                ),
              ),
            ),
          ),
          // Contador "1/3" en la esquina superior derecha.
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(190),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlpha(50)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_camera_outlined,
                      size: 12, color: Colors.white70),
                  const SizedBox(width: 5),
                  Text(
                    '${_current + 1}/${urls.length}',
                    style: const TextStyle(
                      fontFamily: AppFonts.label,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Puntos indicadores o cápsula compacta si hay muchas fotos.
          if (urls.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Center(
                child: urls.length <= 8
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < urls.length; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _current ? 18 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: i == _current
                                    ? AppColors.secondary
                                    : Colors.white.withAlpha(180),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                        ],
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(160),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withAlpha(60), width: 0.8),
                        ),
                        child: Text(
                          '${_current + 1} / ${urls.length}',
                          style: const TextStyle(
                            fontFamily: AppFonts.label,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
          ...widget.overlayChips,
        ],
      ),
    );
  }
}

/// Imagen con fondo desenfocado dinámico y primer plano en `BoxFit.contain`
/// para evitar cualquier corte involuntario de partes del auto.
class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Capa de fondo: Imagen escalada con desenfoque suave
        Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: AppColors.surfaceVariant),
        ),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              color: Colors.black.withAlpha(70),
            ),
          ),
        ),
        // 2. Capa principal: Imagen completa sin recortes
        Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              child: const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) =>
              const _VehicleFallback(),
        ),
      ],
    );
  }
}

/// Visor interactivo a pantalla completa con soporte de zoom (Pinch-to-Zoom).
class _FullScreenGalleryViewer extends StatefulWidget {
  const _FullScreenGalleryViewer({
    required this.imageUrls,
    required this.initialIndex,
    this.title,
  });

  final List<String> imageUrls;
  final int initialIndex;
  final String? title;

  @override
  State<_FullScreenGalleryViewer> createState() =>
      _FullScreenGalleryViewerState();
}

class _FullScreenGalleryViewerState extends State<_FullScreenGalleryViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior con botón cerrar, título y contador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 26),
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title ?? 'Galería del Vehículo',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppFonts.headline,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Foto ${_currentIndex + 1} de ${urls.length} · Pellizca para hacer zoom',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 12,
                            color: Colors.white.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${urls.length}',
                      style: const TextStyle(
                        fontFamily: AppFonts.label,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Área central con InteractiveViewer (Pinch-to-zoom)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: urls.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.5,
                    clipBehavior: Clip.none,
                    child: Center(
                      child: Image.network(
                        urls[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.secondary,
                              strokeWidth: 2.5,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const _VehicleFallback(),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Tira de miniaturas inferior para navegación rápida si hay varias fotos
            if (urls.length > 1)
              Container(
                height: 70,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: urls.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final selected = _currentIndex == index;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected
                                ? AppColors.secondary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            urls[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VehicleFallback extends StatelessWidget {
  const _VehicleFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car, size: 64, color: AppColors.primary),
          const SizedBox(height: 8),
          const Text(
            'Vehículo',
            style: TextStyle(
              fontFamily: AppFonts.body,
              color: AppColors.neutral,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
