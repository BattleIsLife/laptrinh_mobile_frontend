import 'dart:async';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../models/credit_account.dart';
import '../models/credit_application.dart';

/// Contract for Credit Account and Credit Application operations.
abstract class CreditService {
  /// Factory constructor returning [MockCreditService] or [HttpCreditService]
  /// based on application configuration.
  factory CreditService({ApiClient? apiClient, bool? useMock}) {
    final shouldUseMock = useMock ?? ApiConfig.useMockService;
    if (shouldUseMock) {
      return MockCreditService();
    }
    return HttpCreditService(apiClient: apiClient);
  }

  // --- Credit Accounts ---
  Future<List<CreditAccount>> getCreditAccounts({String? token});
  Future<CreditAccount> getCreditAccountById(int accountId, {String? token});
  Future<String> addCreditAccount({
    required String accountType,
    required String bankName,
    required double creditLimit,
    required double currentBalance,
    String? token,
  });
  Future<String> updateCreditAccount({
    required int accountId,
    String? accountType,
    String? bankName,
    double? creditLimit,
    double? currentBalance,
    String? token,
  });
  Future<String> closeCreditAccount({required int accountId, String? token});

  // --- Credit Applications ---
  Future<List<CreditApplication>> getCreditApplications({String? token});
  Future<CreditApplication> getCreditApplicationById(
    int applicationId, {
    String? token,
  });
  Future<String> createCreditApplication({
    required String name,
    required String creditType,
    String? token,
  });
  Future<String> deleteCreditApplication({
    required int applicationId,
    String? token,
  });
}

/// Real HTTP implementation connecting to Node.js backend.
class HttpCreditService implements CreditService {
  final ApiClient _apiClient;

