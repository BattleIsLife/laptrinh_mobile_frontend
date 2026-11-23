
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../controllers/auth_controller.dart';

/// Register form managing user registration inputs.
class RegisterForm extends StatefulWidget {
  final AuthController controller;
  final VoidCallback? onRegisterSuccess;

  const RegisterForm({
    super.key,
    required this.controller,
    this.onRegisterSuccess,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();

    // Cập nhật thanh độ mạnh khi mật khẩu thay đổi.
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);

    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng đồng ý với điều khoản dịch vụ để tiếp tục',
          ),
        ),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await widget.controller.register(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      widget.onRegisterSuccess?.call();
    }
  }

  // Màu sắc dựa trên độ mạnh mật khẩu.
  Color get _strengthColor {
    final strength = AuthController.getPasswordStrength(
      _passwordController.text,
    );

    switch (strength) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get _strengthLabel {
    final password = _passwordController.text;

    if (password.isEmpty) {
      return 'Chưa nhập';
    }

    final strength = AuthController.getPasswordStrength(password);

    switch (strength) {
      case 0:
        return 'Yếu';
      case 1:
        return 'Trung bình';
      case 2:
        return 'Mạnh';
      default:
        return 'Chưa nhập';
    }
  }

  Widget _buildPasswordRequirement(
    String label,
    bool isPassed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isPassed
                ? Icons.check_circle
                : Icons.check_circle_outline,
            size: 14,
            color: isPassed
                ? Colors.green
                : AppTheme.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isPassed
                  ? Colors.green
                  : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStrength() {
    final password = _passwordController.text;
    final strength = AuthController.getPasswordStrength(password);
    final color = _strengthColor;

    final hasMinLength = password.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    final colors = [
      Colors.red,
      Colors.orange,
      Colors.green,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),

        // Thanh độ mạnh gồm 3 đoạn màu.
        Row(
          children: List.generate(3, (index) {
            final isActive = password.isNotEmpty && index <= strength;

            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right: index == 2 ? 0 : 6,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? colors[strength]
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 8),

        // Nhãn độ mạnh.
        Row(
          children: [
            Icon(
              password.isEmpty
                  ? Icons.info_outline
                  : strength == 2
                      ? Icons.check_circle
                      : Icons.info_outline,
              size: 14,
              color: password.isEmpty
                  ? AppTheme.textSecondary
                  : color,
            ),
            const SizedBox(width: 6),
            Text(
              _strengthLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: password.isEmpty
                    ? AppTheme.textSecondary
                    : color,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Điều kiện mật khẩu.
        _buildPasswordRequirement(
          'Tối thiểu 8 ký tự',
          hasMinLength,
        ),
        _buildPasswordRequirement(
          'Chứa chữ hoa, chữ thường và số',
          hasUppercase && hasLowercase && hasNumber,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.controller.isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Họ và tên đầy đủ
          const Text(
            'Họ và tên đầy đủ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _fullNameController,
            enabled: !isLoading,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'vd: Nguyễn Văn An',
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Họ và tên không được để trống';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 2. Địa chỉ Email
          const Text(
            'Địa chỉ Email',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'name@example.com',
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: AuthController.validateEmail,
          ),
          const SizedBox(height: 16),

          // 3. Số điện thoại di động
          const Text(
            'Số điện thoại di động',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            enabled: !isLoading,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: '09xx xxx xxx',
              prefixIcon: const Icon(
                Icons.phone_outlined,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Số điện thoại không được để trống';
              }
              if (value.length < 10) {
                return 'Số điện thoại phải có ít nhất 10 chữ số';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 4. Mật khẩu
          const Text(
            'Mật khẩu',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            enabled: !isLoading,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'Tạo mật khẩu an toàn',
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: isLoading
                    ? null
                    : () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: AuthController.validatePassword,
          ),

          // Thanh độ mạnh mật khẩu cập nhật theo thời gian thực.
          _buildPasswordStrength(),

          const SizedBox(height: 16),

          // 5. Nhập lại mật khẩu
          const Text(
            'Nhập lại mật khẩu',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            enabled: !isLoading,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Xác nhận lại mật khẩu',
              prefixIcon: const Icon(
                Icons.lock_reset_rounded,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Mật khẩu nhập lại không khớp';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleSubmit(),
          ),
          const SizedBox(height: 16),

          // 6. Checkbox Điều khoản dịch vụ
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _agreedToTerms,
                  activeColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: isLoading
                      ? null
                      : (val) {
                          setState(() {
                            _agreedToTerms = val ?? false;
                          });
                        },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  children: [
                    const Text(
                      'Tôi đồng ý với ',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Điều khoản dịch vụ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Text(
                      ' và ',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Chính sách bảo mật dữ liệu tài chính',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Nút Đăng ký tài khoản
          AppButton(
            text: 'Đăng ký tài khoản',
            icon: Icons.arrow_forward_rounded,
            isLoading: isLoading,
            onPressed: isLoading ? null : _handleSubmit,
          ),
        ],
      ),
    );
  }
}
