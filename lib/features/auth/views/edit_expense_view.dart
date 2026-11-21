import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/expense_controller.dart';
import '../models/expense_model.dart';
import 'components/edit_expense_form_card.dart';

class EditExpenseView extends StatefulWidget {
  final ExpenseModel expense;
  final ExpenseController? controller;

  const EditExpenseView({
    super.key,
    required this.expense,
    this.controller,
  });

  @override
  State<EditExpenseView> createState() => _EditExpenseViewState();
}

class _EditExpenseViewState extends State<EditExpenseView> {
  late final ExpenseController _controller;
  late final bool _ownsController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _dateController;
  late final TextEditingController _noteController;

  late DateTime _selectedDate;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ExpenseController();

    final initialDigits = _extractIntegerDigits(widget.expense.amount);
    _amountController = TextEditingController(text: initialDigits);

    _selectedDate = _parseInitialDate(widget.expense.transactionDate);
    _dateController =
        TextEditingController(text: _formatDisplayDate(_selectedDate));
    _noteController =
        TextEditingController(text: widget.expense.description ?? '');

    _controller.loadCategories().then((_) {
      if (!mounted) return;
      setState(() {
        _selectedCategoryId = _resolveInitialCategoryId();
      });
    });
    _selectedCategoryId = _resolveInitialCategoryId();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  String _extractIntegerDigits(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final dotIndex = trimmed.indexOf('.');
    final intPart = dotIndex == -1 ? trimmed : trimmed.substring(0, dotIndex);
    return intPart.replaceAll(RegExp(r'[^0-9]'), '');
  }

  DateTime _parseInitialDate(String raw) {
    final parts = raw.trim().split('-');
    if (parts.length == 3 && parts[0].length == 4) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null && y > 1900) {
        return DateTime(y, m, d);
      }
    }
    return DateTime.now();
  }

  String _formatDisplayDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd/$mm/$yyyy';
  }

  String _formatApiDate(DateTime date) {
    final yyyy = date.year.toString();
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  String? _resolveInitialCategoryId() {
    final cats = _controller.categories;
    if (cats.isEmpty) return null;

    if (widget.expense.categoryId != null &&
        cats.any((c) => c.id == widget.expense.categoryId)) {
      return widget.expense.categoryId;
    }

    final matchedByName = cats.where(
      (c) => c.name.toLowerCase() == widget.expense.categoryName.toLowerCase(),
    );
    if (matchedByName.isNotEmpty) {
      return matchedByName.first.id;
    }

    return cats.first.id;
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

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final cats = _controller.categories;
    final selectedCat = cats.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => cats.first,
    );

    final updated = await _controller.updateExpense(
      id: widget.expense.id,
      amount: _amountController.text,
      categoryId: selectedCat.id,
      categoryName: selectedCat.name,
      transactionDate: _formatApiDate(_selectedDate),
      description: _noteController.text,
      refreshMonth: _selectedDate.month,
      refreshYear: _selectedDate.year,
    );

    if (!mounted) return;
    if (updated != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật giao dịch chi tiêu thành công'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop(updated);
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
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa khoản chi tiêu này không?',
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

    final deleted = await _controller.deleteExpense(
      widget.expense.id,
      month: _selectedDate.month,
      year: _selectedDate.year,
    );

    if (!mounted) return;
    if (deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa giao dịch chi tiêu thành công'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop('deleted');
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
        title: const Text('Điều Chỉnh Khoản Chi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryDark,
              child: const Icon(
                Icons.person_outline,
                size: 18,
                color: Colors.white,
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
                EditExpenseFormCard(
                  formKey: _formKey,
                  amountController: _amountController,
                  dateController: _dateController,
                  noteController: _noteController,
                  categories: _controller.categories,
                  selectedCategoryId: _selectedCategoryId,
                  onCategoryChanged: (val) {
                    setState(() => _selectedCategoryId = val);
                  },
                  onPickDate: _pickDate,
                  serverErrors: _controller.fieldErrors,
                ),
                const SizedBox(height: 18),
                AppButton(
                  text: 'Lưu thay đổi',
                  icon: Icons.save_outlined,
                  isLoading: _controller.isSubmitting,
                  onPressed: _handleSave,
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: 'Hủy bỏ',
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  textColor: AppTheme.primaryDark,
                  onPressed: _controller.isSubmitting ? null : _handleCancel,
                ),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: _controller.isSubmitting ? null : _handleDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppTheme.errorColor,
                  ),
                  label: const Text(
                    'Xóa khoản chi này',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.errorColor,
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