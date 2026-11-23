
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/expense_model.dart';

class AddExpenseFormCard extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController amountController;
  final TextEditingController dateController;
  final TextEditingController noteController;
  final List<ExpenseCategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onPickDate;
  final Map<String, String> serverErrors;

  const AddExpenseFormCard({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.amountController,
    required this.dateController,
    required this.noteController,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.onPickDate,
    this.serverErrors = const {},
  });

  @override
  State<AddExpenseFormCard> createState() => _AddExpenseFormCardState();
}

class _AddExpenseFormCardState extends State<AddExpenseFormCard> {
  @override
  void initState() {
    super.initState();
    widget.amountController.addListener(_refresh);
    widget.noteController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.amountController.removeListener(_refresh);
    widget.noteController.removeListener(_refresh);
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

  Widget _fieldHeader(
    String label, {
    bool required = false,
    String? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
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
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final digits =
        widget.amountController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final noteLength = widget.noteController.text.characters.length;

    final hasSelectedCategory = widget.categories.any(
      (category) => category.id == widget.selectedCategoryId,
    );

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(
                Icons.add_circle,
                size: 16,
                color: AppTheme.primaryDark,
              ),
              SizedBox(width: 6),
              Text(
                'GHI NHẬN GIAO DỊCH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryDark,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          const Text(
            'Nhập chính xác các khoản thanh toán để cập nhật tỷ lệ tín dụng và hạn mức chi tiêu tháng.',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 16),

          // Tên giao dịch
          _fieldHeader(
            'Tên giao dịch',
            required: true,
            trailing: 'Bắt buộc',
          ),

          TextFormField(
            controller: widget.titleController,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary,
            ),
            decoration: const InputDecoration(
              filled: true,
              fillColor: AppTheme.cardColor,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              hintText: 'Nhập tên giao dịch (vd: Tiền trọ, Đi siêu thị...)',
              hintStyle: TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
              suffixIcon: Icon(
                Icons.edit_note_outlined,
                size: 18,
                color: AppTheme.textSecondary,
              ),
            ).copyWith(
              errorText: widget.serverErrors['title'],
            ),
            validator: (val) {
              if ((val ?? '').trim().isEmpty) {
                return 'Vui lòng nhập tên giao dịch';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Danh mục chi tiêu
          _fieldHeader(
            'Danh mục chi tiêu',
            required: true,
            trailing: 'Phân loại ví',
          ),

          DropdownButtonFormField<String>(
            value: hasSelectedCategory
                ? widget.selectedCategoryId
                : null,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.textSecondary,
            ),
            hint: Text(
              widget.categories.isEmpty
                  ? 'Chưa có danh mục'
                  : 'Chọn danh mục phù hợp',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
            items: widget.categories.map((category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Text(
                  category.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: widget.categories.isEmpty
                ? null
                : widget.onCategoryChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.cardColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.category_outlined,
                  size: 16,
                  color: AppTheme.primaryDark,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 36,
              ),
              errorText: widget.serverErrors['category'] ??
                  widget.serverErrors['category_id'],
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Bạn chưa chọn danh mục chi tiêu';
              }
              return null;
            },
          ),

          if (widget.categories.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                'Không có danh mục để chọn. Vui lòng kiểm tra kết nối API.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.errorColor,
                ),
              ),
            ),

          const SizedBox(height: 14),

          // Số tiền
          _fieldHeader(
            'Số tiền (VNĐ)',
            required: true,
            trailing: 'Tối thiểu: 1 đ',
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.serverErrors['amount'] != null
                    ? AppTheme.errorColor
                    : AppTheme.borderColor,
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'đ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryDark,
                    decoration: TextDecoration.underline,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextFormField(
                    controller: widget.amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(13),
                    ],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: 'Nhập số tiền',
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textMuted,
                      ),
                      suffixText: 'VNĐ',
                      suffixStyle: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      errorText: widget.serverErrors['amount'],
                    ),
                    validator: (val) {
                      final raw = (val ?? '').trim();

                      if (raw.isEmpty) {
                        return 'Số tiền không được để trống';
                      }

                      final n = int.tryParse(raw);

                      if (n == null || n < 1) {
                        return 'Số tiền phải lớn hơn 0';
                      }

                      return null;
                    },
                  ),
                ),

                IconButton(
                  onPressed: () {
                    widget.amountController.clear();
                  },
                  icon: const Icon(
                    Icons.backspace_outlined,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          Text(
            widget.serverErrors['amount'] ??
                'Số tiền hiện tại: ${_formatAmountPreview(digits)} đ',
            style: TextStyle(
              fontSize: 11,
              color: widget.serverErrors['amount'] != null
                  ? AppTheme.errorColor
                  : AppTheme.textSecondary,
            ),
          ),

          const SizedBox(height: 14),

          // Ngày chi tiêu
          _fieldHeader(
            'Ngày chi tiêu',
            required: true,
            trailing: 'Chọn ngày',
          ),

          TextFormField(
            controller: widget.dateController,
            readOnly: true,
            onTap: widget.onPickDate,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.cardColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              suffixIcon: const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppTheme.primaryDark,
              ),
              errorText: widget.serverErrors['transaction_date'],
            ),
            validator: (val) {
              if ((val ?? '').trim().isEmpty) {
                return 'Ngày giao dịch không được để trống';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Ghi chú
          _fieldHeader(
            'Ghi chú (Tùy chọn)',
            trailing: '$noteLength/255',
          ),

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
            ),
            decoration: const InputDecoration(
              filled: true,
              fillColor: AppTheme.cardColor,
              contentPadding: EdgeInsets.all(14),
              hintText: 'Thêm ghi chú chi tiết nếu cần...',
              hintStyle: TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ).copyWith(
              errorText: widget.serverErrors['description'],
            ),
          ),

          const SizedBox(height: 14),

          // Banner thông tin
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.trending_up,
                  size: 18,
                  color: AppTheme.primaryDark,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Giao dịch này sẽ được phản ánh trực tiếp vào báo cáo thói quen chi tiêu tín dụng CIC cá nhân của bạn.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      height: 1.35,
                    ),
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
