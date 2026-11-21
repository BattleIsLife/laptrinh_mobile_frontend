import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../models/saving_goal.dart';
import '../services/saving_service.dart';

/// Controller coordinating Savings Goal management state and business logic.
///
/// Follows MVC architecture and extends [ChangeNotifier] for reactive updates.
/// Decoupled from [BuildContext] for reliable unit and widget testing.
class SavingController extends ChangeNotifier {
  final SavingService _savingService;

  List<SavingGoal> _savings = [];
  SavingGoal? _selectedSaving;

  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  String? _successMessage;

  String _statusFilter = 'ALL'; // ALL, ACTIVE, COMPLETED, CANCELLED
  int? _filterMonth;
  int? _filterYear;
  String _searchQuery = '';
  String? _token;

  SavingController({SavingService? savingService, String? token})
    : _savingService = savingService ?? SavingService() {
    _token = token;
  }

  // --- Getters ---
  List<SavingGoal> get savings => _savings;
  SavingGoal? get selectedSaving => _selectedSaving;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get statusFilter => _statusFilter;
  int? get filterMonth => _filterMonth;
  int? get filterYear => _filterYear;
  String get searchQuery => _searchQuery;
  String? get token => _token;

  void setToken(String? token) {
    _token = token;
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setDateFilter(int? month, int? year) {
    _filterMonth = month;
    _filterYear = year;
    notifyListeners();
    fetchSavings(month: _filterMonth, year: _filterYear);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearDateFilter() {
    _filterMonth = null;
    _filterYear = null;
    notifyListeners();
    fetchSavings();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Filtered list of savings goals according to [statusFilter] and [searchQuery].
  List<SavingGoal> get filteredSavings {
    return _savings.where((goal) {
      bool matchesStatus = true;
      switch (_statusFilter) {
        case 'ACTIVE':
          matchesStatus = goal.isActive;
          break;
        case 'COMPLETED':
          matchesStatus = goal.isCompleted;
          break;
        case 'CANCELLED':
          matchesStatus = goal.isCancelled;
          break;
        case 'ALL':
        default:
          matchesStatus = true;
      }

      bool matchesSearch = true;
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase().trim();
        matchesSearch = goal.name.toLowerCase().contains(query);
      }

      return matchesStatus && matchesSearch;
    }).toList();
  }

  // --- Financial Statistics ---

  /// Sum of all target amounts
  double get totalTargetAmount =>
      _savings.fold(0.0, (sum, s) => sum + s.targetAmount);

  /// Sum of all currently accumulated savings
  double get totalSavedAmount =>
      _savings.fold(0.0, (sum, s) => sum + s.currentAmount);

  /// Total remaining amount to achieve all targets
  double get totalRemainingAmount {
    final remaining = totalTargetAmount - totalSavedAmount;
    return remaining > 0 ? remaining : 0.0;
  }

  /// Overall savings completion ratio (0.0 to 1.0)
  double get overallProgressRatio =>
      totalTargetAmount > 0 ? (totalSavedAmount / totalTargetAmount) : 0.0;

  int get totalCount => _savings.length;
  int get activeCount => _savings.where((s) => s.isActive).length;
  int get completedCount => _savings.where((s) => s.isCompleted).length;
  int get cancelledCount => _savings.where((s) => s.isCancelled).length;

  // --- Validations Matching Backend Specifications ---

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên mục tiêu tiết kiệm';
    }
    return null;
  }

