import '../../../core/network/api_client.dart';
import '../models/credit_account_model.dart';
import '../models/credit_application_model.dart';

/// Service gọi trực tiếp các API Quản lý tài khoản tín dụng & Yêu cầu mở tín dụng.
class CreditService {
  final ApiClient _apiClient;

  CreditService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  static const String _accountsPath = '/api/credit_accounts';
  static const String _applicationsPath = '/api/credit_applications';

  // =============================
  // 1. QUẢN LÝ TÀI KHOẢN TÍN DỤNG
  // =============================

  /// GET /api/credit_accounts
  Future<List<CreditAccountModel>> getCreditAccounts({String? token}) async {
    final response = await _apiClient.get(_accountsPath, token: token);
    final rawData = response['data'];
    if (rawData is List) {
      return rawData
          .map((e) => CreditAccountModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// GET `/api/credit_accounts?account_id=<id>`
  Future<CreditAccountModel> getCreditAccountById(
    int accountId, {
    String? token,
  }) async {
    final response = await _apiClient.get(
      _accountsPath,
      queryParams: {'account_id': accountId},
      token: token,
    );
    final rawData = response['data'];
    if (rawData is Map<String, dynamic>) {
      return CreditAccountModel.fromJson(rawData);
    }
    throw ApiException('Không tìm thấy tài khoản');
  }

  /// POST /api/credit_accounts
  Future<String> addCreditAccount({
    required String accountType,
    required String bankName,
    required double creditLimit,
    required double currentBalance,
    String? token,
  }) async {
    final response = await _apiClient.post(
      _accountsPath,
      body: {
        'account_type': accountType,
        'bank_name': bankName,
        'credit_limit': creditLimit,
        'current_balance': currentBalance,
      },
      token: token,
    );
    return response['message']?.toString() ??
        'Đã thêm tài khoản tín dụng thành công';
  }

  /// PATCH /api/credit_accounts
  Future<String> updateCreditAccount({
    required int accountId,
    required String accountType,
    required String bankName,
    required double creditLimit,
    required double currentBalance,
    String? token,
  }) async {
    final response = await _apiClient.patch(
      _accountsPath,
      body: {
        'account_id': accountId,
        'account_type': accountType,
        'bank_name': bankName,
        'credit_limit': creditLimit,
        'current_balance': currentBalance,
      },
      token: token,
    );
    return response['message']?.toString() ??
        'Đã cập nhật tài khoản tín dụng thành công';
  }

  /// DELETE /api/credit_accounts (chuyển trạng thái sang CLOSED)
  Future<String> closeCreditAccount(int accountId, {String? token}) async {
    final response = await _apiClient.delete(
      _accountsPath,
      body: {'account_id': accountId},
      token: token,
    );
    return response['message']?.toString() ??
        'Đã đóng tài khoản tín dụng thành công';
  }

  // =============================
  // 2. YÊU CẦU MỞ TÍN DỤNG
  // =============================

  /// GET /api/credit_applications
  Future<List<CreditApplicationModel>> getCreditApplications({
    String? token,
  }) async {
    final response = await _apiClient.get(_applicationsPath, token: token);
    final rawData = response['data'];
    if (rawData is List) {
      return rawData
          .map(
            (e) => CreditApplicationModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    }
    return [];
  }

  /// GET `/api/credit_applications?application_id=<id>`
  Future<CreditApplicationModel> getCreditApplicationById(
    int applicationId, {
    String? token,
  }) async {
    final response = await _apiClient.get(
      _applicationsPath,
      queryParams: {'application_id': applicationId},
      token: token,
    );
    final rawData = response['data'];
    if (rawData is Map<String, dynamic>) {
      return CreditApplicationModel.fromJson(rawData);
    }
    throw ApiException('Không tìm thấy dữ liệu');
  }

  /// POST /api/credit_applications
  Future<String> addCreditApplication({
    required String name,
    required String creditType,
    String? token,
  }) async {
    final response = await _apiClient.post(
      _applicationsPath,
      body: {
        'name': name,
        'credit_type': creditType,
      },
      token: token,
    );
    return response['message']?.toString() ??
        'Tạo yêu cầu tín dụng thành công';
  }

  /// DELETE /api/credit_applications
  Future<String> deleteCreditApplication(
    int applicationId, {
    String? token,
  }) async {
    final response = await _apiClient.delete(
      _applicationsPath,
      body: {'application_id': applicationId},
      token: token,
    );
    return response['message']?.toString() ??
        'Đã xóa yêu cầu tín dụng thành công';
  }
}
