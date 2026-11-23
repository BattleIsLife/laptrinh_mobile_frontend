import 'package:flutter/foundation.dart';

import '../models/income_model.dart';
import '../services/income_service.dart';

class IncomeController extends ChangeNotifier {
  final IncomeService _incomeService;

  IncomeController({IncomeService? incomeService})
    : _incomeService = incomeService ?? IncomeService();

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  Map<String, String> _fieldErrors = {};
  List<IncomeModel> _incomes = [];
  int _totalItems = 0;
  IncomeStatisticModel? _statistic;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  Map<String, String> get fieldErrors => _fieldErrors;
  List<IncomeModel> get incomes => _incomes;
  int get totalItems => _totalItems;
  IncomeStatisticModel? get statistic => _statistic;

  void clearFormErrors() {
    _errorMessage = null;
    _fieldErrors = {};
    notifyListeners();
  }

  String _normalizeAmount(String rawAmount) {
    final cleaned = rawAmount.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    if (cleaned.isEmpty) return '';
    final parsedDouble = double.tryParse(cleaned);
    if (parsedDouble != null) {
      return parsedDouble.truncate().toString();
    }
    return cleaned.split('.').first;
  }

  /// Tải danh sách và thống kê thu nhập theo tháng/năm
  Future<void> loadIncomeData({int? month, int? year, int page = 0}) async {
    final now = DateTime.now();
    final selectedMonth = month ?? now.month;
    final selectedYear = year ?? now.year;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final listResult = await _incomeService.getIncomes(
        page: page,
        month: selectedMonth,
        year: selectedYear,
      );
      _incomes = (listResult['incomes'] as List<IncomeModel>?) ?? [];
      _totalItems = (listResult['total_items'] as int?) ?? _incomes.length;

      _statistic = await _incomeService.getIncomeStatistic(
       month: selectedMonth,
year: selectedYear,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tạo giao dịch thu nhập từ dữ liệu form (POST api/income/)
  Future<bool> createIncome({
    required String amount,
    required String source,
    required String incomeType,
    required String transactionDate,
    String? description,
    int? refreshMonth,
    int? refreshYear,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    _fieldErrors = {};
    notifyListeners();

    try {
      final normalizedAmount = _normalizeAmount(amount);
      final trimmedDesc = description?.trim();

      final payload = IncomeModel(
        id: 0,
        amount: normalizedAmount,
        source: source.trim(),
        incomeType: incomeType.trim(),
        transactionDate: transactionDate.trim(),
        description: (trimmedDesc == null || trimmedDesc.isEmpty)
            ? null
            : trimmedDesc,
      );

      await _incomeService.createIncome(payload);

      if (refreshMonth != null && refreshYear != null) {
        await loadIncomeData(month: refreshMonth, year: refreshYear);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Thêm khoản thu nhập mới từ IncomeModel (giữ tương thích nếu nơi khác đang gọi)
  Future<bool> addIncome(
    IncomeModel income, {
    int? currentMonth,
    int? currentYear,
  }) async {
    return createIncome(
      amount: income.amount,
      source: income.source,
      incomeType: income.incomeType,
      transactionDate: income.transactionDate,
      description: income.description,
      refreshMonth: currentMonth,
      refreshYear: currentYear,
    );
  }

  /// Xóa khoản thu nhập
  Future<bool> removeIncome(
    int id, {
    int? currentMonth,
    int? currentYear,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _incomeService.deleteIncome(id);
      await loadIncomeData(month: currentMonth, year: currentYear);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật khoản thu nhập theo ID
  Future<bool> updateIncome(
    int id, {
    required String amount,
    required String source,
    required String incomeType,
    required String transactionDate,
    String? description,
    int? refreshMonth,
    int? refreshYear,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    _fieldErrors = {};
    notifyListeners();

    try {
      final normalizedAmount = _normalizeAmount(amount);
      final trimmedDesc = description?.trim();

      final updatedModel = IncomeModel(
        id: id,
        amount: normalizedAmount,
        source: source.trim(),
        incomeType: incomeType.trim(),
        transactionDate: transactionDate.trim(),
        description: (trimmedDesc == null || trimmedDesc.isEmpty)
            ? null
            : trimmedDesc,
      );

      await _incomeService.updateIncome(id, updatedModel);

      if (refreshMonth != null && refreshYear != null) {
        await loadIncomeData(month: refreshMonth, year: refreshYear);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
