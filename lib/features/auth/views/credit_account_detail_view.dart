import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/credit_account_controller.dart';
import '../models/credit_account.dart';
import 'add_edit_credit_account_view.dart';
import 'components/credit_card_widget.dart';

/// Screen displaying in-depth details of a specific credit account.
class CreditAccountDetailView extends StatefulWidget {
  final int accountId;
  final CreditAccountController controller;

  const CreditAccountDetailView({
    super.key,
    required this.accountId,
    required this.controller,
  });

  @override
  State<CreditAccountDetailView> createState() =>
      _CreditAccountDetailViewState();
}

class _CreditAccountDetailViewState extends State<CreditAccountDetailView> {
  CreditAccount? _account;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    final account = await widget.controller.fetchAccountDetail(widget.accountId);
    if (mounted) {
      setState(() {
        _account = account;
        _isLoading = false;
      });
    }
  }

  void _onEditAccount() async {
    if (_account == null) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditCreditAccountView(
          controller: widget.controller,
          accountToEdit: _account,
        ),
      ),
    );

    if (updated == true && mounted) {
      _loadDetail();
    }
  }

  void _confirmCloseAccount() {
    if (_account == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
            SizedBox(width: 8),
            Text('Đóng tài khoản'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn đóng tài khoản "${_account!.bankName}" không?\n\n'
          'Sau khi đóng, tài khoản sẽ chuyển sang trạng thái ĐÃ ĐÓNG và không thể thực hiện giao dịch mới.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success =
                  await widget.controller.closeAccount(widget.accountId);
              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.controller.successMessage ??
                          'Đã đóng tài khoản thành công',
                    ),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
                _loadDetail();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.controller.errorMessage ??
                          'Không thể đóng tài khoản',
                    ),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Đồng ý đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết tài khoản'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: _loadDetail,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _account == null
              ? _buildErrorView()
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card Representation
                          CreditCardWidget(
                            account: _account!,
                            onEdit: _account!.isActive ? _onEditAccount : null,
                            onClose: _account!.isActive
                                ? _confirmCloseAccount
                                : null,
                          ),

                          const SizedBox(height: 24),

                          // Financial Summary Card
                          _buildFinancialSummary(),

                          const SizedBox(height: 20),

                          // Account Specifications Card
                          _buildAccountSpecs(),

                          const SizedBox(height: 28),

                          // Action Buttons
                          if (_account!.isActive) ...[
                            AppButton(
                              text: 'Cập nhật thông tin tài khoản',
                              icon: Icons.edit,
                              onPressed: _onEditAccount,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              icon: const Icon(
                                Icons.block_outlined,
                                color: AppTheme.errorColor,
                              ),
                              label: const Text(
                                'Đóng tài khoản tín dụng',
                                style: TextStyle(
                                  color: AppTheme.errorColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppTheme.errorColor,
                                ),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _confirmCloseAccount,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildFinancialSummary() {
    final account = _account!;
    final utilization = (account.utilizationPercentage * 100).toStringAsFixed(1);

    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chỉ số tài chính',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Hạn mức tín dụng:',
              CreditAccount.formatCurrency(account.creditLimit),
              isHighlighted: true,
            ),
            const Divider(color: AppTheme.borderColor, height: 20),
            _buildDetailRow(
              'Dư nợ hiện tại:',
              CreditAccount.formatCurrency(account.currentBalance),
              valueColor: AppTheme.errorColor,
            ),
            const Divider(color: AppTheme.borderColor, height: 20),
            _buildDetailRow(
              'Hạn mức khả dụng:',
              CreditAccount.formatCurrency(account.availableLimit),
              valueColor: AppTheme.successColor,
            ),
            const Divider(color: AppTheme.borderColor, height: 20),
            _buildDetailRow(
              'Tỷ lệ đã sử dụng:',
              '$utilization%',
              valueColor: account.utilizationPercentage > 0.8
                  ? AppTheme.errorColor
                  : AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSpecs() {
    final account = _account!;

    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin tài khoản',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Mã tài khoản:', '#${account.id}'),
            const Divider(color: AppTheme.borderColor, height: 20),
            _buildDetailRow('Loại tài khoản:', account.accountTypeDisplay),
            const Divider(color: AppTheme.borderColor, height: 20),
            _buildDetailRow('Ngân hàng:', account.bankName),
            const Divider(color: AppTheme.borderColor, height: 20),
            _buildDetailRow('Ngày mở:', account.formattedOpenedDate),
            if (account.formattedClosedDate != null) ...[
              const Divider(color: AppTheme.borderColor, height: 20),
              _buildDetailRow(
                'Ngày đóng:',
                account.formattedClosedDate!,
                valueColor: AppTheme.errorColor,
              ),
            ],
            const Divider(color: AppTheme.borderColor, height: 20),
            _buildDetailRow(
              'Trạng thái:',
              account.statusDisplay,
              valueColor: account.isActive
                  ? AppTheme.successColor
                  : AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 15 : 14,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              widget.controller.errorMessage ??
                  'Không tìm thấy thông tin tài khoản',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadDetail,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
