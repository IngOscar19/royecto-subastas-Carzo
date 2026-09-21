import 'package:flutter/material.dart';

import 'auction.dart';

/// Categorías de vehículos disponibles en la plataforma
enum VehicleCategory {
  all,
  sports,
  sedan,
  suvElectric,
  pickup,
}

extension VehicleCategoryMeta on VehicleCategory {
  String get label {
    switch (this) {
      case VehicleCategory.all:
        return 'Todos los vehículos';
      case VehicleCategory.sports:
        return 'Deportivos & Muscle';
      case VehicleCategory.sedan:
        return 'Sedanes & Familiares';
      case VehicleCategory.suvElectric:
        return 'SUVs & Eléctricos';
      case VehicleCategory.pickup:
        return 'Pick-ups & 4x4';
    }
  }

  String get shortLabel {
    switch (this) {
      case VehicleCategory.all:
        return 'Todos';
      case VehicleCategory.sports:
        return 'Deportivo';
      case VehicleCategory.sedan:
        return 'Sedán';
      case VehicleCategory.suvElectric:
        return 'SUV / EV';
      case VehicleCategory.pickup:
        return 'Pick-up 4x4';
    }
  }

  IconData get icon {
    switch (this) {
      case VehicleCategory.all:
        return Icons.directions_car_rounded;
      case VehicleCategory.sports:
        return Icons.sports_motorsports_rounded;
      case VehicleCategory.sedan:
        return Icons.directions_car_filled_rounded;
      case VehicleCategory.suvElectric:
        return Icons.ev_station_rounded;
      case VehicleCategory.pickup:
        return Icons.local_shipping_rounded;
    }
  }

  bool matches(Auction auction) {
    if (this == VehicleCategory.all) return true;
    return auction.vehicleCategory == this;
  }
}

