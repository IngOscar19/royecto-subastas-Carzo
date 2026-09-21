import 'package:json_annotation/json_annotation.dart';

import '../domain/user.dart';
import '../domain/user_role.dart';

part 'dtos.g.dart';

@JsonSerializable()
class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    this.phone,
  });

  final String email;
  final String password;
  final String name;
  final UserRole role;
  final String? phone;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  const AuthResponse({required this.user, required this.accessToken});

  final User user;
  final String accessToken;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}