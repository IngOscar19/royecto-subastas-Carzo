import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/token_storage.dart';
import '../../features/auth/presentation/auth_controller.dart';
import 'env.dart';

/// Cliente dio con base URL por entorno e interceptor que adjunta
/// automáticamente el JWT (`Authorization: Bearer <token>`) leído de
/// flutter_secure_storage y maneja respuestas 401 (JWT Expirado).
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(
    baseUrl: Env.apiBaseUrl,
    tokenLookup: tokenStorage.getAccessToken,
    onUnauthorized: () {
      ref.read(authControllerProvider.notifier).forceLogoutExpiredSession();
    },
  );
});

class ApiClient {
  ApiClient({
    required String baseUrl,
    required Future<String?> Function() tokenLookup,
    void Function()? onUnauthorized,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(
      _BearerTokenInterceptor(
        tokenLookup,
        onUnauthorized: onUnauthorized,
      ),
    );
  }

  late final Dio dio;
}

class _BearerTokenInterceptor extends InterceptorsWrapper {
  _BearerTokenInterceptor(
    this._tokenLookup, {
    this.onUnauthorized,
  });

  final Future<String?> Function() _tokenLookup;
  final void Function()? onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _tokenLookup().then((token) {
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    }).catchError((Object _) {
      handler.next(options);
    });
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}