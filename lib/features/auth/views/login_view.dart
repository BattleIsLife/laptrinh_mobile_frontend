import 'package:flutter/material.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';
import 'components/login_form.dart';
import 'welcome_view.dart';

/// Main authentication screen.
///
/// Follows MVC: Coordinates with [AuthController] for state updates,
/// handles user navigation, and displays descriptive feedback.
class LoginView extends StatefulWidget {
  final AuthController? controller;

  const LoginView({super.key, this.controller});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final AuthController _controller;
  bool _ownsController = false;

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
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onLoginSuccess(String email) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WelcomeView(controller: _controller)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Section
                      _buildHeader(),
                      const SizedBox(height: 28),

                      // Error Banner (if any)
                      if (_controller.errorMessage != null) ...[
                        _buildErrorBanner(_controller.errorMessage!),
                        const SizedBox(height: 20),
                      ],

                      // Login Form Component
                      Card(
                        elevation: 0,
                        color: AppTheme.surfaceColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppTheme.borderColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: LoginForm(
                            controller: _controller,
                            onLoginSuccess: _onLoginSuccess,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Environment & Test Credentials Helper Box
                      _buildHelperCard(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.lock_person_outlined,
            size: 36,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Đăng nhập tài khoản',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Nhập email và mật khẩu của bạn để tiếp tục',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.errorBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.error_outline,
              color: AppTheme.errorColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.errorColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          InkWell(
            onTap: _controller.clearError,
            child: const Icon(
              Icons.close,
              color: AppTheme.errorColor,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelperCard() {
    final modeLabel = ApiConfig.useMockService ? 'MOCK SERVICE' : 'REST API';
    final modeColor = ApiConfig.useMockService ? Colors.orange : Colors.green;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Thông tin thử nghiệm (Dev Guide)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: modeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  modeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: modeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '• Email: student@example.com\n'
            '• Mật khẩu: example-password (hoặc bất kỳ >= 6 ký tự)\n'
            '• Mật khẩu thử lỗi sai: wrong\n'
            '• Email thử lỗi mạng: network_error@example.com',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
