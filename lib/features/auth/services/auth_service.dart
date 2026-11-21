import 'dart:async';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../models/user.dart';

/// Contract for authentication operations.
abstract class AuthService {
  /// Factory constructor providing [MockAuthService] or [HttpAuthService]
  /// based on configuration or test parameters.
  factory AuthService({ApiClient? apiClient, bool? useMock}) {
    final shouldUseMock = useMock ?? ApiConfig.useMockService;
    if (shouldUseMock) {
      return MockAuthService();
    }
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

/// Real HTTP implementation connecting to Node.js backend via [ApiClient].
class HttpAuthService implements AuthService {
  final ApiClient _apiClient;

  HttpAuthService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Send request to POST /api/auth/login
    // Sensitive data is passed in request body and not logged.
    final response = await _apiClient.post(
      ApiConfig.loginEndpoint,
      body: {'username': email, 'password': password},
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
    // Gửi request POST /api/auth/register với 4 trường chuẩn backend yêu cầu
    await _apiClient.post(
      '/api/auth/register', // Hoặc thay bằng ApiConfig.registerEndpoint nếu nhóm có định nghĩa sẵn
      body: {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
  }
}

/// Mock implementation simulating backend behavior for testing and UI development.
class MockAuthService implements AuthService {
  final Duration simulatedDelay;

  MockAuthService({this.simulatedDelay = const Duration(milliseconds: 600)});

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Simulate network latency
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }

    // Network error simulation hook
    if (email.contains('network_error')) {
      throw NetworkException(
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.',
      );
    }

    // Invalid credentials simulation
    if (password == 'wrong-password' || password == 'wrong') {
      throw UnauthorizedException('Email hoặc mật khẩu không chính xác.');
    }

    // Accepted mock credential (or default student credentials)
    if (email == 'student@example.com' || email.isNotEmpty) {
      final displayName = email == 'student@example.com'
          ? 'Nguyen Van A'
          : email.split('@').first;

      return AuthResult(
        user: User(id: 1, email: email, name: displayName),
        token: 'mock-jwt-token-xyz-12345',
      );
    }

    throw UnauthorizedException('Tài khoản không tồn tại hoặc mật khẩu sai.');
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    // Giả lập độ trễ mạng khi đăng ký
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }

    // Giả lập lỗi trùng email hoặc số điện thoại nếu muốn test
    if (email == 'exists@example.com') {
      throw ApiException('Số điện thoại hoặc Email này đã được sử dụng');
    }
  }
}
