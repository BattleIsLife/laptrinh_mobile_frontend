import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/saving_goal.dart';

/// Aggregated savings progress and target summary banner.
class SavingStatCard extends StatelessWidget {
  final double totalTarget;
  final double totalSaved;
  final double totalRemaining;
  final double overallProgress;
  final int activeCount;
  final int completedCount;

  const SavingStatCard({
    super.key,
    required this.totalTarget,
    required this.totalSaved,
    required this.totalRemaining,
    required this.overallProgress,
    required this.activeCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (overallProgress * 100).clamp(0, 100).toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.flag_circle_outlined,
                    color: AppTheme.primaryColor,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Tổng quan tiến độ tiết kiệm',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$completedCount hoàn thành',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3 Metric Columns
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  label: 'Tổng mục tiêu',
                  amount: totalTarget,
                  color: AppTheme.primaryColor,
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.borderColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _buildMetricItem(
                    label: 'Đã tích lũy',
                    amount: totalSaved,
                    color: AppTheme.successColor,
                  ),
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.borderColor),
              Expanded(
                child: _buildMetricItem(
                  label: 'Còn thiếu',
                  amount: totalRemaining,
                  color: const Color(0xFFF59E0B),
                  isRightAligned: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar with Percentage
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tiến độ toàn bộ danh mục',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: overallProgress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required double amount,
    required Color color,
    bool isRightAligned = false,
  }) {
    return Column(
      crossAxisAlignment:
          isRightAligned ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          SavingGoal.formatCurrency(amount),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
