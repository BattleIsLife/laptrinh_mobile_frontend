import 'dart:async';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../models/user.dart';

/// Contract for authentication operations.
abstract class AuthService {
  factory AuthService({ApiClient? apiClient}) {
    return HttpAuthService(apiClient: apiClient);
  }

  /// Authenticates a user with email and password.
  Future<AuthResult> login({required String email, required String password});

  /// Registers a new user with full_name, email, phone, and password.
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });
}

/// Real HTTP implementation connecting to backend via [ApiClient].
class HttpAuthService implements AuthService {
  final ApiClient _apiClient;

  HttpAuthService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.loginEndpoint,
      body: {
        'email': email,
        'password': password,
      },
    );

    return AuthResult.fromJson(response);
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _apiClient.post(
      '/api/auth/register',
      body: {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
  }
}