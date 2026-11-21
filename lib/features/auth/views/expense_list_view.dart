import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/expense_controller.dart';
import '../models/expense_model.dart';
import 'add_expense_view.dart';
import 'edit_expense_view.dart';
class ExpenseListView extends StatefulWidget {
  const ExpenseListView({super.key});

  @override
  State<ExpenseListView> createState() => _ExpenseListViewState();
}

class _ExpenseListViewState extends State<ExpenseListView> {
  final ExpenseController _controller = ExpenseController();
  int _selectedMonth = 11;
  int _selectedYear = 2026;

  @override
  void initState() {
    super.initState();
    _controller.loadExpenseData(month: _selectedMonth, year: _selectedYear);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  String _formatDisplayDate(String rawDate) {
    final trimmed = rawDate.trim();
    final parts = trimmed.split('-');
    if (parts.length == 3 && parts[0].length == 4) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return trimmed;
  }

  IconData _categoryIcon(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('nhà') || lower.contains('điện')) {
      return Icons.apartment_outlined;
    }
    if (lower.contains('ăn') || lower.contains('phở') || lower.contains('cafe')) {
      return Icons.restaurant_outlined;
    }
    if (lower.contains('đi lại') || lower.contains('di chuyển') || lower.contains('xe')) {
      return Icons.directions_car_outlined;
    }
    if (lower.contains('mua sắm')) {
      return Icons.shopping_bag_outlined;
    }
    if (lower.contains('giải trí')) {
      return Icons.sports_esports_outlined;
    }
    return Icons.receipt_long_outlined;
  }

  Future<void> _onPickMonthYear() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth, 1),
      firstDate: DateTime(1901, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      helpText: 'Chọn tháng/năm xem chi tiêu',
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedMonth = picked.month;
        _selectedYear = picked.year;
      });
      await _controller.loadExpenseData(
        month: _selectedMonth,
        year: _selectedYear,
      );
    }
  }

  Future<void> _openAddExpense() async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => AddExpenseView(controller: _controller),
      ),
    );

    if (!mounted || result == null) return;
    setState(() {});
  }
