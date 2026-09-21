import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import 'catalog_provider.dart';
import '../data/auctions_repository.dart';

/// Modal de publicación de vehículo inspirado en el flujo estructurado de Facebook Marketplace.
class PublishAuctionSheet extends ConsumerStatefulWidget {
  const PublishAuctionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PublishAuctionSheet(),
    );
  }

  @override
  ConsumerState<PublishAuctionSheet> createState() =>
      _PublishAuctionSheetState();
}

class _PublishAuctionSheetState extends ConsumerState<PublishAuctionSheet> {
  final _formKey = GlobalKey<FormState>();

  // 1. Identificación básica
  int _selectedYear = 2023;
  String _selectedMake = 'Ford';
  final _customMakeController = TextEditingController();
  final _modelController = TextEditingController(text: 'Mustang GT');
  String _selectedBodyType = 'Coupé';

  // 2. Especificaciones y Estado
  final _mileageController = TextEditingController(text: '15000');
  String _selectedTransmission = 'Automática';
  String _selectedFuelType = 'Gasolina';
  String _selectedColor = 'Rojo';
  String _selectedCondition = 'Excelente';

  // 3. Precios y Condiciones
  final _startingPriceController = TextEditingController(text: '150000');
  final _minIncrementController = TextEditingController(text: '5000');
  final _buyOutPriceController = TextEditingController();
  int _selectedDurationHours = 24;

  // 4. Descripción adicional & Imágenes (hasta 20 fotos locales)
  final _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedFiles = [];
  final List<String> _presetUrls = [];
  bool _photoError = false;
  bool _isPickingImages = false;

  bool _isSubmitting = false;
  String? _uploadStatusText;

  int get _totalPhotos => _selectedFiles.length + _presetUrls.length;

  static const _makes = [
    'Ford', 'Chevrolet', 'Toyota', 'Nissan', 'BMW', 'Mercedes-Benz',
    'Honda', 'Jeep', 'GMC', 'Audi', 'Volkswagen', 'Porsche', 'Mazda',
    'Hyundai', 'Kia', 'Tesla', 'Dodge', 'Ram', 'Otro'
  ];

  static const _bodyTypes = [
    'Sedán', 'SUV', 'Pickup / Camioneta', 'Coupé', 'Hatchback', 'Convertible'
  ];

  static const _transmissions = ['Automática', 'Manual', 'Dual-Clutch'];
  static const _fuelTypes = ['Gasolina', 'Diésel', 'Híbrido', 'Eléctrico'];
  static const _colors = ['Negro', 'Blanco', 'Gris / Plata', 'Rojo', 'Azul', 'Amarillo', 'Verde'];
  static const _conditions = ['Excelente', 'Muy Bueno', 'Bueno'];

  static const _durations = <(int, String, IconData)>[
    (1, '1 hora', Icons.bolt_rounded),
    (12, '12 horas', Icons.schedule),
    (24, '24 horas', Icons.event_available_outlined),
    (72, '3 días', Icons.date_range_outlined),
    (168, '7 días', Icons.calendar_month_outlined),
  ];

  @override
  void dispose() {
    _customMakeController.dispose();
    _modelController.dispose();
    _mileageController.dispose();
    _startingPriceController.dispose();
    _minIncrementController.dispose();
    _buyOutPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final remaining = 20 - _totalPhotos;
    if (remaining <= 0) {
      _showMaxPhotosToast();
      return;
    }
    setState(() => _isPickingImages = true);
    try {
      final picked = await _picker.pickMultiImage(
        limit: remaining,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (picked.isNotEmpty) {
        setState(() {
          final toAdd = picked.take(remaining).toList();
          _selectedFiles.addAll(toAdd);
          _photoError = false;
        });
      }
    } catch (e) {
      try {
        final single = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1080,
        );
        if (single != null) {
          setState(() {
            _selectedFiles.add(single);
            _photoError = false;
          });
        }
      } catch (e2) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.tertiary,
            content: Text('Error al acceder a la galería: $e2'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImages = false);
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _removePresetUrl(int index) {
    setState(() {
      _presetUrls.removeAt(index);
    });
  }

  void _showMaxPhotosToast() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Límite alcanzado: máximo 20 fotos por vehículo'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  void _applyPreset({
    required int year,
    required String make,
    required String model,
    required String bodyType,
    required String mileage,
    required String transmission,
    required String fuelType,
    required String color,
    required String startingPrice,
    required String notes,
    required List<String> images,
  }) {
    setState(() {
      _selectedYear = year;
      if (_makes.contains(make)) {
        _selectedMake = make;
        _customMakeController.clear();
      } else {
        _selectedMake = 'Otro';
        _customMakeController.text = make;
      }
      _modelController.text = model;
      _selectedBodyType = bodyType;
      _mileageController.text = mileage;
      _selectedTransmission = transmission;
      _selectedFuelType = fuelType;
      _selectedColor = color;
      _startingPriceController.text = startingPrice;
      _notesController.text = notes;

      _presetUrls
        ..clear()
        ..addAll(images.take(20));
      _selectedFiles.clear();
    });
  }

