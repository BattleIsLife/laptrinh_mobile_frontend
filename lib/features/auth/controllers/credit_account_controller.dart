import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../models/credit_account.dart';
import '../models/credit_application.dart';
import '../services/credit_service.dart';

/// Controller coordinating Credit Account and Application state and business logic.
///
/// Follows MVC pattern and extends [ChangeNotifier] for reactive Flutter updates.
/// Fully decoupled from [BuildContext] for clean testing and separation of concerns.
class CreditAccountController extends ChangeNotifier {
  final CreditService _creditService;

  List<CreditAccount> _accounts = [];
  List<CreditApplication> _applications = [];
  CreditAccount? _selectedAccount;

  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  String? _successMessage;

  String _filterType = 'ALL'; // ALL, CREDIT_CARD, OVERDRAFT, ACTIVE, CLOSED
  String _searchQuery = '';
  String? _token;

  CreditAccountController({CreditService? creditService, String? token})
    : _creditService = creditService ?? CreditService() {
    _token = token;
  }

  // --- Getters ---
  List<CreditAccount> get accounts => _accounts;
  List<CreditApplication> get applications => _applications;
  CreditAccount? get selectedAccount => _selectedAccount;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get filterType => _filterType;
  String get searchQuery => _searchQuery;
  String? get token => _token;

  /// Sets or updates the authorization token.
  void setToken(String? token) {
    _token = token;
  }