Future<void> _openEditExpense(ExpenseModel item) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => EditExpenseView(
          expense: item,
          controller: _controller,
        ),
      ),
    );

    if (!mounted || result == null) return;
    setState(() {});
  }
  Future<void> _onItemAction(ExpenseModel item) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppTheme.primaryDark),
              title: const Text('Sửa giao dịch chi tiêu'),
              onTap: () => Navigator.of(ctx).pop('edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
              title: const Text(
                'Xóa giao dịch chi tiêu',
                style: TextStyle(color: AppTheme.errorColor),
              ),
              onTap: () => Navigator.of(ctx).pop('delete'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;
    if (action == 'delete') {
      final ok = await _controller.deleteExpense(
        item.id,
        month: _selectedMonth,
        year: _selectedYear,
      );
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa giao dịch chi tiêu thành công'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (_controller.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_controller.errorMessage!),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } else if (action == 'edit') {
        await _openEditExpense(item);
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
        title: const Text('Danh Sách Chi Tiêu'),
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
          final stat = _controller.statistic;
          final essentialRate =
              (double.tryParse(stat.essentialRate) ?? 80).clamp(0, 100) / 100;
          final discretionaryPercent =
              (100 - (essentialRate * 100)).round().clamp(0, 100);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hàng chọn tháng + nút Thêm mới
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: _onPickMonthYear,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
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
                    ),
                    SizedBox(
                      width: 124,
                      height: 38,
                      child: AppButton(
                        text: 'Thêm mới',
                        icon: Icons.add,
                        height: 38,
                        onPressed: _openAddExpense,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Card Tổng chi tiêu tháng + Biểu đồ + Cơ cấu + Thiết yếu/Tùy ý
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
                            'Tổng chi tiêu tháng',
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
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatMoney(stat.totalExpense),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Xu hướng chi tiêu (Tháng $_selectedMonth)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const Text(
                            'Cao điểm: 10/11',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 115,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _ExpenseChartPainter(
                            lineColor: AppTheme.primaryColor,
                            peakColor: AppTheme.errorColor,
                            points: stat.points,
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
                            'Số giao dịch: ${_controller.totalItems} giao dịch',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: AppTheme.borderColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cơ cấu chi tiêu',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '${stat.structure.length} nhóm',
                            style: const TextStyle(
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
                        children: stat.structure.entries.map((e) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryDark,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${e.key} ${e.value}%',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: essentialRate,
                          minHeight: 7,
                          backgroundColor:
                              AppTheme.primaryColor.withValues(alpha: 0.12),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thiết yếu: ${(essentialRate * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Tùy ý: $discretionaryPercent%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Tiêu đề danh sách
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Danh sách chi tiêu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Nhấn để Sửa / Xóa',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (_controller.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  ..._controller.expenses.map((item) {
                    final title = (item.description?.isNotEmpty == true)
                        ? item.description!
                        : item.categoryName;

                    return InkWell(
                      onTap: () => _onItemAction(item),
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
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _categoryIcon(item.categoryName),
                                color: AppTheme.primaryDark,
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor
                                              .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item.categoryName,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primaryDark,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatDisplayDate(item.transactionDate),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '-${_formatMoney(item.amount)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.errorColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Icon(
                                  Icons.more_horiz,
                                  size: 16,
                                  color: AppTheme.textMuted,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          color: AppTheme.surfaceColor,
          child: AppButton(
            text: 'Thêm chi tiêu mới',
            icon: Icons.add_circle_outline,
            height: 46,
            onPressed: _openAddExpense,
          ),
        ),
      ),
    );
  }
}

class _ExpenseChartPainter extends CustomPainter {
  final Color lineColor;
  final Color peakColor;
  final List<ExpenseChartPoint> points;

  _ExpenseChartPainter({
    required this.lineColor,
    required this.peakColor,
    required this.points,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final topPad = 12.0;
    final bottomPad = 20.0;
    final h = (size.height - topPad - bottomPad).clamp(16.0, size.height);

    final gridPaint = Paint()
      ..color = AppTheme.borderColor.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (int i = 0; i < 3; i++) {
      final y = topPad + (h / 2) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final rawPoints = <Offset>[
      Offset(0.02 * size.width, topPad + h * 0.65),
      Offset(0.22 * size.width, topPad + h * 0.30),
      Offset(0.42 * size.width, topPad + h * 0.52),
      Offset(0.62 * size.width, topPad + h * 0.28),
      Offset(0.81 * size.width, topPad + h * 0.48),
      Offset(0.98 * size.width, topPad + h * 0.68),
    ];

    final path = Path()..moveTo(rawPoints.first.dx, rawPoints.first.dy);
    for (int i = 0; i < rawPoints.length - 1; i++) {
      final p0 = rawPoints[i];
      final p1 = rawPoints[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(rawPoints.last.dx, topPad + h)
      ..lineTo(rawPoints.first.dx, topPad + h)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.16),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, topPad, size.width, h));
    canvas.drawPath(fillPath, fillPaint);

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );

    for (int i = 1; i < rawPoints.length - 1; i++) {
      final pt = rawPoints[i];
      final isPeak = i == 3;
      canvas.drawCircle(pt, 4.5, Paint()..color = isPeak ? peakColor : lineColor);
      canvas.drawCircle(pt, 2.0, Paint()..color = Colors.white);
    }

    const labels = ['01/11', '05/11', '10/11', '15/11', '20/11', '30/11'];
    final stepX = size.width / (labels.length - 1);
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < labels.length; i++) {
      tp.text = TextSpan(
        text: labels[i],
        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
      );
      tp.layout();
      final dx = (i * stepX - tp.width / 2).clamp(
        0.0,
        (size.width - tp.width).clamp(0.0, size.width),
      );
      tp.paint(canvas, Offset(dx, size.height - 14));
    }
  }

  @override
  bool shouldRepaint(covariant _ExpenseChartPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor ||
      oldDelegate.peakColor != peakColor ||
      oldDelegate.points != points;
}