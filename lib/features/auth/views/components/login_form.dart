import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../controllers/auth_controller.dart';

/// Reusable login form component managing form inputs, validation,
/// and password visibility.
class LoginForm extends StatefulWidget {
  final AuthController controller;
  final ValueChanged<String>? onLoginSuccess;

  const LoginForm({super.key, required this.controller, this.onLoginSuccess});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _passwordFocusNode;

  bool _isPasswordVisible = false;
  bool _rememberMe = false; // Thêm trạng thái cho checkbox Ghi nhớ đăng nhập

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _handleSubmit() async {
    // Unfocus keyboard
    FocusScope.of(context).unfocus();

    // Trigger local form validation
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Call controller. User inputs remain intact even if error occurs.
    final success = await widget.controller.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      widget.onLoginSuccess?.call(_emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.controller.isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Label cho ô Email/Số điện thoại
          const Text(
            'Email hoặc Số điện thoại',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Email Field
          TextFormField(
            controller: _emailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              hintText: 'vd: nguyen.van.a@email.com',
              prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppTheme.textSecondary, size: 20),
              filled: true,
              fillColor: const Color(0xFFF1F5F9), // Nền xám nhạt hiện đại giống mẫu
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              ),
            ),
            validator: AuthController.validateEmail,
            onFieldSubmitted: (_) {
              _passwordFocusNode.requestFocus();
            },
          ),
          const SizedBox(height: 20),

          // 2. Label cho ô Mật khẩu
          const Text(
            'Mật khẩu',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Password Field
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            enabled: !isLoading,
            obscureText: !_isPasswordVisible,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              hintText: 'Nhập mật khẩu an toàn',
              prefixIcon: const Icon(Icons.key_rounded, color: AppTheme.textSecondary, size: 20),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: isLoading ? null : _togglePasswordVisibility,
                tooltip: _isPasswordVisible ? 'Ẩn mật khẩu' : 'Hiện mật khẩu',
              ),
            ),
            validator: AuthController.validatePassword,
            onFieldSubmitted: (_) => _handleSubmit(),
          ),
          const SizedBox(height: 12),

          // 3. Ghi nhớ đăng nhập & Quên mật khẩu?
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ghi nhớ đăng nhập',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        // TODO: Xử lý sự kiện quên mật khẩu
                      },
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. Submit Button (Có thêm icon mũi tên giống thiết kế)
          AppButton(
            text: 'Đăng nhập',
            icon: Icons.arrow_forward_rounded,
            isLoading: isLoading,
            onPressed: isLoading ? null : _handleSubmit,
          ),
        ],
      ),
    );
  }
}