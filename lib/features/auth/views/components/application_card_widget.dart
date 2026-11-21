import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/credit_application.dart';

/// Card widget representing a credit opening application.
class ApplicationCardWidget extends StatelessWidget {
  final CreditApplication application;
  final VoidCallback? onDelete;

  const ApplicationCardWidget({
    super.key,
    required this.application,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCreditCard = application.isCreditCard;

    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isCreditCard
                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                    : const Color(0xFF0D9488).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCreditCard ? Icons.credit_card : Icons.account_balance,
                color: isCreditCard
                    ? AppTheme.primaryColor
                    : const Color(0xFF0D9488),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isCreditCard
                              ? AppTheme.primaryColor.withValues(alpha: 0.1)
                              : const Color(0xFF0D9488).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          application.creditTypeDisplay,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isCreditCard
                                ? AppTheme.primaryColor
                                : const Color(0xFF0D9488),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // ID
                      Text(
                        '#${application.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 13,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ngày nộp: ${application.formattedDate}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete Action
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppTheme.errorColor,
                size: 20,
              ),
              tooltip: 'Hủy yêu cầu',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
