import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';


class AddIncomeFormCard extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController amountController;
  final TextEditingController sourceController;
  final TextEditingController dateController;
  final TextEditingController descriptionController;
  final String? selectedIncomeType;
  final ValueChanged<String?> onIncomeTypeChanged;
  final VoidCallback onPickDate;
  final Map<String, String> serverErrors;

  const AddIncomeFormCard({
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
  State<AddIncomeFormCard> createState() => _AddIncomeFormCardState();
}

class _AddIncomeFormCardState extends State<AddIncomeFormCard> {
  static const List _incomeTypes = [
    {'value': 'SALARY', 'label': 'Lương'},
    {'value': 'BUSINESS', 'label': 'Kinh doanh'},
    {'value': 'INVESTMENT', 'label': 'Đầu tư'},
    {'value': 'OTHER', 'label': 'Khác'},
  ];

  @override
  void initState() {
    super.initState();
    widget.descriptionController.addListener(_onDescChanged);
  }

  void _onDescChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.descriptionController.removeListener(_onDescChanged);
    super.dispose();
  }

  Widget _fieldLabel(String title, {bool required = false, String? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              text: title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              children: required
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  : const [],
            ),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _helperText(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final descLength = widget.descriptionController.text.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header khối Thông tin khoản thu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 18,
                    color: AppTheme.primaryDark,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin khoản thu',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Điền chi tiết các khoản thu nhập tài chính định kỳ hoặc phát sinh',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 1. Số tiền (VNĐ)
            _fieldLabel('Số tiền (VNĐ)', required: true),
            TextFormField(
              controller: widget.amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(13),
              ],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 8),
                  child: Text(
                    'đ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryDark,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                errorText: widget.serverErrors['amount'],
              ),
              validator: (value) {
                final raw = (value ?? '').trim();
                if (raw.isEmpty) {
                  return 'Số tiền không được để trống';
                }
                final numVal = int.tryParse(raw);
                if (numVal == null || numVal < 1) {
                  return 'Số tiền phải lớn hơn 0 và không có phần thập phân';
                }
                if (raw.length > 13) {
                  return 'Số tiền tối đa 13 chữ số';
                }
                return null;
              },
            ),
            _helperText(
              'Chỉ chấp nhận số tiền hợp lệ lớn hơn 0',
              icon: Icons.info_outline,
            ),
            const SizedBox(height: 16),

            // 2. Nguồn thu nhập
            _fieldLabel('Nguồn thu nhập', required: true),
            TextFormField(
              controller: widget.sourceController,
              maxLength: 20,
              buildCounter: (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
              decoration: InputDecoration(
                hintText: 'Nhập nguồn thu nhập (vd: Lương công ty)',
                suffixIcon: const Icon(
                  Icons.edit_note_outlined,
                  color: AppTheme.textMuted,
                ),
                errorText: widget.serverErrors['source'],
              ),
              validator: (value) {
                final trimmed = (value ?? '').trim();
                if (trimmed.isEmpty) {
                  return 'Nguồn thu nhập không được để trống';
                }
                if (trimmed.length < 2) {
                  return 'Tối thiểu 2 ký tự mô tả nguồn nhận';
                }
                if (trimmed.length > 20) {
                  return 'Tên nguồn thu nhập không được quá 20 ký tự';
                }
                return null;
              },
            ),
            _helperText('Tối thiểu 2 ký tự mô tả nguồn nhận'),
            const SizedBox(height: 16),

            // 3. Loại thu nhập
            _fieldLabel('Loại thu nhập', required: true),
            DropdownButtonFormField<String>(
              value: widget.selectedIncomeType,
              hint: const Text(
                'Chọn loại thu nhập',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.textMuted,
              ),
              items: _incomeTypes
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item['value'],
                      child: Text(item['label']!),
                    ),
                  )
                  .toList(),
              onChanged: widget.onIncomeTypeChanged,
              decoration: InputDecoration(
                errorText: widget.serverErrors['income_type'],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng chọn loại thu nhập';
                }
                return null;
              },
            ),
            _helperText('Phân loại chính xác giúp tính điểm tín dụng chuẩn hơn'),
            const SizedBox(height: 16),

            // 4. Ngày nhận (hiển thị MM/DD/YYYY như mẫu, gửi YYYY-MM-DD cho API)
            _fieldLabel('Ngày nhận', required: true),
            TextFormField(
              controller: widget.dateController,
              readOnly: true,
              onTap: widget.onPickDate,
              decoration: InputDecoration(
                hintText: '11/18/2026',
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: widget.onPickDate,
                ),
                errorText: widget.serverErrors['transaction_date'],
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Ngày giao dịch không được để trống';
                }
                return null;
              },
            ),
            _helperText('Ngày ghi nhận dòng tiền vào tài khoản'),
            const SizedBox(height: 16),

            // 5. Ghi chú (Tùy chọn)
            _fieldLabel(
              'Ghi chú (Tùy chọn)',
              trailing: '$descLength/200',
            ),
            TextFormField(
              controller: widget.descriptionController,
              maxLines: 3,
              maxLength: 200,
              buildCounter: (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
              decoration: InputDecoration(
                hintText: 'Thêm ghi chú chi tiết nếu có...',
                alignLabelWithHint: true,
                errorText: widget.serverErrors['description'],
              ),
              validator: (value) {
                if ((value ?? '').length > 255) {
                  return 'Mô tả không được quá 255 ký tự';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}