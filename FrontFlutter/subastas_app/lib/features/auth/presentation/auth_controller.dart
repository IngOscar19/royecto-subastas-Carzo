import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/dtos.dart';
import '../data/token_storage.dart';
import '../domain/user.dart';
import '../domain/user_role.dart';

/// Estado de sesión. `null` dentro de `AsyncValue` = no autenticado.
/// El primer `build()` restaura la sesión persistida (loading mientras tanto).
final authControllerProvider =
    AsyncNotifierProvider<AuthController, User?>(AuthController.new);

class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final tokenStorage = ref.watch(tokenStorageProvider);
    final token = await tokenStorage.getAccessToken();
    final userJson = await tokenStorage.getUserJson();
    if (token == null || userJson == null) {
      return null;
    }
    try {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } on Object {
      await tokenStorage.clear();
      return null;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final response = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    await _persistSession(tokenStorage, response);
    state = AsyncData(response.user);
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final response = await ref.read(authRepositoryProvider).register(
          email: email,
          password: password,
          name: name,
          role: role,
          phone: phone,
        );
    await _persistSession(tokenStorage, response);
    state = AsyncData(response.user);
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(null);
  }

  /// Logout forzado al expirar el JWT (HTTP 401).
  Future<void> forceLogoutExpiredSession() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(null);
  }

  Future<void> _persistSession(
    TokenStorage tokenStorage,
    AuthResponse response,
  ) async {
    await tokenStorage.saveAccessToken(response.accessToken);
    await tokenStorage.saveUserJson(jsonEncode(response.user.toJson()));
  }
}