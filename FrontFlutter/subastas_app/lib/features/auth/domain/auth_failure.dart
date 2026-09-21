import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failure.freezed.dart';

@freezed
sealed class AuthFailure with _$AuthFailure {
  const AuthFailure._();

  const factory AuthFailure.emailAlreadyExists() = _EmailAlreadyExists;

  const factory AuthFailure.invalidCredentials() = _InvalidCredentials;

  const factory AuthFailure.validation(String message) = _Validation;

  const factory AuthFailure.connection() = _Connection;

  /// Mensaje legible para mostrar al usuario.
  String get uiMessage => switch (this) {
        _EmailAlreadyExists() =>
          'Ya existe un usuario con ese email. Intenta iniciar sesión.',
        _InvalidCredentials() => 'Email o contraseña incorrectos.',
        _Validation(message: final message) => message,
        _Connection() => 'No se pudo conectar con el servidor.',
      };
}