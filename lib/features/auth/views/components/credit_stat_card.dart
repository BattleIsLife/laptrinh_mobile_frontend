import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/credit_account.dart';

/// Top summary banner showing aggregated financial metrics of all credit accounts.
class CreditStatCard extends StatelessWidget {
  final double totalLimit;
  final double totalBalance;
  final double availableLimit;
  final double utilizationRatio;
  final int activeAccounts;
  final int closedAccounts;

  const CreditStatCard({
    super.key,
    required this.totalLimit,
    required this.totalBalance,
    required this.availableLimit,
    required this.utilizationRatio,
    required this.activeAccounts,
    required this.closedAccounts,
  });

  @override
  Widget build(BuildContext context) {
    final utilizationPercent = (utilizationRatio * 100).clamp(0, 100);

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
                    Icons.analytics_outlined,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Tổng quan hạn mức tín dụng',
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
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$activeAccounts hoạt động',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
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
                  label: 'Tổng hạn mức',
                  amount: totalLimit,
                  color: AppTheme.primaryColor,
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.borderColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _buildMetricItem(
                    label: 'Đã chi tiêu',
                    amount: totalBalance,
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.borderColor),
              Expanded(
                child: _buildMetricItem(
                  label: 'Hạn mức còn lại',
                  amount: availableLimit,
                  color: AppTheme.successColor,
                  isRightAligned: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Utilization Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tỷ lệ sử dụng hạn mức',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${utilizationPercent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: utilizationPercent > 80
                          ? AppTheme.errorColor
                          : (utilizationPercent > 50
                              ? Colors.orange
                              : AppTheme.successColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: utilizationRatio.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    utilizationPercent > 80
                        ? AppTheme.errorColor
                        : (utilizationPercent > 50
                            ? Colors.orange
                            : AppTheme.successColor),
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
          CreditAccount.formatCurrency(amount),
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
