import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/income_controller.dart';
import 'components/add_income_form_card.dart';

class AddIncomeView extends StatefulWidget {
  final IncomeController? controller;

  const AddIncomeView({super.key, this.controller});

  @override
  State<AddIncomeView> createState() => _AddIncomeViewState();
}

class _AddIncomeViewState extends State<AddIncomeView> {
  late final IncomeController _controller;
  late final bool _ownsController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

DateTime _selectedDate = DateTime.now();
  String? _selectedIncomeType;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? IncomeController();
    _dateController.text = _formatDisplayDate(_selectedDate);
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

  /// Hiển thị trên UI giống mẫu: MM/DD/YYYY
  String _formatDisplayDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$mm/$dd/$yyyy';
  }

  /// Gửi API POST api/income/: YYYY-MM-DD
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
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await _controller.createIncome(
      amount: _amountController.text,
      source: _sourceController.text,
      incomeType: _selectedIncomeType!,
      transactionDate: _formatApiDate(_selectedDate),
      description: _descriptionController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo giao dịch thu nhập thành công'),
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
        title: const Text('Thêm Thu Nhập'),
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
                AddIncomeFormCard(
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
                const SizedBox(height: 16),
                AppButton(
                  text: 'Lưu thu nhập',
                  icon: Icons.check_circle_outline,
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