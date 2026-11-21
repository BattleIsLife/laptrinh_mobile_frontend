import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/expense_controller.dart';
import 'components/add_expense_form_card.dart';

class AddExpenseView extends StatefulWidget {
  final ExpenseController? controller;

  const AddExpenseView({super.key, this.controller});

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  late final ExpenseController _controller;
  late final bool _ownsController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  late final TextEditingController _dateController;

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ExpenseController();
    _dateController = TextEditingController(text: _formatDisplayDate(_selectedDate));
    _controller.loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  String _formatDisplayDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$mm/$dd/$yyyy';
  }

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

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final selectedCat = _controller.categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
    );

    final created = await _controller.createExpense(
      amount: _amountController.text,
      categoryId: selectedCat.id,
      categoryName: selectedCat.name,
      transactionDate: _formatApiDate(_selectedDate),
      title: _titleController.text,
      description: _noteController.text,
      refreshMonth: _selectedDate.month,
      refreshYear: _selectedDate.year,
    );

    if (!mounted) return;
    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo giao dịch chi tiêu thành công'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop(created);
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
        title: const Text('Thêm Chi Tiêu'),
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
                AddExpenseFormCard(
                  formKey: _formKey,
                  titleController: _titleController,
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
                  text: 'Lưu chi tiêu',
                  icon: Icons.save_outlined,
                  isLoading: _controller.isSubmitting,
                  onPressed: _handleSave,
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: 'Hủy',
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  textColor: AppTheme.primaryDark,
                  onPressed: _controller.isSubmitting ? null : _handleCancel,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}