  void _showNoPhotosDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.tertiary.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_photo_alternate_rounded,
            color: AppColors.tertiary,
            size: 36,
          ),
        ),
        title: const Text(
          'Fotos Obligatorias',
          style: TextStyle(
            fontFamily: AppFonts.headline,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Para publicar el vehículo en subasta es obligatorio agregar al menos 1 fotografía desde la galería.',
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _pickFromGallery();
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: const Text(
              'Seleccionar fotos de Galería',
              style: TextStyle(
                fontFamily: AppFonts.headline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String bodyType,
    required String color,
    required String mileage,
    required String transmission,
    required String fuelType,
    required String condition,
    required double startingPrice,
    required double minIncrement,
    required double? buyOutPrice,
    required int durationHours,
    required String notes,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: AppColors.surface,
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.gavel_rounded,
                color: AppColors.secondaryDeep,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Estás seguro de crear esta subasta?',
                    style: TextStyle(
                      fontFamily: AppFonts.headline,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Revisa el resumen antes de publicarla en vivo',
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
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // 1. Tira de fotos agregadas
                if (_totalPhotos > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'FOTOS AGREGADAS',
                        style: TextStyle(
                          fontFamily: AppFonts.label,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: AppColors.neutral,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$_totalPhotos foto${_totalPhotos > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontFamily: AppFonts.label,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _totalPhotos,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final isPreset = i < _presetUrls.length;
                        final fileIndex = i - _presetUrls.length;
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 72,
                                height: 72,
                                child: isPreset
                                    ? Image.network(
                                        _presetUrls[i],
                                        fit: BoxFit.cover,
                                        cacheWidth: 200,
                                        cacheHeight: 200,
                                      )
                                    : (kIsWeb
                                        ? Image.network(_selectedFiles[fileIndex].path, fit: BoxFit.cover)
                                        : Image.file(
                                            File(_selectedFiles[fileIndex].path),
                                            fit: BoxFit.cover,
                                            cacheWidth: 200,
                                            cacheHeight: 200,
                                          )),
                              ),
                            ),
                            if (i == 0)
                              Positioned(
                                bottom: 2,
                                left: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryDeep,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'PORTADA',
                                    style: TextStyle(
                                      fontFamily: AppFonts.label,
                                      fontSize: 7,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 2. Tarjeta resumen del vehículo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: AppFonts.headline,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _miniSpecChip(Icons.directions_car_outlined, bodyType),
                          _miniSpecChip(Icons.palette_outlined, color),
                          _miniSpecChip(Icons.speed_rounded, '$mileage km'),
                          _miniSpecChip(Icons.settings_outlined, transmission),
                          _miniSpecChip(Icons.local_gas_station_outlined, fuelType),
                          _miniSpecChip(Icons.verified_outlined, condition),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Condiciones de la subasta
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _summaryRow(
                        'Precio Inicial:',
                        formatCurrency(startingPrice),
                        isBold: true,
                        valueColor: AppColors.secondaryDeep,
                      ),
                      const SizedBox(height: 6),
                      _summaryRow(
                        'Incremento Mínimo:',
                        '+${formatCurrency(minIncrement)}',
                      ),
                      const SizedBox(height: 6),
                      _summaryRow(
                        'Cómpralo Ya (Directo):',
                        buyOutPrice != null ? formatCurrency(buyOutPrice) : 'No habilitado',
                        valueColor: buyOutPrice != null ? AppColors.primary : AppColors.neutral,
                      ),
                      const SizedBox(height: 6),
                      _summaryRow(
                        'Duración Subasta:',
                        '$durationHours hora${durationHours > 1 ? 's' : ''}',
                      ),
                    ],
                  ),
                ),

                // 4. Observaciones
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withAlpha(120),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OBSERVACIONES:',
                          style: TextStyle(
                            fontFamily: AppFonts.label,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: AppColors.neutral,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          notes,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text(
                    'Editar / Cancelar',
                    style: TextStyle(
                      fontFamily: AppFonts.headline,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondaryDeep,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                  label: const Text(
                    'Sí, Publicar',
                    style: TextStyle(
                      fontFamily: AppFonts.headline,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniSpecChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border.withAlpha(120)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.neutral),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: AppFonts.label,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 12,
            color: AppColors.neutral,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppFonts.label,
            fontSize: 12.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState!.validate();

    if (_totalPhotos == 0) {
      setState(() => _photoError = true);
      _showNoPhotosDialog();
      return;
    }

    if (!formValid) return;

    final make = _selectedMake == 'Otro'
        ? _customMakeController.text.trim()
        : _selectedMake;
    final model = _modelController.text.trim();
    final title = '$_selectedYear $make $model';
    final mileage = _mileageController.text.trim();
    final notes = _notesController.text.trim();

    // Formatear descripción estructurada estilo ficha técnica
    final formattedDescription = StringBuffer()
      ..writeln('🚗 Año: $_selectedYear | Marca: $make | Modelo: $model')
      ..writeln('🚙 Carrocería: $_selectedBodyType | Color: $_selectedColor')
      ..writeln('⚡ Transmisión: $_selectedTransmission | Combustible: $_selectedFuelType')
      ..writeln('🛣️ Kilometraje: $mileage km | Estado: $_selectedCondition');

    if (notes.isNotEmpty) {
      formattedDescription.writeln('\n📝 Observaciones: $notes');
    }

    final startingPrice =
        double.tryParse(_startingPriceController.text.trim()) ?? 0;
    final minIncrement =
        double.tryParse(_minIncrementController.text.trim()) ?? 0;
    final buyOutRaw = _buyOutPriceController.text.trim();
    final buyOutPrice = buyOutRaw.isNotEmpty ? double.tryParse(buyOutRaw) : null;

    final confirmed = await _showConfirmationDialog(
      title: title,
      bodyType: _selectedBodyType,
      color: _selectedColor,
      mileage: mileage,
      transmission: _selectedTransmission,
      fuelType: _selectedFuelType,
      condition: _selectedCondition,
      startingPrice: startingPrice,
      minIncrement: minIncrement,
      buyOutPrice: buyOutPrice,
      durationHours: _selectedDurationHours,
      notes: notes,
    );

    if (confirmed != true || !mounted) return;

    final now = DateTime.now();
    final startTime = now.subtract(const Duration(seconds: 5));
    final endTime = now.add(Duration(hours: _selectedDurationHours));

    setState(() {
      _isSubmitting = true;
      _uploadStatusText = _selectedFiles.isNotEmpty ? 'Subiendo fotos locales...' : 'Publicando...';
    });

    try {
      final List<String> finalImageUrls = [..._presetUrls];

      // Subir fotos locales seleccionadas por el usuario al backend
      if (_selectedFiles.isNotEmpty) {
        setState(() {
          _uploadStatusText = 'Subiendo ${_selectedFiles.length} foto(s)...';
        });
        final uploaded = await ref
            .read(auctionsRepositoryProvider)
            .uploadImages(_selectedFiles);
        finalImageUrls.addAll(uploaded);
      }

      setState(() {
        _uploadStatusText = 'Creando subasta en vivo...';
      });

      await ref.read(auctionsRepositoryProvider).createAuction(
            title: title,
            description: formattedDescription.toString().trim(),
            startingPrice: startingPrice,
            minIncrement: minIncrement,
            buyOutPrice: buyOutPrice,
            startTime: startTime,
            endTime: endTime,
            images: finalImageUrls.isNotEmpty ? finalImageUrls : null,
          );

      if (!mounted) return;
      ref.invalidate(sellerAuctionsProvider);
      ref.invalidate(activeAuctionsProvider);
      Navigator.of(context).pop();
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
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.secondary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text('¡"$title" publicada y en vivo!')),
              ],
            ),
          ),
        );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _uploadStatusText = null;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: AppColors.tertiary,
            content: Text('Error al publicar subasta: $e'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header fijo
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
                      child: const Icon(Icons.storefront_rounded,
                          size: 22, color: AppColors.secondaryDeep),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Publicar Vehículo en Subasta',
                            style: TextStyle(
                              fontFamily: AppFonts.headline,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Formulario detallado con características',
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

              // Formulario scrollable
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Botones rápidos de prueba
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _samplePresetChip(
                            'Mustang GT 2023',
                            () => _applyPreset(
                              year: 2023,
                              make: 'Ford',
                              model: 'Mustang GT Premium',
                              bodyType: 'Coupé',
                              mileage: '15000',
                              transmission: 'Automática',
                              fuelType: 'Gasolina',
                              color: 'Rojo',
                              startingPrice: '150000',
                              notes: 'Motor V8 5.0L Coyote, asientos en piel, escape activo.',
                              images: [
                                'https://images.unsplash.com/photo-1584345604476-8ec5e12e42dd?w=800',
                                'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800',
                              ],
                            ),
                          ),
                          _samplePresetChip(
                            'BMW M4 2024',
                            () => _applyPreset(
                              year: 2024,
                              make: 'BMW',
                              model: 'M4 Competition xDrive',
                              bodyType: 'Coupé',
                              mileage: '8500',
                              transmission: 'Dual-Clutch',
                              fuelType: 'Gasolina',
                              color: 'Azul',
                              startingPrice: '280000',
                              notes: 'Twin-Turbo 503 HP, rines forjados, frenos carbonocerámicos.',
                              images: [
                                'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800',
                                'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=800',
                              ],
                            ),
                          ),
                          _samplePresetChip(
                            'Sierra Denali 2022',
                            () => _applyPreset(
                              year: 2022,
                              make: 'GMC',
                              model: 'Sierra 1500 Denali Ultimate',
                              bodyType: 'Pickup / Camioneta',
                              mileage: '32000',
                              transmission: 'Automática',
                              fuelType: 'Gasolina',
                              color: 'Negro',
                              startingPrice: '240000',
                              notes: 'Motor 6.2L V8 4x4, suspensión adaptativa, audio Bose.',
                              images: [
                                'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800',
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // SECCIÓN 1: IDENTIFICACIÓN DEL VEHÍCULO
                      const _SectionLabel('1. IDENTIFICACIÓN DEL VEHÍCULO'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: DropdownButtonFormField<int>(
                              initialValue: _selectedYear,
                              isExpanded: true,
                              iconSize: 18,
                              style: const TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Año',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                prefixIconConstraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                prefixIcon: Icon(Icons.calendar_today_outlined, size: 16),
                              ),
                              items: List.generate(2026 - 1960 + 1, (i) => 2026 - i)
                                  .map((year) => DropdownMenuItem(
                                        value: year,
                                        child: Text('$year', overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedYear = val ?? _selectedYear),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 5,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedMake,
                              isExpanded: true,
                              iconSize: 18,
                              style: const TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Marca',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                prefixIconConstraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                prefixIcon: Icon(Icons.directions_car_outlined, size: 16),
                              ),
                              items: _makes
                                  .map((make) => DropdownMenuItem(
                                        value: make,
                                        child: Text(make, overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedMake = val ?? _selectedMake),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedMake == 'Otro') ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _customMakeController,
                          textCapitalization: TextCapitalization.words,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            labelText: 'Especifica la Marca del Vehículo',
                            hintText: 'Ej. Subaru, Volvo, Ferrari, Lamborghini, Peugeot, Cupra...',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            prefixIcon: Icon(Icons.edit_note_rounded, size: 18),
                          ),
                          validator: (v) {
                            if ((v ?? '').trim().isEmpty) {
                              return 'Por favor escribe la marca del vehículo';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _modelController,
                        textCapitalization: TextCapitalization.words,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          labelText: 'Modelo y Versión',
                          hintText: 'Ej. Mustang GT, Sierra Denali, Civic Si...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          prefixIcon: Icon(Icons.badge_outlined, size: 18),
                        ),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) return 'El modelo y versión es obligatorio';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedBodyType,
                        isExpanded: true,
                        iconSize: 20,
                        style: const TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Carrocería',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          prefixIcon: Icon(Icons.airport_shuttle_outlined, size: 18),
                        ),
                        items: _bodyTypes
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedBodyType = val ?? _selectedBodyType),
                      ),

                      const SizedBox(height: 22),

                      // SECCIÓN 2: ESTADO Y ESPECIFICACIONES TÉCNICAS
                      const _SectionLabel('2. ESPECIFICACIONES & ESTADO'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              controller: _mileageController,
                              keyboardType: TextInputType.number,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              decoration: const InputDecoration(
                                labelText: 'Kilometraje',
                                hintText: 'Ej. 45000',
                                suffixText: 'km',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                prefixIconConstraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                prefixIcon: Icon(Icons.speed_outlined, size: 16),
                              ),
                              validator: (v) {
                                final text = (v ?? '').trim();
                                if (text.isEmpty) return 'Ingresa el kilometraje';
                                final km = double.tryParse(text);
                                if (km == null || km < 0) return 'Kilometraje inválido';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 5,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedColor,
                              isExpanded: true,
                              iconSize: 18,
                              style: const TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Color Exterior',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                prefixIconConstraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                prefixIcon: Icon(Icons.palette_outlined, size: 16),
                              ),
                              items: _colors
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c, overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedColor = val ?? _selectedColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedTransmission,
                              isExpanded: true,
                              iconSize: 18,
                              style: const TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 12.5,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Transmisión',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                prefixIconConstraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                prefixIcon: Icon(Icons.settings_outlined, size: 16),
                              ),
                              items: _transmissions
                                  .map((t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(t, overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedTransmission = val ?? _selectedTransmission),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 5,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedFuelType,
                              isExpanded: true,
                              iconSize: 18,
                              style: const TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 12.5,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Combustible',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                prefixIconConstraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                prefixIcon: Icon(Icons.local_gas_station_outlined, size: 16),
                              ),
                              items: _fuelTypes
                                  .map((f) => DropdownMenuItem(
                                        value: f,
                                        child: Text(f, overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedFuelType = val ?? _selectedFuelType),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCondition,
                        isExpanded: true,
                        iconSize: 20,
                        style: const TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Condición General',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          prefixIcon: Icon(Icons.verified_outlined, size: 18),
                        ),
                        items: _conditions
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedCondition = val ?? _selectedCondition),
                      ),

                      const SizedBox(height: 22),

                      // SECCIÓN 3: PRECIOS Y CONDICIONES COMERCIALES (MXN)
                      const _SectionLabel('3. PRECIOS Y CONDICIONES (MXN)'),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _moneyField(
                              controller: _startingPriceController,
                              label: 'Precio de salida',
                              hint: '150000',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _moneyField(
                              controller: _minIncrementController,
                              label: 'Puja mínima',
                              hint: '5000',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _moneyField(
                        controller: _buyOutPriceController,
                        label: 'Compra directa / Cómpralo Ya (opcional)',
                        hint: 'Ej. 250000 · Adjudica al instante',
                        icon: Icons.bolt_rounded,
                        isOptional: true,
                      ),

                      const SizedBox(height: 22),

                      // SECCIÓN 4: DURACIÓN DE LA SUBASTA
                      const _SectionLabel('4. DURACIÓN DE LA SUBASTA'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final (hours, label, icon) in _durations)
                            _durationChip(hours, label, icon),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // SECCIÓN 5: FOTOS DEL VEHÍCULO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _SectionLabel('5. FOTOS DEL VEHÍCULO'),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: _totalPhotos >= 20
                                      ? AppColors.tertiary.withAlpha(30)
                                      : (_totalPhotos == 0
                                          ? AppColors.tertiary.withAlpha(20)
                                          : AppColors.secondary.withAlpha(25)),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _totalPhotos >= 20
                                        ? AppColors.tertiary
                                        : (_totalPhotos == 0
                                            ? AppColors.tertiary
                                            : AppColors.secondary),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  _totalPhotos == 0 ? 'Mín. 1 · 0/20' : '$_totalPhotos/20 fotos',
                                  style: TextStyle(
                                    fontFamily: AppFonts.label,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _totalPhotos >= 20
                                        ? AppColors.tertiary
                                        : (_totalPhotos == 0
                                            ? AppColors.tertiary
                                            : AppColors.secondary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_totalPhotos < 20)
                            InkWell(
                              onTap: _pickFromGallery,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.add_photo_alternate_outlined, size: 16, color: AppColors.primary),
                                    SizedBox(width: 4),
                                    Text(
                                      'Galería',
                                      style: TextStyle(
                                        fontFamily: AppFonts.label,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_totalPhotos == 0)
                        InkWell(
                          onTap: _isPickingImages ? null : _pickFromGallery,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                            decoration: BoxDecoration(
                              color: _photoError
                                  ? AppColors.tertiary.withAlpha(12)
                                  : (_isPickingImages
                                      ? AppColors.secondary.withAlpha(15)
                                      : AppColors.surfaceVariant),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _photoError
                                    ? AppColors.tertiary
                                    : (_isPickingImages
                                        ? AppColors.secondary
                                        : AppColors.border),
                                width: _isPickingImages || _photoError ? 1.6 : 1.2,
                              ),
                            ),
                            child: Column(
                              children: [
                                if (_isPickingImages) ...[
                                  const SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Cargando imágenes de la galería...',
                                    style: TextStyle(
                                      fontFamily: AppFonts.headline,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondaryDeep,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Optimizando fotos seleccionadas...',
                                    style: TextStyle(
                                      fontFamily: AppFonts.body,
                                      fontSize: 12,
                                      color: AppColors.neutral,
                                    ),
                                  ),
                                ] else ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _photoError
                                          ? AppColors.tertiary.withAlpha(20)
                                          : AppColors.primary.withAlpha(15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 26,
                                      color: _photoError
                                          ? AppColors.tertiary
                                          : AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _photoError
                                        ? '¡Foto requerida para publicar!'
                                        : 'Seleccionar fotos locales del vehículo',
                                    style: TextStyle(
                                      fontFamily: AppFonts.headline,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: _photoError
                                          ? AppColors.tertiary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _photoError
                                        ? 'Toca aquí para elegir al menos 1 imagen desde la galería'
                                        : 'Hasta 20 fotos desde la galería de tu dispositivo',
                                    style: TextStyle(
                                      fontFamily: AppFonts.body,
                                      fontSize: 11.5,
                                      color: _photoError
                                          ? AppColors.tertiary
                                          : AppColors.neutral,
                                      fontWeight: _photoError
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      else ...[
                        if (_isPickingImages) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.secondary.withAlpha(80)),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.secondaryDeep,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Cargando y optimizando fotos seleccionadas...',
                                    style: TextStyle(
                                      fontFamily: AppFonts.body,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondaryDeep,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        _buildPhotoThumbnailsGrid(),
                      ],

                      const SizedBox(height: 22),

                      // SECCIÓN 6: DETALLES Y OBSERVACIONES
                      const _SectionLabel('6. DETALLES Y OBSERVACIONES'),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          hintText: 'Describe el estado mecánico, papeles al día, equipamiento adicional, etc.',
                        ),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) {
                            return 'Ingresa los detalles y observaciones del vehículo';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Botón fijo al fondo
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.rocket_launch_rounded, size: 20),
                    label: Text(
                      _uploadStatusText ?? (_isSubmitting ? 'Publicando...' : 'Publicar Subasta Ahora'),
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
      ),
    );
  }

  Widget _samplePresetChip(String label, VoidCallback onPressed) {
    return ActionChip(
      avatar: const Icon(Icons.auto_awesome, size: 14, color: AppColors.secondaryDeep),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: AppFonts.label,
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      backgroundColor: AppColors.surfaceVariant,
      side: const BorderSide(color: AppColors.border, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: onPressed,
    );
  }

  Widget _durationChip(int hours, String label, IconData icon) {
    final selected = _selectedDurationHours == hours;
    return ChoiceChip(
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _selectedDurationHours = hours),
      avatar: Icon(
        icon,
        size: 15,
        color: selected ? Colors.white : AppColors.neutral,
      ),
      label: Text(label),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceVariant,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      labelStyle: TextStyle(
        fontFamily: AppFonts.label,
        fontSize: 12,
        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        color: selected ? Colors.white : AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  Widget _moneyField({
    required String label,
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: AppFonts.headline,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(text: label),
              if (!isOptional)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                TextSpan(
                  text: ' · opcional',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    color: AppColors.neutral.withAlpha(255),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12.5),
            prefixText: '\$ ',
            prefixStyle: const TextStyle(
              fontFamily: AppFonts.label,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
            prefixIcon: icon != null
                ? Icon(icon, size: 17, color: AppColors.secondaryDeep)
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          validator: isOptional
              ? (v) {
                  final raw = (v ?? '').trim();
                  if (raw.isEmpty) return null;
                  final val = double.tryParse(raw);
                  if (val == null || val <= 0) return 'Monto > \$0';
                  return null;
                }
              : (v) {
                  final raw = (v ?? '').trim();
                  if (raw.isEmpty) return 'Este monto es obligatorio';
                  final val = double.tryParse(raw);
                  if (val == null || val <= 0) return 'Monto debe ser mayor a \$0';
                  return null;
                },
        ),
      ],
    );
  }

  Widget _buildPhotoThumbnailsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: _totalPhotos + (_totalPhotos < 20 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _totalPhotos && _totalPhotos < 20) {
          if (_isPickingImages) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondary, width: 1.5),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Cargando...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.label,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryDeep,
                    ),
                  ),
                ],
              ),
            );
          }
          return InkWell(
            onTap: _pickFromGallery,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined, size: 24, color: AppColors.primary),
                  const SizedBox(height: 4),
                  Text(
                    'Agregar\n($_totalPhotos/20)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppFonts.label,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final isPreset = index < _presetUrls.length;
        final fileIndex = index - _presetUrls.length;

        return Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isPreset
                    ? Image.network(
                        _presetUrls[index],
                        fit: BoxFit.cover,
                        cacheWidth: 300,
                        cacheHeight: 300,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppColors.surfaceVariant,
                            child: const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.broken_image_rounded),
                        ),
                      )
                    : (kIsWeb
                        ? Image.network(
                            _selectedFiles[fileIndex].path,
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                            cacheHeight: 300,
                          )
                        : Image.file(
                            File(_selectedFiles[fileIndex].path),
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                            cacheHeight: 300,
                            frameBuilder: (context, child, frame, wasSync) {
                              if (wasSync || frame != null) return child;
                              return Container(
                                color: AppColors.surfaceVariant,
                                child: const Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: index == 0 ? AppColors.secondary : AppColors.border,
                    width: index == 0 ? 1.8 : 1,
                  ),
                ),
              ),
            ),
            if (index == 0)
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryDeep,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'PORTADA',
                    style: TextStyle(
                      fontFamily: AppFonts.label,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(160),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${index + 1}',
                  style: const TextStyle(
                    fontFamily: AppFonts.label,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 3,
              right: 3,
              child: InkWell(
                onTap: () {
                  if (isPreset) {
                    _removePresetUrl(index);
                  } else {
                    _removeFile(fileIndex);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontFamily: AppFonts.label,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

