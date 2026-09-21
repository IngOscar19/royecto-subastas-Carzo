import 'package:flutter/foundation.dart';

/// Configuración por entorno vía --dart-define:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
class Env {
  Env._();

  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }
}