  HttpCreditService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<CreditAccount>> getCreditAccounts({String? token}) async {
    final response = await _apiClient.get(
      ApiConfig.creditAccountsEndpoint,
      token: token,
    );

    final rawList = response['data'];
    if (rawList is List) {
      return rawList
          .map((item) => CreditAccount.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<CreditAccount> getCreditAccountById(
    int accountId, {
    String? token,
  }) async {
    final response = await _apiClient.get(
      ApiConfig.creditAccountsEndpoint,
      queryParams: {'account_id': accountId},
      token: token,
    );

    final rawData = response['data'];
    if (rawData is Map<String, dynamic>) {
      return CreditAccount.fromJson(rawData);
    }
    throw ApiException('Không tìm thấy thông tin tài khoản');
  }

  @override
  Future<String> addCreditAccount({
    required String accountType,
    required String bankName,
    required double creditLimit,
    required double currentBalance,
    String? token,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.creditAccountsEndpoint,
      body: {
        'account_type': accountType,
        'bank_name': bankName,
        'credit_limit': creditLimit,
        'current_balance': currentBalance,
      },
      token: token,
    );

    return response['message'] as String? ??
        'Đã thêm tài khoản tín dụng thành công';
  }

  @override
  Future<String> updateCreditAccount({
    required int accountId,
    String? accountType,
    String? bankName,
    double? creditLimit,
    double? currentBalance,
    String? token,
  }) async {
    final body = <String, dynamic>{'account_id': accountId};
    if (accountType != null) body['account_type'] = accountType;
    if (bankName != null) body['bank_name'] = bankName;
    if (creditLimit != null) body['credit_limit'] = creditLimit;
    if (currentBalance != null) body['current_balance'] = currentBalance;

    final response = await _apiClient.patch(
      ApiConfig.creditAccountsEndpoint,
      body: body,
      token: token,
    );

    return response['message'] as String? ??
        'Đã cập nhật tài khoản tín dụng thành công';
  }

  @override
  Future<String> closeCreditAccount({
    required int accountId,
    String? token,
  }) async {
    final response = await _apiClient.delete(
      ApiConfig.creditAccountsEndpoint,
      body: {'account_id': accountId},
      token: token,
    );

    return response['message'] as String? ??
        'Đã đóng tài khoản tín dụng thành công';
  }

  @override
  Future<List<CreditApplication>> getCreditApplications({String? token}) async {
    final response = await _apiClient.get(
      ApiConfig.creditApplicationsEndpoint,
      token: token,
    );

    final rawList = response['data'];
    if (rawList is List) {
      return rawList
          .map(
            (item) => CreditApplication.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    return [];
  }

  @override
  Future<CreditApplication> getCreditApplicationById(
    int applicationId, {
    String? token,
  }) async {
    final response = await _apiClient.get(
      ApiConfig.creditApplicationsEndpoint,
      queryParams: {'application_id': applicationId},
      token: token,
    );

    final rawData = response['data'];
    if (rawData is Map<String, dynamic>) {
      return CreditApplication.fromJson(rawData);
    }
    throw ApiException('Không tìm thấy dữ liệu yêu cầu');
  }

  @override
  Future<String> createCreditApplication({
    required String name,
    required String creditType,
    String? token,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.creditApplicationsEndpoint,
      body: {'name': name, 'credit_type': creditType},
      token: token,
    );

    return response['message'] as String? ?? 'Tạo yêu cầu tín dụng thành công';
  }

  @override
  Future<String> deleteCreditApplication({
    required int applicationId,
    String? token,
  }) async {
    final response = await _apiClient.delete(
      ApiConfig.creditApplicationsEndpoint,
      body: {'application_id': applicationId},
      token: token,
    );

    return response['message'] as String? ??
        'Đã xóa yêu cầu tín dụng thành công';
  }
}

/// In-memory mock service for testing, offline demo, and verification.
class MockCreditService implements CreditService {
  final Duration simulatedDelay;

  MockCreditService({this.simulatedDelay = const Duration(milliseconds: 400)});

  static final List<CreditAccount> _accounts = [
    CreditAccount(
      id: 1,
      userId: 1,
      accountType: 'CREDIT_CARD',
      bankName: 'Ngân hàng Giả tưởng Việt Nam',
      creditLimit: 700000.0,
      currentBalance: 100000.0,
      openedDate: DateTime.now().subtract(const Duration(days: 45)),
      closedDate: null,
      status: 'ACTIVE',
    ),
    CreditAccount(
      id: 2,
      userId: 1,
      accountType: 'CREDIT_CARD',
      bankName: 'Ngân hàng Techcombank',
      creditLimit: 5000000.0,
      currentBalance: 200000.0,
      openedDate: DateTime.now().subtract(const Duration(days: 30)),
      closedDate: null,
      status: 'ACTIVE',
    ),
    CreditAccount(
      id: 3,
      userId: 1,
      accountType: 'OVERDRAFT',
      bankName: 'Ngân hàng Vietcombank',
      creditLimit: 15000000.0,
      currentBalance: 3200000.0,
      openedDate: DateTime.now().subtract(const Duration(days: 90)),
      closedDate: null,
      status: 'ACTIVE',
    ),
    CreditAccount(
      id: 4,
      userId: 1,
      accountType: 'CREDIT_CARD',
      bankName: 'Ngân hàng VPBank',
      creditLimit: 30000000.0,
      currentBalance: 0.0,
      openedDate: DateTime.now().subtract(const Duration(days: 180)),
      closedDate: DateTime.now().subtract(const Duration(days: 10)),
      status: 'CLOSED',
    ),
  ];

  static final List<CreditApplication> _applications = [
    CreditApplication(
      id: 1,
      userId: 1,
      name: 'Thẻ tín dụng Hoàn tiền Visa Platinum',
      creditType: 'CREDIT_CARD',
      applicationDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CreditApplication(
      id: 2,
      userId: 1,
      name: 'Hạn mức thấu chi tiêu dùng theo lương',
      creditType: 'OVERDRAFT',
      applicationDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  Future<List<CreditAccount>> getCreditAccounts({String? token}) async {
    await Future.delayed(simulatedDelay);
    return List.from(_accounts);
  }

  @override
  Future<CreditAccount> getCreditAccountById(
    int accountId, {
    String? token,
  }) async {
    await Future.delayed(simulatedDelay);
    final match = _accounts.where((a) => a.id == accountId);
    if (match.isEmpty) {
      throw ApiException('Không tìm thấy tài khoản');
    }
    return match.first;
  }

  @override
  Future<String> addCreditAccount({
    required String accountType,
    required String bankName,
    required double creditLimit,
    required double currentBalance,
    String? token,
  }) async {
    await Future.delayed(simulatedDelay);
    final newId = _accounts.isEmpty
        ? 1
        : _accounts.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;
    final newAccount = CreditAccount(
      id: newId,
      userId: 1,
      accountType: accountType,
      bankName: bankName,
      creditLimit: creditLimit,
      currentBalance: currentBalance,
      openedDate: DateTime.now(),
      closedDate: null,
      status: 'ACTIVE',
    );
    _accounts.add(newAccount);
    return 'Đã thêm tài khoản tín dụng thành công';
  }

  @override
  Future<String> updateCreditAccount({
    required int accountId,
    String? accountType,
    String? bankName,
    double? creditLimit,
    double? currentBalance,
    String? token,
  }) async {
    await Future.delayed(simulatedDelay);
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index == -1) {
      throw ApiException('Không tìm thấy tài khoản');
    }

    final current = _accounts[index];
    _accounts[index] = current.copyWith(
      accountType: accountType,
      bankName: bankName,
      creditLimit: creditLimit,
      currentBalance: currentBalance,
    );
    return 'Đã cập nhật tài khoản tín dụng thành công';
  }

  @override
  Future<String> closeCreditAccount({
    required int accountId,
    String? token,
  }) async {
    await Future.delayed(simulatedDelay);
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index == -1) {
      throw ApiException('Không tìm thấy tài khoản');
    }

    final current = _accounts[index];
    _accounts[index] = current.copyWith(
      status: 'CLOSED',
      closedDate: DateTime.now(),
    );
    return 'Đã đóng tài khoản tín dụng thành công';
  }

  @override
  Future<List<CreditApplication>> getCreditApplications({String? token}) async {
    await Future.delayed(simulatedDelay);
    return List.from(_applications);
  }

  @override
  Future<CreditApplication> getCreditApplicationById(
    int applicationId, {
    String? token,
  }) async {
    await Future.delayed(simulatedDelay);
    final match = _applications.where((a) => a.id == applicationId);
    if (match.isEmpty) {
      throw ApiException('Không tìm thấy dữ liệu');
    }
    return match.first;
  }

  @override
  Future<String> createCreditApplication({
    required String name,
    required String creditType,
    String? token,
  }) async {
    await Future.delayed(simulatedDelay);
    final newId = _applications.isEmpty
        ? 1
        : _applications.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;
    final newApp = CreditApplication(
      id: newId,
      userId: 1,
      name: name,
      creditType: creditType,
      applicationDate: DateTime.now(),
    );
    _applications.add(newApp);
    return 'Tạo yêu cầu tín dụng thành công';
  }

  @override
  Future<String> deleteCreditApplication({
    required int applicationId,
    String? token,
  }) async {
    await Future.delayed(simulatedDelay);
    final index = _applications.indexWhere((a) => a.id == applicationId);
    if (index == -1) {
      throw ApiException('Không tìm thấy tài khoản');
    }
    _applications.removeAt(index);
    return 'Đã xóa yêu cầu tín dụng thành công';
  }
}
