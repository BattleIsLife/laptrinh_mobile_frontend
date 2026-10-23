import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/auth_controller.dart';

/// Simple welcome / home screen displayed upon successful authentication.
class WelcomeView extends StatelessWidget {
  final AuthController controller;

  const WelcomeView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser;
    final token = controller.token ?? '';
    final maskedToken = token.length > 10
        ? '${token.substring(0, 6)}...${token.substring(token.length - 4)}'
        : token;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              controller.logout();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.borderColor),
                ),
                color: AppTheme.surfaceColor,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar Icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          size: 44,
                          color: AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Đăng nhập thành công!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Chào mừng bạn đã quay trở lại hệ thống.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: AppTheme.borderColor),
                      const SizedBox(height: 16),

                      // User Info Details
                      _buildInfoRow(
                        icon: Icons.person_outline,
                        label: 'Họ và tên',
                        value: user?.name.isNotEmpty == true
                            ? user!.name
                            : 'Chưa cập nhật',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user?.email ?? 'Không có',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.vpn_key_outlined,
                        label: 'Auth Token',
                        value: maskedToken.isNotEmpty
                            ? maskedToken
                            : 'Không có',
                      ),
                      const SizedBox(height: 28),

                      // Logout Button
                      AppButton(
                        text: 'Đăng xuất',
                        backgroundColor: AppTheme.errorColor,
                        icon: Icons.logout,
                        onPressed: () {
                          controller.logout();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
