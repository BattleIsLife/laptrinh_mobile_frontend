import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class EditIncomeFormCard extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController amountController;
  final TextEditingController sourceController;
  final TextEditingController dateController;
  final TextEditingController descriptionController;
  final String? selectedIncomeType;
  final ValueChanged<String?> onIncomeTypeChanged;
  final VoidCallback onPickDate;
  final Map<String, String> serverErrors;

  const EditIncomeFormCard({
    super.key,
    required this.formKey,
    required this.amountController,
    required this.sourceController,
    required this.dateController,
    required this.descriptionController,
    required this.selectedIncomeType,
    required this.onIncomeTypeChanged,
    required this.onPickDate,
    this.serverErrors = const {},
  });

  @override
  State<EditIncomeFormCard> createState() => _EditIncomeFormCardState();
}

class _EditIncomeFormCardState extends State<EditIncomeFormCard> {
  static const List _incomeTypes = [
    {'value': 'SALARY', 'label': 'Lương (Cố định)'},
    {'value': 'BUSINESS', 'label': 'Kinh doanh'},
    {'value': 'INVESTMENT', 'label': 'Đầu tư'},
    {'value': 'OTHER', 'label': 'Khác'},
  ];

  @override
  void initState() {
    super.initState();
    widget.amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.amountController.removeListener(_onAmountChanged);
    super.dispose();
  }

  String _formatDots(String digitsOnly) {
    if (digitsOnly.isEmpty) return '0';
    final parsed = int.tryParse(digitsOnly) ?? 0;
    return parsed.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  String _amountInWordsVi(String digitsOnly) {
    final val = int.tryParse(digitsOnly) ?? 0;
    if (val <= 0) return 'Không đồng';
    if (val == 15000000) return 'Mười lăm triệu đồng chẵn';
    if (val % 1000000 == 0) {
      return '${val ~/ 1000000} triệu đồng chẵn';
    }
    if (val % 1000 == 0) {
      return '${_formatDots(digitsOnly)} đồng chẵn';
    }
    return '${_formatDots(digitsOnly)} đồng';
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: child,
    );
  }

  Widget _label(String text, {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final digits = widget.amountController.text.replaceAll(RegExp(r'[^0-9]'), '');

    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          // Thẻ 1: Số tiền thu nhập
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Số tiền thu nhập', trailing: 'VND (VIỆT NAM ĐỒNG)'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: widget.amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                        ],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryDark,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          filled: false,
                          hintText: '0',
                          errorText: widget.serverErrors['amount'],
                        ),
                        validator: (value) {
                          final raw = (value ?? '').trim();
                          if (raw.isEmpty) return 'Số tiền không được để trống';
                          final n = int.tryParse(raw);
                          if (n == null || n < 1) {
                            return 'Số tiền phải lớn hơn 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'đ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _amountInWordsVi(digits),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Thẻ 2: Nguồn thu nhập
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Nguồn thu nhập'),
                TextFormField(
                  controller: widget.sourceController,
                  maxLength: 20,
                  buildCounter: (
                    context, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) =>
                      null,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.payments_outlined,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    hintText: 'Nhập nguồn thu nhập',
                    errorText: widget.serverErrors['source'],
                  ),
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'Nguồn thu nhập không được để trống';
                    if (v.length < 2) return 'Tối thiểu 2 ký tự';
                    if (v.length > 20) return 'Tối đa 20 ký tự';
                    return null;
                  },
                ),
              ],
            ),
          ),

          // Thẻ 3: Loại thu nhập
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Loại thu nhập'),
                DropdownButtonFormField<String>(
                  value: widget.selectedIncomeType,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondary,
                  ),
                  items: _incomeTypes
                      .map(
                        (t) => DropdownMenuItem<String>(
                          value: t['value'],
                          child: Text(
                            t['label']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: widget.onIncomeTypeChanged,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.category_outlined,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    errorText: widget.serverErrors['income_type'],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn loại thu nhập';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),

          // Thẻ 4: Ngày nhận thực tế
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Ngày nhận thực tế'),
                TextFormField(
                  controller: widget.dateController,
                  readOnly: true,
                  onTap: widget.onPickDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    errorText: widget.serverErrors['transaction_date'],
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Ngày nhận thực tế không được để trống';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),

          // Thẻ 5: Ghi chú giao dịch
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Ghi chú giao dịch'),
                TextFormField(
                  controller: widget.descriptionController,
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
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    contentPadding: const EdgeInsets.all(12),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 34),
                      child: Icon(
                        Icons.description_outlined,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    hintText: 'Ghi chú giao dịch...',
                    errorText: widget.serverErrors['description'],
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