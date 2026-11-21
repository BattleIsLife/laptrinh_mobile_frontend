import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/credit_account.dart';

/// Interactive visual credit card widget styled like modern banking cards.
class CreditCardWidget extends StatelessWidget {
  final CreditAccount account;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onClose;

  const CreditCardWidget({
    super.key,
    required this.account,
    this.onTap,
    this.onEdit,
    this.onClose,
  });

  /// Gradients matching bank styling and card status.
  List<Color> _getCardGradient() {
    if (account.isClosed) {
      return [const Color(0xFF64748B), const Color(0xFF475569)];
    }

    if (account.isOverdraft) {
      return [const Color(0xFF0D9488), const Color(0xFF042F2E)]; // Emerald / Teal
    }

    final bank = account.bankName.toLowerCase();
    if (bank.contains('techcombank')) {
      return [const Color(0xFFDC2626), const Color(0xFF7F1D1D)]; // Crimson Red
    } else if (bank.contains('vpbank')) {
      return [const Color(0xFF059669), const Color(0xFF064E3B)]; // VP Emerald
    } else if (bank.contains('vietcombank') || bank.contains('vcb')) {
      return [const Color(0xFF15803D), const Color(0xFF14532D)]; // VCB Green
    } else if (bank.contains('mb') || bank.contains('mbbank')) {
      return [const Color(0xFF2563EB), const Color(0xFF1E3A8A)]; // Royal Blue
    } else if (bank.contains('bidv')) {
      return [const Color(0xFF0284C7), const Color(0xFF0369A1)]; // BIDV Cyan/Blue
    }

    // Default sleek dark purple / blue gradient
    return [const Color(0xFF3B82F6), const Color(0xFF1E1B4B)];
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getCardGradient();
    final isClosed = account.isClosed;

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Bank Name, Status Badge & Menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            account.isCreditCard
                                ? Icons.credit_card
                                : Icons.account_balance,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            account.bankName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isClosed
                          ? Colors.black.withValues(alpha: 0.3)
                          : AppTheme.successColor.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      account.statusDisplay,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Popup Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    color: AppTheme.surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!();
                      } else if (value == 'close' && onClose != null) {
                        onClose!();
                      } else if (value == 'detail' && onTap != null) {
                        onTap!();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'detail',
                        child: Row(
                          children: [
                            Icon(Icons.visibility_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Xem chi tiết'),
                          ],
                        ),
                      ),
                      if (!isClosed) ...[
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Cập nhật'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'close',
                          child: Row(
                            children: [
                              Icon(
                                Icons.block_outlined,
                                size: 18,
                                color: AppTheme.errorColor,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Đóng tài khoản',
                                style: TextStyle(color: AppTheme.errorColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Chip & Contactless Icons + Type Label
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // EMV Chip simulation
                      Container(
                        width: 38,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700), // Gold
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFDAA520),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 28,
                            height: 18,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFB8860B),
                                width: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.contactless,
                        color: Colors.white70,
                        size: 22,
                      ),
                    ],
                  ),
                  Text(
                    account.accountTypeDisplay.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Account Number Mask
              Text(
                '•••• •••• •••• ${account.id.toString().padLeft(4, '0')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.5,
                  fontFamily: 'monospace',
                ),
              ),

              const SizedBox(height: 14),

              // Balance & Limit Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DƯ NỢ HIỆN TẠI',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CreditAccount.formatCurrency(account.currentBalance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'HẠN MỨC',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CreditAccount.formatCurrency(account.creditLimit),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Utilization Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: account.utilizationPercentage,
                  minHeight: 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    account.utilizationPercentage > 0.85
                        ? const Color(0xFFF87171)
                        : (account.utilizationPercentage > 0.5
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFF34D399)),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đã dùng ${(account.utilizationPercentage * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'Còn lại: ${CreditAccount.formatCurrency(account.availableLimit)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
