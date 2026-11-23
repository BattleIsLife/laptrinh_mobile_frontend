
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

/// Controller coordinating authentication state and business logic.
class AuthController extends ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  String? _token;

  AuthController({AuthService? authService})
      : _authService = authService ?? AuthService();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _currentUser != null && _token != null;

  // =========================
  // VALIDATION
  // =========================

  /// Email validation - giống emailValidator bên backend.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }

    final cleanEmail = value.trim();
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailRegex.hasMatch(cleanEmail)) {
      return 'Định dạng Email không hợp lệ (ví dụ: name@example.com)';
    }

    return null;
  }

  /// Phone validation - giống phoneValidator bên backend.
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số điện thoại không được để trống';
    }

    final cleanPhone = value.trim();
    final phoneRegex = RegExp(r'^0[0-9]{9}$');

    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Số điện thoại không đúng định dạng (gồm 10 chữ số)';
    }

    return null;
  }

  /// Password validation - giống passwordValidator bên backend.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }

    final cleanPassword = value.trim();

    if (cleanPassword.length < 8) {
      return 'Mật khẩu phải có tối thiểu 8 ký tự';
    }

    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*\d)(?=.*[A-Z]).+$',
    );

    if (!passwordRegex.hasMatch(cleanPassword)) {
      return 'Mật khẩu phải chứa cả chữ hoa, chữ thường và số (ví dụ: Abc123456)';
    }

    return null;
  }
static int getPasswordStrength(String? value) {
  if (value == null || value.isEmpty) return 0;

  final password = value.trim();

  final hasMinLength = password.length >= 8;
  final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
  final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
  final hasNumber = RegExp(r'[0-9]').hasMatch(password);
  final hasSpecial = RegExp(r'[^a-zA-Z0-9]').hasMatch(password);

  final isValid = hasMinLength &&
      hasUppercase &&
      hasLowercase &&
      hasNumber;

  if (!isValid) return 0;

  if (password.length >= 12 && hasSpecial) return 2;

  return 1;
}
  // =========================
  // LOGIN
  // =========================

  /// Executes user login.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final emailError = validateEmail(email);

    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      return false;
    }

    if (password.isEmpty) {
      _errorMessage = 'Vui lòng nhập mật khẩu.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResult = await _authService.login(
        email: email.trim(),
        password: password,
      );

      _currentUser = authResult.user;
      _token = authResult.token;

      ApiClient.setAuthToken(_token);

      _errorMessage = null;
      _isLoading = false;
      notifyListeners();

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi đăng nhập. Vui lòng thử lại sau.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // =========================
  // REGISTER
  // =========================

  /// Executes user registration.
  /// Validation rules are synchronized with backend.
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    // 1. Validate full name
    if (fullName.trim().isEmpty) {
      _errorMessage = 'Họ và tên không được để trống';
      notifyListeners();
      return false;
    }

    if (fullName.trim().length > 100) {
      _errorMessage = 'Họ và tên không được quá 100 ký tự';
      notifyListeners();
      return false;
    }

    // 2. Validate email
    final emailError = validateEmail(email);

    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      return false;
    }

    // 3. Validate phone
    final phoneError = validatePhone(phone);

    if (phoneError != null) {
      _errorMessage = phoneError;
      notifyListeners();
      return false;
    }

    // 4. Validate password
    final passwordError = validatePassword(password);

    if (passwordError != null) {
      _errorMessage = passwordError;
      notifyListeners();
      return false;
    }

    // 5. Start registration
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        password: password.trim(),
      );

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();

      return false;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi đăng ký. Vui lòng thử lại sau.';
      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  // =========================
  // CLEAR ERROR
  // =========================

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // =========================
  // LOGOUT
  // =========================

  void logout() {
    _currentUser = null;
    _token = null;

    ApiClient.setAuthToken(null);

    _errorMessage = null;
    _isLoading = false;

    notifyListeners();
  }
}
