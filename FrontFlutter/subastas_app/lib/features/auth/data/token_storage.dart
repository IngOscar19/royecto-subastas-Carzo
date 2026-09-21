import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Acceso singleton al storage seguro de tokens/sesión.
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

/// Persistencia del JWT y de los datos de sesión (JSON del usuario).
/// flutter_secure_storage en iOS usa Keychain y en Android EncryptedSharedPreferences.
/// En macOS sin certificado de firma de desarrollo, usa fallback seguro en memoria si el Keychain falla (-34018).
class TokenStorage {
  static const _tokenKey = 'access_token';
  static const _userKey = 'user';

  final FlutterSecureStorage _storage;
  final Map<String, String> _memoryFallback = {};

  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> getAccessToken() async {
    try {
      final value = await _storage.read(key: _tokenKey);
      if (value != null) return value;
    } catch (e) {
      debugPrint('TokenStorage: Keychain read error ($e), usando fallback');
    }
    return _memoryFallback[_tokenKey];
  }

  Future<void> saveAccessToken(String token) async {
    _memoryFallback[_tokenKey] = token;
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('TokenStorage: Keychain write error ($e), usando fallback');
    }
  }

  Future<String?> getUserJson() async {
    try {
      final value = await _storage.read(key: _userKey);
      if (value != null) return value;
    } catch (e) {
      debugPrint('TokenStorage: Keychain read error ($e), usando fallback');
    }
    return _memoryFallback[_userKey];
  }

  Future<void> saveUserJson(String userJson) async {
    _memoryFallback[_userKey] = userJson;
    try {
      await _storage.write(key: _userKey, value: userJson);
    } catch (e) {
      debugPrint('TokenStorage: Keychain write error ($e), usando fallback');
    }
  }

  Future<void> clear() async {
    _memoryFallback.clear();
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
    } catch (e) {
      debugPrint('TokenStorage: Keychain clear error ($e)');
    }
  }
}