extension AuctionCategory on Auction {
  /// Determina la categoría del vehículo según el título y la descripción técnica.
  VehicleCategory get vehicleCategory {
    final text = '$title ${description ?? ''}'.toLowerCase();

    // 1. Pick-ups & Camionetas 4x4
    if (text.contains('pickup') ||
        text.contains('pick-up') ||
        text.contains('f-150') ||
        text.contains('f150') ||
        text.contains('f-250') ||
        text.contains('f250') ||
        text.contains('silverado') ||
        text.contains('sierra') ||
        text.contains('tacoma') ||
        text.contains('tundra') ||
        text.contains('ranger') ||
        text.contains('hilux') ||
        text.contains('frontier') ||
        text.contains('colorado') ||
        text.contains('canyon') ||
        text.contains('ram 1500') ||
        text.contains('ram 2500') ||
        text.contains('ram 3500') ||
        text.contains('amarok') ||
        text.contains('raptor') ||
        text.contains('lariat') ||
        text.contains('titan') ||
        text.contains('navara') ||
        text.contains('d-max') ||
        (text.contains('camioneta') && !text.contains('suv'))) {
      return VehicleCategory.pickup;
    }

    // 2. SUVs & Crossovers / Eléctricos
    if (text.contains('suv') ||
        text.contains('crossover') ||
        text.contains('eléctrico') ||
        text.contains('electrico') ||
        text.contains('electric') ||
        _hasWord(text, 'ev') ||
        _hasWord(text, 'phev') ||
        text.contains('híbrido') ||
        text.contains('hibrido') ||
        text.contains('hybrid') ||
        text.contains('tesla') ||
        text.contains('model 3') ||
        text.contains('model y') ||
        text.contains('model x') ||
        text.contains('model s') ||
        text.contains('cybertruck') ||
        text.contains('rav4') ||
        text.contains('cr-v') ||
        text.contains('crv') ||
        text.contains('explorer') ||
        text.contains('tahoe') ||
        text.contains('suburban') ||
        text.contains('cherokee') ||
        text.contains('grand cherokee') ||
        text.contains('wrangler') ||
        text.contains('renegade') ||
        text.contains('bronco') ||
        text.contains('tucson') ||
        text.contains('sportage') ||
        text.contains('cx-5') ||
        text.contains('cx-30') ||
        text.contains('cx-9') ||
        text.contains('cx-90') ||
        text.contains('tiguan') ||
        text.contains('atlas') ||
        text.contains('taos') ||
        text.contains('q3') ||
        text.contains('q5') ||
        text.contains('q7') ||
        text.contains('q8') ||
        text.contains('e-tron') ||
        text.contains('bmw x') ||
        text.contains('bmw ix') ||
        text.contains('glc') ||
        text.contains('gle') ||
        text.contains('gls') ||
        text.contains('eqe') ||
        text.contains('eqs') ||
        text.contains('taycan') ||
        text.contains('ioniq') ||
        text.contains('ev6') ||
        text.contains('mach-e') ||
        text.contains('4runner') ||
        text.contains('highlander') ||
        text.contains('pilot') ||
        text.contains('escape') ||
        text.contains('edge') ||
        text.contains('trax') ||
        text.contains('equinox') ||
        text.contains('rogue') ||
        text.contains('kicks') ||
        text.contains('pathfinder') ||
        text.contains('compass')) {
      return VehicleCategory.suvElectric;
    }

    // 3. Deportivos & Muscle Cars auténticos (excluye sedanes con paquetes de apariencia "Sport" o "GT-Line")
    final isSedanModel = text.contains('accord') ||
        text.contains('civic') ||
        text.contains('forte') ||
        text.contains('camry') ||
        text.contains('corolla') ||
        text.contains('altima') ||
        text.contains('sentra') ||
        text.contains('versa') ||
        text.contains('jetta') ||
        text.contains('passat') ||
        text.contains('golf') ||
        text.contains('polo') ||
        text.contains('aveo') ||
        text.contains('onix') ||
        text.contains('spark') ||
        text.contains('rio') ||
        text.contains('optima') ||
        text.contains('k5') ||
        text.contains('elantra') ||
        text.contains('sonata') ||
        text.contains('accent') ||
        text.contains('yaris') ||
        text.contains('prius') ||
        text.contains('mazda 3') ||
        text.contains('mazda 6') ||
        text.contains('ibiza') ||
        text.contains('leon') ||
        text.contains('vento') ||
        text.contains('fiesta') ||
        text.contains('focus') ||
        text.contains('cruze') ||
        text.contains('malibu') ||
        text.contains('fusion');

    final isTrackSpec = text.contains('type r') || text.contains('golf r');

    if (!isSedanModel || isTrackSpec) {
      if (text.contains('mustang') ||
          text.contains('camaro') ||
          text.contains('corvette') ||
          text.contains('challenger') ||
          text.contains('charger') ||
          text.contains('deportivo') ||
          text.contains('muscle car') ||
          text.contains('coupé') ||
          text.contains('coupe') ||
          text.contains('convertible') ||
          text.contains('cabriolet') ||
          text.contains('porsche') ||
          text.contains('911') ||
          text.contains('cayman') ||
          text.contains('boxster') ||
          text.contains('ferrari') ||
          text.contains('lamborghini') ||
          text.contains('supra') ||
          text.contains('m2') ||
          text.contains('m3') ||
          text.contains('m4') ||
          text.contains('m5') ||
          text.contains('m8') ||
          text.contains('mercedes-amg') ||
          text.contains('amg gt') ||
          text.contains('audi r8') ||
          text.contains('rs3') ||
          text.contains('rs4') ||
          text.contains('rs5') ||
          text.contains('rs6') ||
          text.contains('rs7') ||
          text.contains('tt rs') ||
          text.contains('gtr') ||
          text.contains('gt-r') ||
          text.contains('nismo') ||
          isTrackSpec ||
          text.contains('wrx') ||
          text.contains('sti') ||
          text.contains('viper') ||
          text.contains('bugatti') ||
          text.contains('mclaren') ||
          text.contains('aston martin') ||
          text.contains('maserati') ||
          text.contains('miata') ||
          text.contains('mx-5') ||
          text.contains('370z') ||
          text.contains('350z')) {
        return VehicleCategory.sports;
      }
    }

    // 4. Sedanes & Familiares (y default)
    return VehicleCategory.sedan;
  }

  bool _hasWord(String text, String word) {
    return RegExp(
      r'(^|[^\w])' + RegExp.escape(word) + r'([^\w]|$)',
      caseSensitive: false,
    ).hasMatch(text);
  }
}
