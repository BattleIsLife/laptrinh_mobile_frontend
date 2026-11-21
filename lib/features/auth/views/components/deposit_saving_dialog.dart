import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../models/saving_goal.dart';

/// Modal dialog allowing users to contribute funds directly to a saving goal.
class DepositSavingDialog extends StatefulWidget {
  final SavingGoal goal;
  final Future<bool> Function(double amount) onDeposit;

  const DepositSavingDialog({
    super.key,
    required this.goal,
    required this.onDeposit,
  });

  @override
  State<DepositSavingDialog> createState() => _DepositSavingDialogState();
}

class _DepositSavingDialogState extends State<DepositSavingDialog> {
  final _amountController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  static const List<double> _quickAmounts = [
    500000,
    1000000,
    2000000,
    5000000,
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double _getParsedDouble(String text) {
    final clean = text.replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  void _selectQuickAmount(double amount) {
    setState(() {
      _amountController.text = amount.toStringAsFixed(0);
      _errorMessage = null;
    });
  }

  Future<void> _handleDeposit() async {
    final amount = _getParsedDouble(_amountController.text);
    if (amount <= 0) {
      setState(() {
        _errorMessage = 'Vui lòng nhập số tiền đóng góp hợp lệ (> 0)';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await widget.onDeposit(amount);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.savings_outlined,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Đóng góp tiết kiệm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        widget.goal.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Goal status progress summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hiện có',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                      Text(
                        SavingGoal.formatCurrency(widget.goal.currentAmount),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Mục tiêu',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                      Text(
                        SavingGoal.formatCurrency(widget.goal.targetAmount),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              onChanged: (_) => setState(() => _errorMessage = null),
              decoration: InputDecoration(
                hintText: 'Nhập số tiền muốn nạp',
                prefixIcon: const Icon(Icons.attach_money_rounded),
                suffixText: 'VNĐ',
                errorText: _errorMessage,
              ),
            ),

            const SizedBox(height: 12),

            // Quick Amount Suggestion Chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _quickAmounts.map((amt) {
                return ActionChip(
                  label: Text(
                    '+${SavingGoal.formatCurrency(amt)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  onPressed: () => _selectQuickAmount(amt),
                  backgroundColor: AppTheme.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppTheme.borderColor),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    text: 'Xác nhận nạp',
                    isLoading: _isLoading,
                    height: 48,
                    onPressed: _handleDeposit,
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
