import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

/// Controller coordinating authentication state and business logic.
///
/// Follows MVC architecture and extends [ChangeNotifier] for reactive updates.
/// Designed to be decoupled from Flutter widgets and [BuildContext], making it
/// fully testable with standard unit tests.
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

  /// Email validation rule.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ email.';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email không hợp lệ (ví dụ: student@example.com).';
    }
    return null;
  }

  /// Password validation rule.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu.';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải chứa ít nhất 6 ký tự.';
    }
    return null;
  }

  /// Executes user login.
  ///
  /// Returns `true` if login succeeded, `false` otherwise.
  /// On error, retains the input data and sets a descriptive [errorMessage].
  Future<bool> login({required String email, required String password}) async {
    // 1. Validate inputs locally before firing network requests
    final emailError = validateEmail(email);
    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      return false;
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      _errorMessage = passwordError;
      notifyListeners();
      return false;
    }

    // 2. Set loading state
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 3. Delegate to Service Layer
      // Lưu ý: Nếu backend nhận key là username, bạn có thể truyền email vào đây hoặc tùy chỉnh trong auth_service
      final authResult = await _authService.login(
        email: email.trim(),
        password: password,
      );

      // 4. Update success state
      _currentUser = authResult.user;
      _token = authResult.token;
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
      _errorMessage = 'Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Executes user registration.
  ///
  /// Nhận vào 4 trường dữ liệu theo đúng tài liệu API Backend:
  /// full_name, email, phone, password.
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    // 1. Validate cơ bản
    final emailError = validateEmail(email);
    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      return false;
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      _errorMessage = passwordError;
      notifyListeners();
      return false;
    }

    if (fullName.trim().isEmpty) {
      _errorMessage = 'Vui lòng nhập họ và tên đầy đủ.';
      notifyListeners();
      return false;
    }

    if (phone.trim().isEmpty) {
      _errorMessage = 'Vui lòng nhập số điện thoại di động.';
      notifyListeners();
      return false;
    }

    // 2. Set loading state
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 3. Gọi service đăng ký 
      // Tạm thời nếu AuthService chưa có hàm register, bạn có thể gọi API tương ứng ở đây
      await _authService.register(
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        password: password,
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

  /// Clears active error message.
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Resets authentication state to logged-out.
  void logout() {
    _currentUser = null;
    _token = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}