  /// Sets the active account filter: 'ALL', 'CREDIT_CARD', 'OVERDRAFT', 'ACTIVE', 'CLOSED'
  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  /// Sets the bank search query string.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clears transient feedback messages.
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Filtered list of accounts according to [filterType] and [searchQuery].
  List<CreditAccount> get filteredAccounts {
    return _accounts.where((account) {
      // Filter by type or status
      bool matchesFilter = true;
      switch (_filterType) {
        case 'CREDIT_CARD':
          matchesFilter = account.isCreditCard;
          break;
        case 'OVERDRAFT':
          matchesFilter = account.isOverdraft;
          break;
        case 'ACTIVE':
          matchesFilter = account.isActive;
          break;
        case 'CLOSED':
          matchesFilter = account.isClosed;
          break;
        case 'ALL':
        default:
          matchesFilter = true;
      }

      // Filter by bank name query
      bool matchesSearch = true;
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase().trim();
        matchesSearch = account.bankName.toLowerCase().contains(query);
      }

      return matchesFilter && matchesSearch;
    }).toList();
  }

  // --- Financial Statistics ---

  /// Sum of credit limits across all active accounts
  double get totalCreditLimit => _accounts
      .where((a) => a.isActive)
      .fold(0.0, (sum, a) => sum + a.creditLimit);

  /// Sum of current balance (debt used) across all active accounts
  double get totalCurrentBalance => _accounts
      .where((a) => a.isActive)
      .fold(0.0, (sum, a) => sum + a.currentBalance);

  /// Total available credit line
  double get totalAvailableLimit {
    final available = totalCreditLimit - totalCurrentBalance;
    return available > 0 ? available : 0.0;
  }

  /// Overall utilization ratio across all active accounts
  double get overallUtilization =>
      totalCreditLimit > 0 ? (totalCurrentBalance / totalCreditLimit) : 0.0;

  int get activeAccountCount => _accounts.where((a) => a.isActive).length;
  int get closedAccountCount => _accounts.where((a) => a.isClosed).length;

  // --- Input Validations (Backend Specs) ---

  /// Validates bank name (must not be empty)
  static String? validateBankName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên ngân hàng';
    }
    return null;
  }

  /// Validates credit limit (non-negative decimal, max 2 decimals)
  static String? validateCreditLimit(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập hạn mức tín dụng';
    }
    final clean = value.replaceAll('.', '').replaceAll(',', '.').trim();
    final number = double.tryParse(clean);
    if (number == null || number < 0) {
      return 'Hạn mức tín dụng phải là 1 số thập phân không âm';
    }
    return null;
  }

  /// Validates current balance (non-negative decimal, max 2 decimals)
  static String? validateCurrentBalance(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số dư tài khoản';
    }
    final clean = value.replaceAll('.', '').replaceAll(',', '.').trim();
    final number = double.tryParse(clean);
    if (number == null || number < 0) {
      return 'Số dư tài khoản phải là 1 số thập phân không âm';
    }
    return null;
  }

  /// Validates account type (must be CREDIT_CARD or OVERDRAFT)
  static String? validateAccountType(String? value) {
    if (value != 'CREDIT_CARD' && value != 'OVERDRAFT') {
      return 'Loại tài khoản không hợp lệ, phải là CREDIT_CARD hoặc OVERDRAFT';
    }
    return null;
  }

  /// Validates application name (must not be empty)
  static String? validateApplicationName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên yêu cầu tín dụng';
    }
    return null;
  }

  // --- Account Operations ---

  /// Fetches credit accounts from API.
  Future<void> fetchAccounts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _accounts = await _creditService.getCreditAccounts(token: _token);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi không xác định khi tải danh sách tài khoản: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches detail for a single account by ID.
  Future<CreditAccount?> fetchAccountDetail(int accountId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final account = await _creditService.getCreditAccountById(
        accountId,
        token: _token,
      );
      _selectedAccount = account;
      _isLoading = false;
      notifyListeners();
      return account;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Lỗi khi tải chi tiết tài khoản: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Adds a new credit account.
  Future<bool> addAccount({
    required String accountType,
    required String bankName,
    required double creditLimit,
    required double currentBalance,
  }) async {
    final typeErr = validateAccountType(accountType);
    if (typeErr != null) {
      _errorMessage = typeErr;
      notifyListeners();
      return false;
    }

    final bankErr = validateBankName(bankName);
    if (bankErr != null) {
      _errorMessage = bankErr;
      notifyListeners();
      return false;
    }

    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _creditService.addCreditAccount(
        accountType: accountType,
        bankName: bankName.trim(),
        creditLimit: creditLimit,
        currentBalance: currentBalance,
        token: _token,
      );

      _successMessage = msg;
      _isActionLoading = false;
      await fetchAccounts();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi khi thêm tài khoản: $e';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing credit account.
  Future<bool> updateAccount({
    required int accountId,
    String? accountType,
    String? bankName,
    double? creditLimit,
    double? currentBalance,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _creditService.updateCreditAccount(
        accountId: accountId,
        accountType: accountType,
        bankName: bankName?.trim(),
        creditLimit: creditLimit,
        currentBalance: currentBalance,
        token: _token,
      );

      _successMessage = msg;
      _isActionLoading = false;
      await fetchAccounts();

      if (_selectedAccount != null && _selectedAccount!.id == accountId) {
        await fetchAccountDetail(accountId);
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật tài khoản: $e';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Closes a credit account (changes status to CLOSED).
  Future<bool> closeAccount(int accountId) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _creditService.closeCreditAccount(
        accountId: accountId,
        token: _token,
      );

      _successMessage = msg;
      _isActionLoading = false;
      await fetchAccounts();

      if (_selectedAccount != null && _selectedAccount!.id == accountId) {
        await fetchAccountDetail(accountId);
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi khi đóng tài khoản: $e';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- Credit Application Operations ---

  /// Fetches credit applications list.
  Future<void> fetchApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _applications = await _creditService.getCreditApplications(token: _token);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi khi tải danh sách yêu cầu mở tín dụng: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submits a new credit application.
  Future<bool> createApplication({
    required String name,
    required String creditType,
  }) async {
    final nameErr = validateApplicationName(name);
    if (nameErr != null) {
      _errorMessage = nameErr;
      notifyListeners();
      return false;
    }

    final typeErr = validateAccountType(creditType);
    if (typeErr != null) {
      _errorMessage = typeErr;
      notifyListeners();
      return false;
    }

    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _creditService.createCreditApplication(
        name: name.trim(),
        creditType: creditType,
        token: _token,
      );

      _successMessage = msg;
      _isActionLoading = false;
      await fetchApplications();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi khi tạo yêu cầu tín dụng: $e';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Deletes a credit application.
  Future<bool> deleteApplication(int applicationId) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _creditService.deleteCreditApplication(
        applicationId: applicationId,
        token: _token,
      );

      _successMessage = msg;
      _isActionLoading = false;
      await fetchApplications();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi khi xóa yêu cầu: $e';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }
}
