import 'dart:async';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../models/forgot_password_model.dart';
import '../models/user.dart';

/// Contract for authentication operations.
abstract class AuthService {
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

  /// Gửi mã OTP về email người dùng (POST /api/auth/get_otp).
  Future<String> getOtp({required ForgotPasswordModel request});

  /// Kiểm tra mã OTP hợp lệ trước khi sang bước đặt mật khẩu mới.
  Future<void> verifyOtp({required String email, required String otp});

  /// Đặt lại mật khẩu mới bằng email + OTP (POST /api/auth/reset_password).
  Future<String> resetPassword({required ForgotPasswordModel request});
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

  @override
  Future<String> getOtp({required ForgotPasswordModel request}) async {
    final response = await _apiClient.post(
      '/api/auth/get_otp',
      body: request.toGetOtpJson(),
    );
    return response['message'] as String? ?? 'Đã sinh ra mã OTP';
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    // Tài liệu API backend kiểm tra OTP trực tiếp ở /api/auth/reset_password,
    // nên ở client kiểm tra đúng định dạng 6 chữ số trước khi sang bước đổi mật khẩu.
    if (!RegExp(r'^[0-9]{6}$').hasMatch(otp.trim())) {
      throw ApiException('Mã OTP phải gồm đúng 6 chữ số', statusCode: 400);
    }
  }

  @override
  Future<String> resetPassword({required ForgotPasswordModel request}) async {
    final response = await _apiClient.post(
      '/api/auth/reset_password',
      body: request.toResetPasswordJson(),
    );
    return response['message'] as String? ?? 'Đã đổi mật khẩu thành công!!';
  }
}

/// Mock service dùng để test giao diện offline mà không cần bật backend Node.js.
class MockAuthService implements AuthService {
  final Duration simulatedDelay;

  MockAuthService({this.simulatedDelay = const Duration(milliseconds: 400)});

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(simulatedDelay);
    return AuthResult(
      token: 'mock_jwt_token_123456',
      user: User(id: 1, name: 'Mock User', email: email),
    );
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(simulatedDelay);
  }

  @override
  Future<String> getOtp({required ForgotPasswordModel request}) async {
    await Future.delayed(simulatedDelay);

    if (request.email.trim().isEmpty) {
      throw ApiException('Vui lòng nhập email', statusCode: 401);
    }

    // Giả lập trường hợp email chưa đăng ký để test lỗi
    if (request.email.trim() == 'notfound@email.com') {
      throw ApiException(
        'Email này chưa được liên kết với tài khoản nào',
        statusCode: 401,
      );
    }

    return 'Đã sinh ra mã OTP';
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    await Future.delayed(simulatedDelay);

    if (otp.trim() != '999999') {
      throw ApiException(
        'OTP của bạn đã hết hạn hoặc không hợp lệ',
        statusCode: 401,
      );
    }
  }

  @override
  Future<String> resetPassword({required ForgotPasswordModel request}) async {
    await Future.delayed(simulatedDelay);

    if (request.email.trim().isEmpty) {
      throw ApiException('Vui lòng nhập email', statusCode: 401);
    }

    if (request.password.isEmpty ||
        request.password != request.confirmPassword) {
      throw ApiException('Mật khẩu không khớp', statusCode: 401);
    }

    // Mã OTP mẫu hợp lệ là 999999 (giống trong tài liệu API)
    if (request.otp.trim() != '999999') {
      throw ApiException(
        'OTP của bạn đã hết hạn hoặc không hợp lệ',
        statusCode: 401,
      );
    }

    return 'Đã đổi mật khẩu thành công!!';
  }
}
