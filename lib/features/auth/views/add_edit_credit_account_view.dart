import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/credit_account_controller.dart';
import '../models/credit_account.dart';
import 'components/credit_card_widget.dart';

/// Screen for adding a new credit account or updating an existing one.
class AddEditCreditAccountView extends StatefulWidget {
  final CreditAccountController controller;
  final CreditAccount? accountToEdit;

  const AddEditCreditAccountView({
    super.key,
    required this.controller,
    this.accountToEdit,
  });

  bool get isEditing => accountToEdit != null;

  @override
  State<AddEditCreditAccountView> createState() =>
      _AddEditCreditAccountViewState();
}

class _AddEditCreditAccountViewState extends State<AddEditCreditAccountView> {
  final _formKey = GlobalKey<FormState>();

  late String _accountType;
  late final TextEditingController _bankNameController;
  late final TextEditingController _creditLimitController;
  late final TextEditingController _balanceController;

  static const List<String> _popularBanks = [
    'Ngân hàng Techcombank',
    'Ngân hàng Vietcombank',
    'Ngân hàng VPBank',
    'Ngân hàng MB Bank',
    'Ngân hàng BIDV',
    'Ngân hàng VietinBank',
    'Ngân hàng ACB',
    'Ngân hàng Sacombank',
    'Ngân hàng TPBank',
  ];

  @override
  void initState() {
    super.initState();
    final account = widget.accountToEdit;

    _accountType = account?.accountType ?? 'CREDIT_CARD';
    _bankNameController = TextEditingController(text: account?.bankName ?? '');
    _creditLimitController = TextEditingController(
      text: account != null ? account.creditLimit.toStringAsFixed(0) : '',
    );
    _balanceController = TextEditingController(
      text: account != null ? account.currentBalance.toStringAsFixed(0) : '0',
    );
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _creditLimitController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  double _getParsedDouble(String text) {
    final clean = text.replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  CreditAccount _createPreviewAccount() {
    final existing = widget.accountToEdit;
    return CreditAccount(
      id: existing?.id ?? 9999,
      userId: existing?.userId ?? 1,
      accountType: _accountType,
      bankName: _bankNameController.text.trim().isEmpty
          ? 'Tên ngân hàng'
          : _bankNameController.text.trim(),
      creditLimit: _getParsedDouble(_creditLimitController.text),
      currentBalance: _getParsedDouble(_balanceController.text),
      openedDate: existing?.openedDate ?? DateTime.now(),
      status: existing?.status ?? 'ACTIVE',
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bankName = _bankNameController.text.trim();
    final creditLimit = _getParsedDouble(_creditLimitController.text);
    final balance = _getParsedDouble(_balanceController.text);

    bool success;
    if (widget.isEditing) {
      success = await widget.controller.updateAccount(
        accountId: widget.accountToEdit!.id,
        accountType: _accountType,
        bankName: bankName,
        creditLimit: creditLimit,
        currentBalance: balance,
      );
    } else {
      success = await widget.controller.addAccount(
        accountType: _accountType,
        bankName: bankName,
        creditLimit: creditLimit,
        currentBalance: balance,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.successMessage ?? 'Thao tác thành công',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.errorMessage ?? 'Thao tác thất bại',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Cập nhật tài khoản'
              : 'Thêm tài khoản tín dụng',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Live Card Preview
                  const Text(
                    'Xem trước giao diện thẻ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CreditCardWidget(account: _createPreviewAccount()),

                  const SizedBox(height: 24),

                  // Account Type Selector
                  const Text(
                    'Loại tài khoản *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeOption(
                          label: 'Thẻ tín dụng',
                          value: 'CREDIT_CARD',
                          icon: Icons.credit_card,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTypeOption(
                          label: 'Thấu chi',
                          value: 'OVERDRAFT',
                          icon: Icons.account_balance,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Bank Name Field with Autocomplete
                  const Text(
                    'Ngân hàng phát hành *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Autocomplete<String>(
                    initialValue: TextEditingValue(
                      text: _bankNameController.text,
                    ),
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return _popularBanks;
                      }
                      return _popularBanks.where(
                        (bank) => bank.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                      );
                    },
                    onSelected: (selection) {
                      setState(() {
                        _bankNameController.text = selection;
                      });
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                      // Synchronize text
                      controller.addListener(() {
                        if (_bankNameController.text != controller.text) {
                          _bankNameController.text = controller.text;
                          setState(() {});
                        }
                      });
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        validator: CreditAccountController.validateBankName,
                        decoration: const InputDecoration(
                          hintText: 'Nhập hoặc chọn tên ngân hàng',
                          prefixIcon: Icon(Icons.account_balance_outlined),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Credit Limit Input
                  const Text(
                    'Hạn mức tín dụng (VNĐ) *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _creditLimitController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: CreditAccountController.validateCreditLimit,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Ví dụ: 10000000',
                      prefixIcon: Icon(Icons.speed),
                      suffixText: 'VNĐ',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Current Balance Input
                  const Text(
                    'Số dư nợ hiện tại (VNĐ) *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _balanceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: CreditAccountController.validateCurrentBalance,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Ví dụ: 200000',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      suffixText: 'VNĐ',
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  ListenableBuilder(
                    listenable: widget.controller,
                    builder: (context, _) {
                      return AppButton(
                        text: widget.isEditing
                            ? 'Lưu thay đổi'
                            : 'Thêm tài khoản',
                        isLoading: widget.controller.isActionLoading,
                        icon: widget.isEditing ? Icons.check : Icons.add,
                        onPressed: _submitForm,
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _accountType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _accountType = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
            width: isSelected ? 2 : 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
