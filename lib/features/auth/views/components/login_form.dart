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
          // Email Field
          TextFormField(
            controller: _emailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Địa chỉ Email',
              hintText: 'student@example.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: AuthController.validateEmail,
            onFieldSubmitted: (_) {
              _passwordFocusNode.requestFocus();
            },
          ),
          const SizedBox(height: 16),

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
              labelText: 'Mật khẩu',
              hintText: 'Nhập mật khẩu của bạn',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondary,
                ),
                onPressed: isLoading ? null : _togglePasswordVisibility,
                tooltip: _isPasswordVisible ? 'Ẩn mật khẩu' : 'Hiện mật khẩu',
              ),
            ),
            validator: AuthController.validatePassword,
            onFieldSubmitted: (_) => _handleSubmit(),
          ),
          const SizedBox(height: 24),

          // Submit Button
          AppButton(
            text: 'Đăng nhập',
            isLoading: isLoading,
            onPressed: isLoading ? null : _handleSubmit,
          ),
        ],
      ),
    );
  }
}
