import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';

class ExpenseController extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  int _totalItems = 8;
  List<ExpenseModel> _expenses = const [
    ExpenseModel(
      id: 1,
      amount: '4000000.00',
      categoryId: '2',
      categoryName: 'Nhà ở',
      transactionDate: '2026-11-02',
      description: 'Tiền thuê nhà',
    ),
    ExpenseModel(
      id: 2,
      amount: '2500000.00',
      categoryId: '1',
      categoryName: 'Ăn uống',
      transactionDate: '2026-11-05',
      description: 'Ăn uống',
    ),
    ExpenseModel(
      id: 3,
      amount: '1000000.00',
      categoryId: '3',
      categoryName: 'Di chuyển',
      transactionDate: '2026-11-07',
      description: 'Đi lại',
    ),
    ExpenseModel(
      id: 4,
      amount: '3000000.00',
      categoryId: '5',
      categoryName: 'Mua sắm',
      transactionDate: '2026-11-10',
      description: 'Mua sắm',
    ),
    ExpenseModel(
      id: 5,
      amount: '2000000.00',
      categoryId: '4',
      categoryName: 'Giải trí',
      transactionDate: '2026-11-14',
      description: 'Giải trí',
    ),
  ];

  ExpenseStatisticModel _statistic = const ExpenseStatisticModel(
    totalExpense: '12500000.00',
    points: [],
    structure: {
      'Nhà ở': '32',
      'Mua sắm': '24',
      'Ăn uống': '20',
      'Giải trí': '16',
      'Đi lại': '8',
    },
    essentialRate: '80',
  );

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  int get totalItems => _totalItems;
  List<ExpenseModel> get expenses => _expenses;
  ExpenseStatisticModel get statistic => _statistic;

  /// Gọi GET /api/expense/?page=...&month=...&year=... và GET /api/expense/statistic?month=...&year=...
  Future<void> loadExpenseData({
    required int month,
    required int year,
    int page = 0,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Khi nối service thật:
      // final listRes = await _expenseService.getExpenses(page: page, month: month, year: year);
      // final statRes = await _expenseService.getStatistic(month: month, year: year);
      // _expenses = listRes.items;
      // _totalItems = listRes.totalItems;
      // _statistic = statRes;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Xóa giao dịch chi tiêu theo ID: DELETE /api/expense/:id
  Future<bool> deleteExpense(int id, {required int month, required int year}) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Khi nối service thật:
      // await _expenseService.deleteExpense(id);
      // await loadExpenseData(month: month, year: year);
      _expenses = _expenses.where((e) => e.id != id).toList();
      if (_totalItems > 0) _totalItems -= 1;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
  List<ExpenseCategoryModel> _categories = const [
    ExpenseCategoryModel(id: '1', name: 'Ăn uống', icon: 'fastfood', isEssential: true),
    ExpenseCategoryModel(id: '2', name: 'Nhà ở & Điện nước', icon: 'home', isEssential: true),
    ExpenseCategoryModel(id: '3', name: 'Đi lại & Xăng xe', icon: 'directions_car', isEssential: true),
    ExpenseCategoryModel(id: '4', name: 'Giải trí & Cafe', icon: 'sports_esports', isEssential: false),
  ];

  Map<String, String> _fieldErrors = const {};

  List<ExpenseCategoryModel> get categories => _categories;
  Map<String, String> get fieldErrors => _fieldErrors;

  void clearFormErrors() {
    _errorMessage = null;
    _fieldErrors = const {};
    notifyListeners();
  }

  String _normalizeAmount(String rawAmount) {
    final trimmed = rawAmount.trim();
    if (trimmed.isEmpty) return '';
    final dotIndex = trimmed.indexOf('.');
    final integerPart = dotIndex == -1 ? trimmed : trimmed.substring(0, dotIndex);
    final digitsOnly = integerPart.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return '';
    final parsed = int.tryParse(digitsOnly);
    if (parsed == null || parsed < 1) return '';
    return parsed.toString();
  }


  Future<void> loadCategories() async {
    try {
      // Khi nối service thật:
      // _categories = await _expenseService.getCategories();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
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
    _fieldErrors = const {};
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

      // Body gửi POST /api/expense/:
      // {
      //   "amount": normalizedAmount,
      //   "category_id": categoryId,
      //   "transaction_date": transactionDate,
      //   "description": finalDescription,
      // }
      // Khi nối service thật:
      // await _expenseService.createExpense(
      //   amount: normalizedAmount,
      //   categoryId: categoryId,
      //   transactionDate: transactionDate,
      //   description: finalDescription,
      // );
      // if (refreshMonth != null && refreshYear != null) {
      //   await loadExpenseData(month: refreshMonth, year: refreshYear);
      // }

      final created = ExpenseModel(
        id: DateTime.now().millisecondsSinceEpoch,
        amount: '$normalizedAmount.00',
        categoryId: categoryId,
        categoryName: categoryName,
        transactionDate: transactionDate,
        description: finalDescription.isEmpty ? null : finalDescription,
      );

      _expenses = [created, ..._expenses];
      _totalItems += 1;
      return created;
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
    _fieldErrors = const {};
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

      // Body gửi PUT /api/expense/:id:
      // {
      //   "amount": normalizedAmount,
      //   "category_id": categoryId,
      //   "transaction_date": transactionDate,
      //   "description": cleanDesc,
      // }
      // Khi nối service thật:
      // await _expenseService.updateExpense(
      //   id: id,
      //   amount: normalizedAmount,
      //   categoryId: categoryId,
      //   transactionDate: transactionDate,
      //   description: cleanDesc,
      // );
      // if (refreshMonth != null && refreshYear != null) {
      //   await loadExpenseData(month: refreshMonth, year: refreshYear);
      // }

      final updated = ExpenseModel(
        id: id,
        amount: '$normalizedAmount.00',
        categoryId: categoryId,
        categoryName: categoryName,
        transactionDate: transactionDate,
        description: cleanDesc.isEmpty ? null : cleanDesc,
      );

      _expenses = _expenses.map((e) => e.id == id ? updated : e).toList();
      return updated;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }}