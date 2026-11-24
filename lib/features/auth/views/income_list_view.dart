import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/income_controller.dart';
import '../models/income_model.dart';
import 'add_income_view.dart';
import 'edit_income_view.dart';

class IncomeListView extends StatefulWidget {
  const IncomeListView({super.key});

  @override
  State<IncomeListView> createState() => _IncomeListViewState();
}

class _IncomeListViewState extends State<IncomeListView> {
  final IncomeController _controller = IncomeController();
  final DateTime _now = DateTime.now();

  final ScrollController _scrollController = ScrollController();

  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();

    _selectedMonth = _now.month;
    _selectedYear = _now.year;

    // Lắng nghe sự kiện cuộn danh sách.
    _scrollController.addListener(_onScroll);

    _controller.loadIncomeData(month: _selectedMonth, year: _selectedYear);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    _controller.dispose();

    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    // Chỉ tải khi người dùng thực sự cuộn xuống.
    if (position.userScrollDirection == ScrollDirection.reverse &&
        position.extentAfter < 200) {
      _controller.loadMoreIncomes(month: _selectedMonth, year: _selectedYear);
    }
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

  String _getPeakIncomeDate(List<IncomeChartPoint> chartData) {
    if (chartData.isEmpty) return 'Chưa có dữ liệu';

    IncomeChartPoint? peakPoint;
    double maxAmount = 0;

    for (final point in chartData) {
      final amount =
          double.tryParse(point.amount.replaceAll(',', '').trim()) ?? 0;

      if (peakPoint == null || amount > maxAmount) {
        maxAmount = amount;
        peakPoint = point;
      }
    }

    if (peakPoint == null || maxAmount <= 0) {
      return 'Chưa có thu nhập';
    }

    final date = DateTime.tryParse(peakPoint.date);

    if (date == null) return 'Chưa có dữ liệu';

    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(String rawDate) {
    final trimmed = rawDate.trim();
    final parts = trimmed.split('-');

    if (parts.length == 3 && parts[0].length == 4) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }

    return trimmed;
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

  Future<void> _onPickMonthYear() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth, 1),
      firstDate: DateTime(1901, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      helpText: 'Chọn tháng/năm xem thu nhập',
      cancelText: 'Hủy',
      confirmText: 'OK',
    );

    if (picked == null || !mounted) return;

    debugPrint('Tháng đã chọn: ${picked.month}/${picked.year}');

    setState(() {
      _selectedMonth = picked.month;
      _selectedYear = picked.year;
    });

    // Khi đổi tháng/năm, tải lại từ page = 0.
    await _controller.loadIncomeData(
      month: _selectedMonth,
      year: _selectedYear,
    );
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
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final stat = _controller.statistic;
          final items = _controller.incomes;
          final structure = stat?.structure ?? const <String, String>{};
          final chartData = stat?.chartData ?? const <IncomeChartPoint>[];
          final totalIncomeText = _formatMoney(stat?.totalIncome ?? '0');

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hàng chọn tháng + nút Thêm mới.
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
                        onPressed: _openAddIncome,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Card Tổng thu nhập + Biểu đồ + Cơ cấu.
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
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
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
                      Text(
                        totalIncomeText,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Xu hướng thu nhập (Tháng $_selectedMonth)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            'Cao điểm: ${_getPeakIncomeDate(chartData)}',
                            style: const TextStyle(
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
                        child: chartData.isEmpty
                            ? const Center(
                                child: Text(
                                  'Chưa có dữ liệu biểu đồ trong tháng này',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              )
                            : CustomPaint(
                                painter: _SimpleChartPainter(
                                  color: AppTheme.primaryColor,
                                  chartData: chartData,
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: AppTheme.borderColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cơ cấu thu nhập',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '${structure.length} nhóm',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (structure.isEmpty)
                        const Text(
                          'Chưa có dữ liệu cơ cấu thu nhập',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: structure.entries.map((e) {
                            final c = _typeColor(e.key);

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.08,
                                ),
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

                // Tiêu đề lịch sử thu nhập.
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
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                if (_controller.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_controller.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      _controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.errorColor,
                      ),
                    ),
                  )
                else if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Chưa có giao dịch thu nhập nào trong tháng này.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  )
                else
                  ...items.map((item) {
                    final formattedDate = _formatDisplayDate(
                      item.transactionDate,
                    );

                    final subtitle = item.description?.isNotEmpty == true
                        ? '$formattedDate • ${item.description}'
                        : formattedDate;

                    return InkWell(
                      onTap: () => _openEditIncome(item),
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
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
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
                                          color: AppTheme.primaryColor
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
                      ),
                    );
                  }),

                // Hiển thị trạng thái tải thêm ở cuối danh sách.
                if (_controller.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Đang tải thêm giao dịch...'),
                        ],
                      ),
                    ),
                  )
                else if (!_controller.hasMore && items.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Bạn đã xem hết giao dịch',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // Hiển thị lỗi nếu tải thêm thất bại.
                if (_controller.errorMessage != null &&
                    items.isNotEmpty &&
                    !_controller.isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ),
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
            text: 'Thêm khoản thu nhập mới',
            icon: Icons.add,
            height: 46,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
            textColor: AppTheme.primaryDark,
            onPressed: _openAddIncome,
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

    await _controller.loadIncomeData(
      month: _selectedMonth,
      year: _selectedYear,
    );
  }

  Future<void> _openEditIncome(IncomeModel item) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(builder: (_) => EditIncomeView(income: item)),
    );

    if (!mounted || result == null) return;

    await _controller.loadIncomeData(
      month: _selectedMonth,
      year: _selectedYear,
    );
  }
}

class _SimpleChartPainter extends CustomPainter {
  final Color color;
  final List<IncomeChartPoint> chartData;

  _SimpleChartPainter({required this.color, required this.chartData});

  @override
  void paint(Canvas canvas, Size size) {
    if (chartData.isEmpty) return;

    // Chuyển số tiền từ String sang double.
    final amounts = chartData.map((point) {
      final clean = point.amount.replaceAll(',', '').trim();
      return double.tryParse(clean) ?? 0.0;
    }).toList();

    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);

    const topPad = 10.0;
    const bottomPad = 22.0;

    final chartHeight = size.height - topPad - bottomPad;

    final stepX = chartData.length > 1
        ? size.width / (chartData.length - 1)
        : 0.0;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < amounts.length; i++) {
      final normalized = maxAmount > 0 ? amounts[i] / maxAmount : 0.0;

      final x = chartData.length > 1 ? i * stepX : size.width / 2;

      final y = topPad + chartHeight * (1 - normalized);

      final point = Offset(x, y);
      points.add(point);

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    // Vẽ đường biểu đồ.
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Vẽ các điểm dữ liệu.
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = color);
      canvas.drawCircle(point, 1.8, Paint()..color = Colors.white);
    }

    // Hiển thị tối đa 6 nhãn ngày để tránh bị chồng chữ.
    final labelIndexes = <int>{};

    if (chartData.length <= 6) {
      labelIndexes.addAll(List.generate(chartData.length, (index) => index));
    } else {
      for (int i = 0; i < 6; i++) {
        labelIndexes.add((i * (chartData.length - 1) / 5).round());
      }
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final index in labelIndexes) {
      final rawDate = chartData[index].date;
      final parsedDate = DateTime.tryParse(rawDate);

      final label = parsedDate != null
          ? '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}'
          : rawDate;

      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
      );

      textPainter.layout();

      final dx = (points[index].dx - textPainter.width / 2).clamp(
        0.0,
        size.width - textPainter.width,
      );

      textPainter.paint(canvas, Offset(dx, size.height - 14));
    }
  }

  @override
  bool shouldRepaint(covariant _SimpleChartPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.chartData != chartData;
  }
}
