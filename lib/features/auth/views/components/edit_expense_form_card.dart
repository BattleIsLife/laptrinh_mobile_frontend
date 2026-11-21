import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/expense_model.dart';

class EditExpenseFormCard extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController amountController;
  final TextEditingController dateController;
  final TextEditingController noteController;
  final List<ExpenseCategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onPickDate;
  final String helperHint;
  final Map<String, String> serverErrors;

  const EditExpenseFormCard({
    super.key,
    required this.formKey,
    required this.amountController,
    required this.dateController,
    required this.noteController,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.onPickDate,
    this.helperHint = 'Hạn mức danh mục còn lại: 6.000.000 đ trong tháng',
    this.serverErrors = const {},
  });

  @override
  State<EditExpenseFormCard> createState() => _EditExpenseFormCardState();
}

class _EditExpenseFormCardState extends State<EditExpenseFormCard> {
  @override
  void initState() {
    super.initState();
    widget.amountController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.amountController.removeListener(_refresh);
    super.dispose();
  }

  String _formatAmountPreview(String digitsOnly) {
    if (digitsOnly.isEmpty) return '0';
    final parsed = int.tryParse(digitsOnly) ?? 0;
    return parsed.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: child,
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
          children: required
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                ]
              : const [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final digits =
        widget.amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amountError = widget.serverErrors['amount'];
    final categoryError =
        widget.serverErrors['category'] ?? widget.serverErrors['category_id'];
    final dateError = widget.serverErrors['transaction_date'];
    final noteError = widget.serverErrors['description'];

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Số tiền chi tiêu
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Số tiền chi tiêu', required: true),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: amountError != null
                          ? AppTheme.errorColor
                          : AppTheme.borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'đ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryDark,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Text(
                              _formatAmountPreview(digits),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: digits.isEmpty
                                    ? AppTheme.textSecondary
                                    : AppTheme.primaryDark,
                              ),
                            ),
                            Opacity(
                              opacity: 0.0,
                              child: TextFormField(
                                controller: widget.amountController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(13),
                                ],
                                validator: (val) {
                                  final raw = (val ?? '').trim();
                                  if (raw.isEmpty) {
                                    return 'Số tiền không được để trống';
                                  }
                                  final parsed = int.tryParse(raw);
                                  if (parsed == null || parsed < 1) {
                                    return 'Số tiền tối thiểu là 1';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => widget.amountController.clear(),
                        borderRadius: BorderRadius.circular(20),
                        child: const Icon(
                          Icons.cancel,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  amountError ?? widget.helperHint,
                  style: TextStyle(
                    fontSize: 11,
                    color: amountError != null
                        ? AppTheme.errorColor
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Danh mục
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Danh mục', required: true),
                DropdownButtonFormField<String>(
                  value: widget.selectedCategoryId,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: AppTheme.textPrimary,
                  ),
                  items: widget.categories
                      .map(
                        (c) => DropdownMenuItem<String>(
                          value: c.id,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.home_outlined,
                                size: 18,
                                color: AppTheme.primaryDark,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                c.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: widget.onCategoryChanged,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.primaryColor.withValues(alpha: 0.06),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    errorText: categoryError,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Bạn chưa chọn danh mục chi tiêu';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Ngày chi tiêu
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Ngày chi tiêu', required: true),
                TextFormField(
                  controller: widget.dateController,
                  readOnly: true,
                  onTap: widget.onPickDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.primaryColor.withValues(alpha: 0.06),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    errorText: dateError,
                  ),
                  validator: (val) {
                    final raw = (val ?? '').trim();
                    if (raw.isEmpty) {
                      return 'Ngày giao dịch không được để trống';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Ghi chú bổ sung
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Ghi chú bổ sung'),
                TextFormField(
                  controller: widget.noteController,
                  maxLines: 3,
                  maxLength: 255,
                  buildCounter: (
                    context, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) =>
                      null,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.primaryColor.withValues(alpha: 0.06),
                    contentPadding: const EdgeInsets.all(12),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 36),
                      child: Icon(
                        Icons.description_outlined,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    hintText: 'Nhập ghi chú (tối đa 255 ký tự)...',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                    errorText: noteError,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}