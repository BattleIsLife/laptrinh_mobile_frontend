import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../models/income_model.dart';
import 'add_income_view.dart';
import 'edit_income_view.dart';
class IncomeListView extends StatefulWidget {
  const IncomeListView({super.key});

  @override
  State<IncomeListView> createState() => _IncomeListViewState();
}

class _IncomeListViewState extends State<IncomeListView> {
  final int _selectedMonth = 11;
  final int _selectedYear = 2026;

  final List<IncomeModel> _items = [
    IncomeModel(
      id: 1,
      amount: '15000000.00',
      source: 'Lương tháng',
      incomeType: 'SALARY',
      transactionDate: '05/11/2026',
      description: 'Chuyển khoản định kỳ',
    ),
    IncomeModel(
      id: 2,
      amount: '5000000.00',
      source: 'Làm thêm',
      incomeType: 'BUSINESS',
      transactionDate: '08/11/2026',
      description: 'Khách hàng tự do',
    ),
    IncomeModel(
      id: 3,
      amount: '3000000.00',
      source: 'Thưởng dự án',
      incomeType: 'OTHER',
      transactionDate: '12/11/2026',
      description: 'Đột xuất theo KPI',
    ),
    IncomeModel(
      id: 4,
      amount: '2000000.00',
      source: 'Đầu tư',
      incomeType: 'INVESTMENT',
      transactionDate: '15/11/2026',
      description: 'Lợi tức quỹ định kỳ',
    ),
    
  ];

  final Map<String, String> _structure = const {
    'SALARY': '52',
    'BUSINESS': '24',
    'INVESTMENT': '14',
    'OTHER': '10',
  };

  String _formatMoney(String raw) {
    final clean = raw.replaceAll(',', '').trim();
    final val = double.tryParse(clean) ?? 0;
    final intVal = val.truncate().abs();
    final formatted = intVal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formatted đ';
  }

  String _typeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'SALARY':
        return 'Lương';
      case 'BUSINESS':
        return 'Kinh doanh';
      case 'INVESTMENT':
        return 'Đầu tư';
      default:
        return 'Khác';
    }
  }

  Color _typeColor(String type) {
    switch (type.toUpperCase()) {
      case 'SALARY':
        return AppTheme.primaryColor;
      case 'BUSINESS':
        return AppTheme.accentColor;
      case 'INVESTMENT':
        return AppTheme.primaryDark;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'SALARY':
        return Icons.payments_outlined;
      case 'BUSINESS':
        return Icons.laptop_mac_outlined;
      case 'INVESTMENT':
        return Icons.show_chart;
      default:
        return Icons.workspace_premium_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text('Danh Sách Thu Nhập'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hàng chọn tháng + nút Thêm mới
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: AppTheme.primaryDark,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tháng $_selectedMonth/$_selectedYear',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: AppTheme.primaryDark,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 124,
                  height: 38,
                  child: AppButton(
                    text: 'Thêm mới',
                    icon: Icons.add,
                    height: 38,
                    onPressed: _openAddIncome,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Card Tổng thu nhập + Biểu đồ + Cơ cấu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng thu nhập tháng',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 18,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '25.000.000 đ',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Xu hướng thu nhập (Tháng 11)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        'Cao điểm: 10/11',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 105,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _SimpleChartPainter(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Số giao dịch: ${_items.length} giao dịch',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: AppTheme.borderColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Cơ cấu thu nhập',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '4 nhóm',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _structure.entries.map((e) {
                      final c = _typeColor(e.key);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${_typeLabel(e.key)} ${e.value}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: c,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Tiêu đề lịch sử thu nhập
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Lịch sử thu nhập',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Chạm để quản lý',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Danh sách giao dịch
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final subtitle = item.description?.isNotEmpty == true
                  ? '${item.transactionDate} • ${item.description}'
                  : item.transactionDate;
              return InkWell(
                onTap: () => _openEditIncome(index, item),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _typeIcon(item.incomeType),
                        color: _typeColor(item.incomeType),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.source,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _typeLabel(item.incomeType),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+${_formatMoney(item.amount)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.check_circle_outline,
                              size: 12,
                              color: AppTheme.successColor,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'Hoàn tất',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ));
            }),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          color: AppTheme.surfaceColor,
          child: AppButton(
            text: 'Thêm khoản thu nhập mới',
            icon: Icons.add,
            height: 46,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
            textColor: AppTheme.primaryDark,
            onPressed:_openAddIncome,
          ),
        ),
      ),
    );
  }

  Future<void> _openAddIncome() async {
    final result = await Navigator.of(
      context,
    ).push<dynamic>(MaterialPageRoute(builder: (_) => const AddIncomeView()));

    if (!mounted || result == null) return;

    if (result is IncomeModel) {
      setState(() {
        _items.insert(0, result);
      });
    } else if (result == true) {
      setState(() {});
    }
  }
  Future<void> _openEditIncome(int index, IncomeModel item) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => EditIncomeView(income: item),
      ),
    );

    if (!mounted || result == null) return;

    if (result == 'deleted') {
      setState(() {
        _items.removeAt(index);
      });
    } else if (result is IncomeModel) {
      setState(() {
        _items[index] = result;
      });
    } else if (result == true) {
      setState(() {});
    }
  }
}

class _SimpleChartPainter extends CustomPainter {
  final Color color;

  _SimpleChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final ratios = [0.35, 0.72, 0.45, 0.88, 0.58, 0.25];
    final topPad = 10.0;
    final bottomPad = 18.0;
    final h = (size.height - topPad - bottomPad).clamp(16.0, size.height);
    final stepX = size.width / (ratios.length - 1);

    final path = Path();
    final pts = <Offset>[];
    for (var i = 0; i < ratios.length; i++) {
      final pt = Offset(i * stepX, topPad + h * (1 - ratios[i]));
      pts.add(pt);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );

    for (final pt in pts) {
      canvas.drawCircle(pt, 4, Paint()..color = color);
      canvas.drawCircle(pt, 1.8, Paint()..color = Colors.white);
    }

    const labels = ['01/11', '05/11', '10/11', '15/11', '20/11', '30/11'];
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < labels.length; i++) {
      tp.text = TextSpan(
        text: labels[i],
        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
      );
      tp.layout();
      final dx = (pts[i].dx - tp.width / 2).clamp(
        0.0,
        (size.width - tp.width).clamp(0.0, size.width),
      );
      tp.paint(canvas, Offset(dx, size.height - 14));
    }
  }

  @override
  bool shouldRepaint(covariant _SimpleChartPainter oldDelegate) =>
      oldDelegate.color != color;
      
}
