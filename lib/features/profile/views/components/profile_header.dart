import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

import '../../models/profile.dart';

class ProfileHeader extends StatelessWidget {
  final Profile profile;

  const ProfileHeader({super.key, required this.profile});
  // Tạo avatar từ chữ cái đầu
  Widget _buildAvatar(String fullName) {
    final String initials = fullName.isNotEmpty
        ? fullName.trim().split(' ').last[0].toUpperCase()
        : '?';

    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    final Color bgColor = colors[fullName.length % colors.length];

    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: bgColor,
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.backgroundColor, // 0xFFF8FAFC — trắng xanh nhạt
            AppTheme.borderColor, // 0xFFE2E8F0 — xanh nhạt hơn
          ],
        ),

        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildAvatar(profile.fullName),
          SizedBox(height: 8),
          Text(
            profile.fullName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            profile.id.toString(),
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBadge(
                icon: Icons.shield,
                color: Colors.green,
                label: 'Sức khoẻ tài chính',
                value: '88/100 • Rất tốt',
              ),
              const SizedBox(width: 12),
              _buildBadge(
                icon: Icons.trending_up,
                color: Colors.blue,
                label: 'Điểm tín dụng',
                value: '745 • Hạng T',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: color)),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
