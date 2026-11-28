import 'package:flutter/material.dart';

import '../controllers/credit_controller.dart';
import '../models/credit_account_model.dart';

/// Màn hình Thêm mới hoặc Cập nhật Tài khoản tín dụng.
class CreditAccountFormView extends StatefulWidget {
  final CreditController controller;
  final CreditAccountModel? accountToEdit;

  const CreditAccountFormView({
    super.key,
    required this.controller,
    this.accountToEdit,
  });

  @override
  State<CreditAccountFormView> createState() => _CreditAccountFormViewState();
}

class _CreditAccountFormViewState extends State<CreditAccountFormView> {
  late String _accountType;
  late final TextEditingController _bankNameController;
  late final TextEditingController _creditLimitController;
  late final TextEditingController _currentBalanceController;

  bool get _isEditing => widget.accountToEdit != null;

  @override
  void initState() {
    super.initState();
    final acc = widget.accountToEdit;
    _accountType = acc?.accountType ?? 'CREDIT_CARD';
    _bankNameController = TextEditingController(text: acc?.bankName ?? '');
    _creditLimitController = TextEditingController(
      text: acc != null ? acc.creditLimit.toString() : '',
    );
    _currentBalanceController = TextEditingController(
      text: acc != null ? acc.currentBalance.toString() : '',
    );
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _creditLimitController.dispose();
    _currentBalanceController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    bool ok;
    if (_isEditing) {
      ok = await widget.controller.updateAccount(
        accountId: widget.accountToEdit!.id,
        accountType: _accountType,
        bankName: _bankNameController.text,
        creditLimitText: _creditLimitController.text,
        currentBalanceText: _currentBalanceController.text,
      );
    } else {
      ok = await widget.controller.addAccount(
        accountType: _accountType,
        bankName: _bankNameController.text,
        creditLimitText: _creditLimitController.text,
        currentBalanceText: _currentBalanceController.text,
      );
    }

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.successMessage ?? 'Lưu thành công',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.controller.errorMessage ?? 'Có lỗi xảy ra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Sửa tài khoản tín dụng' : 'Thêm tài khoản tín dụng',
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final isLoading = widget.controller.isLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _accountType,
                  decoration: const InputDecoration(
                    labelText: 'Loại tài khoản',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'CREDIT_CARD',
                      child: Text('Thẻ tín dụng (CREDIT_CARD)'),
                    ),
                    DropdownMenuItem(
                      value: 'OVERDRAFT',
                      child: Text('Thấu chi (OVERDRAFT)'),
                    ),
                  ],
                  onChanged: isLoading
                      ? null
                      : (val) {
                          if (val != null) {
                            setState(() => _accountType = val);
                          }
                        },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bankNameController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Tên ngân hàng',
                    hintText: 'Ví dụ: Ngân hàng ABC',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _creditLimitController,
                  enabled: !isLoading,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Hạn mức tín dụng',
                    hintText: 'Ví dụ: 5000000',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _currentBalanceController,
                  enabled: !isLoading,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Số dư hiện tại',
                    hintText: 'Ví dụ: 200000',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Cập nhật' : 'Thêm tài khoản'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
