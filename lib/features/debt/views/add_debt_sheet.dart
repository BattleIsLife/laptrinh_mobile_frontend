import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/debt.dart';

class AddDebtSheet extends StatefulWidget {
  const AddDebtSheet({super.key});
  @override
  State<AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<AddDebtSheet> {
  final _formKey = GlobalKey<FormState>; //giúp gọi lệnh kiểm tra tất cả các ô nhập liệu mà ko cần kiểm tra từng ô
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime(2050);
  final List<String> _bankOptions = [
    'VPBank',
    'Home Credit',
    'Vietcombank',
    'FE Credit',
  ];
  String _selectedLender = 'VPBank';
  String _selectedDebtType = 'unsecured';
  final _totalAmountCtrl = TextEditingController(text: '100000000');
  final _remainingAmountCtrl = TextEditingController(text: '75000000');
  final _monthlyPaymentCtrl = TextEditingController(text: '3500000');
  final _interestRateCtrl = TextEditingController(text: '12.5');
  void _submitForm() {}
  Future<void> _pickDate({
    required DateTime initialDate,
    required ValueChanged<DateTime>
    onDateSelected, // Hàm callback trả về ngày người dùng vừa chọn})
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate, // Ngày hiển thị mặc định khi mở lịch lên
      firstDate: DateTime(
        2015,
      ), // Ngày nhỏ nhất người dùng được phép chọn (ví dụ năm 2015)
      lastDate: DateTime(2050),
      helpText: 'CHỌN NGÀY',
      cancelText: 'HỦY',
      confirmText: 'CHỌN',
    );
    if (picked != null) {
      onDateSelected(picked); // Truyền ngày mới về để cập nhật State
    }
  }

  Widget _buildDateField({
    required String label,
    required DateTime selectedDate,
    required VoidCallback onTap,
  }) {
    // Format ngày tháng năm thành dạng dd/MM/yyyy
    final String formattedDate =
        '${selectedDate.day.toString().padLeft(2, '0')}/'
        '${selectedDate.month.toString().padLeft(2, '0')}/'
        '${selectedDate.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap, // Khi bấm vào ô này sẽ kích hoạt hàm mở lịch ở Bước 1
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.post_add_rounded,
                      color: Color(0xFF1E40AF),
                      size: 32,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thêm khoản nợ mới',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Nhập thông tin hợp đồng vay để hệ thống tự động phân tích tài chính.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tổ chức cho vay / Ngân hàng *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField(
                value: _selectedLender,
                items: _bankOptions.map((bank) {
                  return DropdownMenuItem(value: bank, child: Text(bank));
                }).toList(),
                onChanged: (val) => setState(() => _selectedLender = val!),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text('Vay tín chấp'),
                    selected: _selectedDebtType == 'unsecured', //biến kiểu bool quyết định thẻ này được chọn ko
                    onSelected: (_) =>
                        setState(() => _selectedDebtType = 'unsecured'),
                  ),
                  ChoiceChip(
                    label: const Text('Vay trả góp'),
                    selected: _selectedDebtType == 'installment',
                    onSelected: (_) =>
                        setState(() => _selectedDebtType = 'installment'),
                  ),
                  ChoiceChip(
                    label: const Text('Vay thế chấp'),
                    selected: _selectedDebtType == 'mortgage',
                    onSelected: (_) =>
                        setState(() => _selectedDebtType = 'mortgage'),
                  ),
                  ChoiceChip(
                    label: const Text('Vay cá nhân'),
                    selected: _selectedDebtType == 'personal',
                    onSelected: (_) =>
                        setState(() => _selectedDebtType = 'personal'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Tổng số tiền vay ban đầu (Gốc) *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _totalAmountCtrl, // dùng để lưu lại giá trị biến
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  suffixText: 'VND',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Dư nợ còn lại *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _remainingAmountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  suffixText: 'đ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Trả mỗi tháng *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _monthlyPaymentCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  suffixText: 'đ/th',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lãi suất năm (%/năm)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _interestRateCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  suffixText: '%/năm',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'Ngày bắt đầu',
                      selectedDate: _startDate,
                      onTap: () {
                        _pickDate(
                          initialDate: _startDate,
                          onDateSelected: (newDate) {
                            setState(() {
                              _startDate = newDate; // Cập nhật lại ngày bắt đầu khi người dùng chọn xong
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(
                      label: 'Dự kiến kết thúc',
                      selectedDate: _endDate,
                      onTap: () {
                        _pickDate(
                          initialDate: _endDate,
                          onDateSelected: (newDate) {
                            setState(() {
                              _endDate = newDate;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 7,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text(
                        'Lưu khoản nợ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
