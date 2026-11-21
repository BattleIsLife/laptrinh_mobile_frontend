import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/income_controller.dart';
import '../models/income_model.dart';
import 'components/edit_income_form_card.dart';

class EditIncomeView extends StatefulWidget {
  final IncomeModel income;
  final IncomeController? controller;

  const EditIncomeView({
    super.key,
    required this.income,
    this.controller,
  });

  @override
  State<EditIncomeView> createState() => _EditIncomeViewState();
}

class _EditIncomeViewState extends State<EditIncomeView> {
  late final IncomeController _controller;
  late final bool _ownsController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _sourceController;
  late final TextEditingController _dateController;
  late final TextEditingController _descriptionController;

  late DateTime _selectedDate;
  String? _selectedIncomeType;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? IncomeController();

    final cleanAmount =
        double.tryParse(widget.income.amount.replaceAll(',', ''))
                ?.truncate()
                .toString() ??
            widget.income.amount.replaceAll(RegExp(r'[^0-9]'), '');

    _amountController = TextEditingController(text: cleanAmount);
    _sourceController = TextEditingController(text: widget.income.source);
    _descriptionController =
        TextEditingController(text: widget.income.description ?? '');

    final normalizedType = widget.income.incomeType.toUpperCase();
    const validTypes = {'SALARY', 'BUSINESS', 'INVESTMENT', 'OTHER'};
    _selectedIncomeType = validTypes.contains(normalizedType) ? normalizedType : 'OTHER';

    _selectedDate = _parseInitialDate(widget.income.transactionDate);
    _dateController = TextEditingController(text: _formatDisplayDate(_selectedDate));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  DateTime _parseInitialDate(String raw) {
    final trimmed = raw.trim();
    // Hỗ trợ YYYY-MM-DD hoặc DD/MM/YYYY
    if (trimmed.contains('-')) {
      final parts = trimmed.split('-');
      if (parts.length == 3) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (y != null && m != null && d != null) {
          return DateTime(y, m, d);
        }
      }
    } else if (trimmed.contains('/')) {
      final parts = trimmed.split('/');
      if (parts.length == 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
    }
    return DateTime(2026, 11, 5);
  }

  /// Hiển thị theo mẫu: DD/MM/YYYY
  String _formatDisplayDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd/$mm/$yyyy';
  }

  /// Gửi API: YYYY-MM-DD
  String _formatApiDate(DateTime date) {
    final yyyy = date.year.toString();
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1901, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDisplayDate(picked);
      });
    }
  }

  Future<void> _handleSaveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await _controller.updateIncome(
      widget.income.id,
      amount: _amountController.text,
      source: _sourceController.text,
      incomeType: _selectedIncomeType!,
      transactionDate: _formatApiDate(_selectedDate),
      description: _descriptionController.text,
      refreshMonth: _selectedDate.month,
      refreshYear: _selectedDate.year,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật khoản thu nhập thành công'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop(true);
    } else if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giao dịch này?'),
        content: const Text(
          'Khoản thu nhập sẽ bị xóa khỏi danh sách và thống kê tháng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final deleted = await _controller.removeIncome(
      widget.income.id,
      currentMonth: _selectedDate.month,
      currentYear: _selectedDate.year,
    );

    if (!mounted) return;
    if (deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa khoản thu nhập'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop(true);
    } else if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _handleCancel() {
    _controller.clearFormErrors();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: _handleCancel,
        ),
        title: const Text('Điều Chỉnh Khoản Thu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: const Icon(
                Icons.person,
                size: 18,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EditIncomeFormCard(
                  formKey: _formKey,
                  amountController: _amountController,
                  sourceController: _sourceController,
                  dateController: _dateController,
                  descriptionController: _descriptionController,
                  selectedIncomeType: _selectedIncomeType,
                  onIncomeTypeChanged: (val) {
                    setState(() => _selectedIncomeType = val);
                  },
                  onPickDate: _pickDate,
                  serverErrors: _controller.fieldErrors,
                ),
                const SizedBox(height: 6),
                AppButton(
                  text: 'Lưu thay đổi',
                  icon: Icons.check_circle_outline,
                  isLoading: _controller.isSubmitting,
                  onPressed: _handleSaveChanges,
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: 'Hủy',
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  textColor: AppTheme.primaryDark,
                  onPressed: _controller.isSubmitting ? null : _handleCancel,
                ),
                const SizedBox(height: 14),
                Center(
                  child: TextButton.icon(
                    onPressed: _controller.isSubmitting ? null : _handleDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: AppTheme.errorColor,
                    ),
                    label: const Text(
                      'Xóa giao dịch này',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.errorBgColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}