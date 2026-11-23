
import 'package:flutter/foundation.dart';

import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseController extends ChangeNotifier {
  final ExpenseService _expenseService;

  ExpenseController({ExpenseService? expenseService})
      : _expenseService = expenseService ?? ExpenseService();

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  int _totalItems = 0;

  List<ExpenseModel> _expenses = [];

  ExpenseStatisticModel _statistic = const ExpenseStatisticModel(
    totalExpense: '0',
    points: [],
    structure: {},
    essentialRate: '0',
  );

  List<ExpenseCategoryModel> _categories = [];

  Map<String, String> _fieldErrors = {};

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  int get totalItems => _totalItems;
  List<ExpenseModel> get expenses => _expenses;
  ExpenseStatisticModel get statistic => _statistic;
  List<ExpenseCategoryModel> get categories => _categories;
  Map<String, String> get fieldErrors => _fieldErrors;

  /// GET /api/expense/?page=...&month=...&year=...
  /// GET /api/expense/statistic?month=...&year=...
  Future<void> loadExpenseData({
    required int month,
    required int year,
    int page = 0,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final listRes = await _expenseService.getExpenses(
        page: page,
        month: month,
        year: year,
      );

      final statRes = await _expenseService.getStatistic(
        month: month,
        year: year,
      );

      _expenses =
          (listRes['expenses'] as List<ExpenseModel>?) ?? [];

      _totalItems = listRes['total_items'] as int? ?? _expenses.length;

      _statistic = statRes;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// GET /api/expense_category/
  Future<void> loadCategories() async {
    try {
      _categories = await _expenseService.getCategories();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  /// GET /api/expense/:id
  Future<ExpenseModel?> getExpenseById(int id) async {
    try {
      return await _expenseService.getExpenseById(id);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// DELETE /api/expense/:id
  Future<bool> deleteExpense(
    int id, {
    required int month,
    required int year,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _expenseService.deleteExpense(id);

      await loadExpenseData(
        month: month,
        year: year,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearFormErrors() {
    _errorMessage = null;
    _fieldErrors = {};
    notifyListeners();
  }

  String _normalizeAmount(String rawAmount) {
    final trimmed = rawAmount.trim();

    if (trimmed.isEmpty) return '';

    final dotIndex = trimmed.indexOf('.');
    final integerPart =
        dotIndex == -1 ? trimmed : trimmed.substring(0, dotIndex);

    final digitsOnly = integerPart.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) return '';

    final parsed = int.tryParse(digitsOnly);

    if (parsed == null || parsed < 1) return '';

    return parsed.toString();
  }

  /// POST /api/expense/
 
Future<ExpenseModel?> createExpense({
  required String amount,
  required String categoryId,
  required String categoryName,
  required String transactionDate,
  String? title,
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

    if (normalizedAmount.isEmpty || normalizedAmount.length > 13) {
      _fieldErrors = {
        'amount': 'Số tiền tối thiểu 1 đ và tối đa 13 chữ số',
      };
      return null;
    }

    final cleanTitle = (title ?? '').trim();
    final cleanDesc = (description ?? '').trim();

    final finalDescription = cleanDesc.isNotEmpty
        ? cleanDesc
        : (cleanTitle.isNotEmpty ? cleanTitle : '');

    await _expenseService.createExpense(
      amount: normalizedAmount,
      categoryId: categoryId,
      transactionDate: transactionDate,
      description: finalDescription.isEmpty ? null : finalDescription,
    );

    final transactionDateParsed = DateTime.tryParse(transactionDate);

    final month = refreshMonth ?? transactionDateParsed?.month;
    final year = refreshYear ?? transactionDateParsed?.year;

    if (month != null && year != null) {
      try {
        await loadExpenseData(
          month: month,
          year: year,
        );
      } catch (_) {
       
      }
    }

    ExpenseModel(
      id: 0,
      amount: normalizedAmount,
      categoryId: categoryId,
      categoryName: categoryName,
      transactionDate: transactionDate,
      description: finalDescription.isEmpty ? null : finalDescription,
    );
  } catch (e) {
    _errorMessage = e.toString().replaceFirst('Exception: ', '');
    return null;
  } finally {
    _isSubmitting = false;
    notifyListeners();
  }
}

  /// PUT /api/expense/:id
  Future<ExpenseModel?> updateExpense({
    required int id,
    required String amount,
    required String categoryId,
    required String categoryName,
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

      if (normalizedAmount.isEmpty || normalizedAmount.length > 13) {
        _fieldErrors = {
          'amount': 'Số tiền tối thiểu 1 đ và tối đa 13 chữ số',
        };
        return null;
      }

      final cleanDesc = (description ?? '').trim();

      if (cleanDesc.length > 255) {
        _fieldErrors = {
          'description': 'Mô tả không được quá 255 ký tự',
        };
        return null;
      }

      await _expenseService.updateExpense(
        id,
        amount: normalizedAmount,
        categoryId: categoryId,
        transactionDate: transactionDate,
        description: cleanDesc.isEmpty ? null : cleanDesc,
      );

      // Lấy lại dữ liệu giao dịch từ backend để có thông tin mới nhất.
      final updated = await _expenseService.getExpenseById(id);

      if (refreshMonth != null && refreshYear != null) {
        await loadExpenseData(
          month: refreshMonth,
          year: refreshYear,
        );
      }

      return updated;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