  static String? validateTargetAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mục tiêu đạt được phải là 1 số thập phân dương, tối đa 2 chữ số sau dấu phảy';
    }
    final clean = value.replaceAll('.', '').replaceAll(',', '.').trim();
    final number = double.tryParse(clean);
    if (number == null || number <= 0) {
      return 'Mục tiêu đạt được phải là 1 số thập phân dương, tối đa 2 chữ số sau dấu phảy';
    }
    return null;
  }

  static String? validateMonthlyContribution(
    String? value, {
    double? targetAmount,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Đóng góp hàng tháng phải là 1 số thập phân dương, tối đa 2 chữ số sau dấu phảy';
    }
    final clean = value.replaceAll('.', '').replaceAll(',', '.').trim();
    final number = double.tryParse(clean);
    if (number == null || number <= 0) {
      return 'Đóng góp hàng tháng phải là 1 số thập phân dương, tối đa 2 chữ số sau dấu phảy';
    }
    if (targetAmount != null && targetAmount > 0 && number > targetAmount) {
      return 'Đóng góp hàng tháng không được lớn hơn mục tiêu đề ra';
    }
    return null;
  }

  static String? validateInterestRate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Lãi suất là 1 số thập phân dương, tối đa 2 chữ số sau dấu phảy';
    }
    final clean = value.replaceAll('.', '').replaceAll(',', '.').trim();
    final number = double.tryParse(clean);
    if (number == null || number < 0) {
      return 'Lãi suất là 1 số thập phân dương, tối đa 2 chữ số sau dấu phảy';
    }
    return null;
  }

  static String? validateTargetDate(DateTime? date) {
    if (date == null) {
      return 'Vui lòng chọn ngày hoàn thành mục tiêu';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    if (!targetDay.isAfter(today)) {
      return 'Thời gian hoàn thành mục tiêu không hợp lệ, phải lớn hơn ngày hiện tại';
    }
    return null;
  }

  // --- Operations ---

  /// Fetches savings goals from API with optional month & year filter.
  Future<void> fetchSavings({int? page, int? month, int? year}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _savings = await _savingService.getSavings(
        page: page,
        month: month ?? _filterMonth,
        year: year ?? _filterYear,
        token: _token,
      );
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi không xác định khi tải danh sách mục tiêu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches detail for a single saving goal by ID.
  Future<SavingGoal?> fetchSavingDetail(int savingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final goal = await _savingService.getSavingById(savingId, token: _token);
      _selectedSaving = goal;
      _isLoading = false;
      notifyListeners();
      return goal;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Lỗi khi tải chi tiết mục tiêu: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Adds a new savings goal.
  Future<bool> addSaving({
    required String name,
    required double targetAmount,
    required double monthlyContribution,
    required String targetDate,
    required double interestRate,
  }) async {
    final nameErr = validateName(name);
    if (nameErr != null) {
      _errorMessage = nameErr;
      notifyListeners();
      return false;
    }

    if (monthlyContribution > targetAmount) {
      _errorMessage = 'Đóng góp hàng tháng không được lớn hơn mục tiêu đề ra';
      notifyListeners();
      return false;
    }

    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _savingService.addSaving(
        name: name.trim(),
        targetAmount: targetAmount,
        monthlyContribution: monthlyContribution,
        targetDate: targetDate,
        interestRate: interestRate,
        token: _token,
      );

      _successMessage = msg;
      _isActionLoading = false;
      await fetchSavings();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi khi thêm mục tiêu tiết kiệm: $e';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing savings goal.
  Future<bool> updateSaving({
    required int savingId,
    String? name,
    double? targetAmount,
    double? monthlyContribution,
    String? targetDate,
    double? interestRate,
    String? status,
    double? currentAmount,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _savingService.updateSaving(
        savingId: savingId,
        name: name?.trim(),
        targetAmount: targetAmount,
        monthlyContribution: monthlyContribution,
        targetDate: targetDate,
        interestRate: interestRate,
        status: status,
        currentAmount: currentAmount,
        token: _token,
      );

      _successMessage = msg;
      _isActionLoading = false;
      await fetchSavings();

      if (_selectedSaving != null && _selectedSaving!.id == savingId) {
        await fetchSavingDetail(savingId);
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật mục tiêu: $e';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Convenient helper to deposit an amount into a saving goal.
  Future<bool> depositToSavingGoal(int savingId, double depositAmount) async {
    if (depositAmount <= 0) {
      _errorMessage = 'Số tiền nạp phải lớn hơn 0';
      notifyListeners();
      return false;
    }

    final targetGoal = _savings.firstWhere(
      (s) => s.id == savingId,
      orElse: () => _selectedSaving!,
    );
    final newCurrentAmount = targetGoal.currentAmount + depositAmount;

    return updateSaving(
      savingId: savingId,
      currentAmount: newCurrentAmount,
      status: newCurrentAmount >= targetGoal.targetAmount ? 'COMPLETED' : null,
    );
  }

  /// Deletes a savings goal.
  Future<bool> deleteSaving(int savingId) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _savingService.deleteSaving(savingId, token: _token);
      _successMessage = msg;
      _isActionLoading = false;
      await fetchSavings();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi khi xóa mục tiêu: $e';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }
}
