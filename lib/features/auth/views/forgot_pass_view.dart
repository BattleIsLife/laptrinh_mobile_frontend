import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';

/// Màn hình Quên mật khẩu theo chuẩn MVC:
/// - View chỉ hiển thị giao diện và nhận thao tác người dùng
/// - Toàn bộ xử lý logic, gọi API nằm trong [AuthController]
///
/// Luồng 3 bước:
/// Bước 1: Nhập Email -> gửi OTP
/// Bước 2: Nhập mã OTP
/// Bước 3: Nhập mật khẩu mới -> đặt lại mật khẩu
class ForgotPasswordView extends StatefulWidget {
  final AuthController? controller;

  const ForgotPasswordView({super.key, this.controller});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final AuthController _controller;
  bool _ownsController = false;

  // Quản lý bước hiện tại: 1 = Nhập Email, 2 = Nhập OTP, 3 = Đổi mật khẩu
  int _step = 1;

  // Ẩn / hiện mật khẩu
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  // Controller cho các ô nhập liệu
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = AuthController();
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Bước 1: Gọi Controller gửi OTP
  Future<void> _handleSendOtp() async {
    final success = await _controller.sendOtp(
      email: _emailController.text,
    );
    if (!mounted) return;

    if (success) {
      _showMessage(_controller.successMessage ?? 'Đã sinh ra mã OTP');
      setState(() {
        _step = 2; // Chuyển sang bước nhập OTP
      });
    } else {
      _showMessage(
        _controller.errorMessage ?? 'Gửi OTP thất bại',
        isError: true,
      );
    }
  }

  // Bước 2: Gọi Controller kiểm tra OTP, hợp lệ mới cho sang Bước 3
  Future<void> _handleConfirmOtpStep() async {
    final success = await _controller.verifyOtp(
      email: _emailController.text,
      otp: _otpController.text,
    );
    if (!mounted) return;

    if (success) {
      setState(() {
        _step = 3; // Chỉ sang bước nhập mật khẩu mới khi OTP hợp lệ
      });
    } else {
      _showMessage(
        _controller.errorMessage ?? 'Mã OTP không hợp lệ',
        isError: true,
      );
    }
  }

  // Bước 3: Gọi Controller đặt lại mật khẩu
  Future<void> _handleResetPassword() async {
    final success = await _controller.resetPassword(
      email: _emailController.text,
      otp: _otpController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
    if (!mounted) return;

    if (success) {
      _showMessage(
        _controller.successMessage ?? 'Đã đổi mật khẩu thành công!!',
      );
      Navigator.pop(context); // Quay về màn hình Đăng nhập
    } else {
      _showMessage(
        _controller.errorMessage ?? 'Đổi mật khẩu thất bại',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final isLoading = _controller.isLoading;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Bước $_step / 3',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_step == 1) _buildStep1Email(isLoading),
                  if (_step == 2) _buildStep2Otp(isLoading),
                  if (_step == 3) _buildStep3NewPassword(isLoading),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Giao diện Bước 1: Nhập Email
  Widget _buildStep1Email(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Nhập email của bạn',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Chúng tôi sẽ gửi mã OTP về email này để xác nhận.'),
        const SizedBox(height: 20),
        TextField(
          controller: _emailController,
          enabled: !isLoading,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'user@email.com',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isLoading ? null : _handleSendOtp,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Gửi mã OTP'),
        ),
      ],
    );
  }

  // Giao diện Bước 2: Nhập OTP
  Widget _buildStep2Otp(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Nhập mã OTP',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('Mã OTP đã được gửi tới: ${_emailController.text.trim()}'),
        const SizedBox(height: 20),
        TextField(
          controller: _otpController,
          enabled: !isLoading,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Mã OTP',
            hintText: 'Nhập mã OTP (ví dụ: 999999)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock_clock),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isLoading ? null : _handleConfirmOtpStep,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Tiếp tục'),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: isLoading ? null : () => setState(() => _step = 1),
              child: const Text('Đổi email khác'),
            ),
            TextButton(
              onPressed: isLoading ? null : _handleSendOtp,
              child: const Text('Gửi lại OTP'),
            ),
          ],
        ),
      ],
    );
  }

  // Giao diện Bước 3: Nhập mật khẩu mới
  Widget _buildStep3NewPassword(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Đặt mật khẩu mới',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Mật khẩu phải tối thiểu 8 ký tự, chứa chữ hoa, chữ thường và số (vd: Abc12345).',
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          enabled: !isLoading,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            labelText: 'Mật khẩu mới',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() => _showPassword = !_showPassword);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          enabled: !isLoading,
          obscureText: !_showConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Nhập lại mật khẩu mới',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() => _showConfirmPassword = !_showConfirmPassword);
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isLoading ? null : _handleResetPassword,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Đổi mật khẩu'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: isLoading ? null : () => setState(() => _step = 2),
          child: const Text('Quay lại nhập OTP'),
        ),
      ],
    );
  }
}
