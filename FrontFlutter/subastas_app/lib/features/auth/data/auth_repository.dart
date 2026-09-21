import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/auth_failure.dart';
import '../domain/user_role.dart';
import 'dtos.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider).dio);
});

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<AuthResponse> login({required String email, required String password}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: LoginRequest(email: email, password: password).toJson(),
      );
      return AuthResponse.fromJson(response.data ?? {});
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: RegisterRequest(
          email: email,
          password: password,
          name: name,
          role: role,
          phone: phone,
        ).toJson(),
      );
      return AuthResponse.fromJson(response.data ?? {});
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }

  AuthFailure mapDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      409 => const AuthFailure.emailAlreadyExists(),
      401 => const AuthFailure.invalidCredentials(),
      400 => AuthFailure.validation(_validationMessage(error.response?.data)),
      _ => const AuthFailure.connection(),
    };
  }

  String _validationMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is List && message.isNotEmpty) {
        return message.first.toString();
      }
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return 'Datos inválidos. Revisa los campos.';
  }
}