import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/saving_controller.dart';
import '../models/saving_goal.dart';
import 'components/saving_goal_card_widget.dart';

/// Screen for adding or editing a savings goal.
class AddEditSavingView extends StatefulWidget {
  final SavingController controller;
  final SavingGoal? goalToEdit;

  const AddEditSavingView({
    super.key,
    required this.controller,
    this.goalToEdit,
  });

  bool get isEditing => goalToEdit != null;

  @override
  State<AddEditSavingView> createState() => _AddEditSavingViewState();
}

class _AddEditSavingViewState extends State<AddEditSavingView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _targetAmountController;
  late final TextEditingController _monthlyContributionController;
  late final TextEditingController _interestRateController;
  late final TextEditingController _currentAmountController;

  late DateTime _selectedDate;
  late String _status;

  @override
  void initState() {
    super.initState();
    final goal = widget.goalToEdit;

    _nameController = TextEditingController(text: goal?.name ?? '');
    _targetAmountController = TextEditingController(
      text: goal != null ? goal.targetAmount.toStringAsFixed(0) : '',
    );
    _monthlyContributionController = TextEditingController(
      text: goal != null ? goal.monthlyContribution.toStringAsFixed(0) : '',
    );
    _interestRateController = TextEditingController(
      text: goal != null ? goal.interestRate.toStringAsFixed(1) : '0.0',
    );
    _currentAmountController = TextEditingController(
      text: goal != null ? goal.currentAmount.toStringAsFixed(0) : '0',
    );

    _selectedDate = goal?.targetDate ?? DateTime.now().add(const Duration(days: 180));
    _status = goal?.status ?? 'ACTIVE';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _monthlyContributionController.dispose();
    _interestRateController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  double _getParsedDouble(String text) {
    final clean = text.replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  SavingGoal _createPreviewGoal() {
    final existing = widget.goalToEdit;
    return SavingGoal(
      id: existing?.id ?? 9999,
      userId: existing?.userId ?? 1,
      name: _nameController.text.trim().isEmpty
          ? 'Tên mục tiêu của bạn'
          : _nameController.text.trim(),
      targetAmount: _getParsedDouble(_targetAmountController.text),
      currentAmount: widget.isEditing
          ? _getParsedDouble(_currentAmountController.text)
          : (existing?.currentAmount ?? 0.0),
      monthlyContribution: _getParsedDouble(_monthlyContributionController.text),
      interestRate: _getParsedDouble(_interestRateController.text),
      targetDate: _selectedDate,
      status: _status,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _pickTargetDate() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(tomorrow) ? _selectedDate : tomorrow,
      firstDate: tomorrow,
      lastDate: DateTime(now.year + 20),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dateErr = SavingController.validateTargetDate(_selectedDate);
    if (dateErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dateErr), backgroundColor: AppTheme.errorColor),
      );
      return;
    }

    final name = _nameController.text.trim();
    final targetAmount = _getParsedDouble(_targetAmountController.text);
    final monthly = _getParsedDouble(_monthlyContributionController.text);
    final rate = _getParsedDouble(_interestRateController.text);
    final formattedDate =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    bool success;
    if (widget.isEditing) {
      final currentAmount = _getParsedDouble(_currentAmountController.text);
      success = await widget.controller.updateSaving(
        savingId: widget.goalToEdit!.id,
        name: name,
        targetAmount: targetAmount,
        monthlyContribution: monthly,
        targetDate: formattedDate,
        interestRate: rate,
        status: _status,
        currentAmount: currentAmount,
      );
    } else {
      success = await widget.controller.addSaving(
        name: name,
        targetAmount: targetAmount,
        monthlyContribution: monthly,
        targetDate: formattedDate,
        interestRate: rate,
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
              ? 'Sửa mục tiêu tiết kiệm'
              : 'Thêm mục tiêu tiết kiệm',
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
                  // Live Preview Card
                  const Text(
                    'Xem trước mục tiêu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SavingGoalCardWidget(goal: _createPreviewGoal()),

                  const SizedBox(height: 24),

                  // Goal Name
                  const Text(
                    'Tên mục tiêu tiết kiệm *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    validator: SavingController.validateName,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Ví dụ: Mua xe máy, Quỹ khẩn cấp, Mua laptop...',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Target Amount
                  const Text(
                    'Số tiền cần đạt được (VNĐ) *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _targetAmountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: SavingController.validateTargetAmount,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Ví dụ: 50000000',
                      prefixIcon: Icon(Icons.track_changes_outlined),
                      suffixText: 'VNĐ',
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Monthly Contribution
                  const Text(
                    'Tiền đóng góp hàng tháng (VNĐ) *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _monthlyContributionController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: (val) {
                      final target =
                          _getParsedDouble(_targetAmountController.text);
                      return SavingController.validateMonthlyContribution(
                        val,
                        targetAmount: target,
                      );
                    },
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Ví dụ: 3000000',
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                      suffixText: 'VNĐ',
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Interest Rate & Target Date Row
                  Row(
                    children: [
                      // Interest Rate
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lãi suất (%/năm) *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _interestRateController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'),
                                ),
                              ],
                              validator: SavingController.validateInterestRate,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: '0.0',
                                prefixIcon: Icon(Icons.percent_rounded),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Target Date Picker
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ngày hoàn thành *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _pickTargetDate,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.borderColor,
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 18,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Editing Fields: Current Amount & Status
                  if (widget.isEditing) ...[
                    const SizedBox(height: 18),
                    const Text(
                      'Số tiền đã tích lũy hiện có (VNĐ)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _currentAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: '0',
                        prefixIcon: Icon(Icons.savings_outlined),
                        suffixText: 'VNĐ',
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      'Trạng thái mục tiêu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'ACTIVE',
                          child: Text('Đang tiến hành (ACTIVE)'),
                        ),
                        DropdownMenuItem(
                          value: 'COMPLETED',
                          child: Text('Đã hoàn thành (COMPLETED)'),
                        ),
                        DropdownMenuItem(
                          value: 'CANCELLED',
                          child: Text('Đã hủy (CANCELLED)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _status = val);
                        }
                      },
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Submit Button
                  ListenableBuilder(
                    listenable: widget.controller,
                    builder: (context, _) {
                      return AppButton(
                        text: widget.isEditing
                            ? 'Lưu thay đổi'
                            : 'Thêm mục tiêu',
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
}
