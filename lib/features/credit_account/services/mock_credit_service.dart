import '../../../core/network/api_client.dart';
import '../models/credit_account_model.dart';
import '../models/credit_application_model.dart';
import 'credit_service.dart';

/// Mock Service dùng để test giao diện Quản lý tài khoản tín dụng offline
/// mà không cần bật Backend Node.js.
class MockCreditService extends CreditService {
  final Duration delay;

  MockCreditService({this.delay = const Duration(milliseconds: 300)});

  final List<CreditAccountModel> _accounts = [
    const CreditAccountModel(
      id: 1,
      userId: 1,
      accountType: 'CREDIT_CARD',
      bankName: 'Ngân hàng Giả tưởng Việt Nam',
      creditLimit: 700000,
      currentBalance: 100000,
      openedDate: '2026-11-03T17:00:00.000Z',
      closedDate: null,
      status: 'ACTIVE',
    ),
    const CreditAccountModel(
      id: 2,
      userId: 1,
      accountType: 'OVERDRAFT',
      bankName: 'Ngân hàng DEF',
      creditLimit: 5000000,
      currentBalance: 200000,
      openedDate: '2026-11-03T17:00:00.000Z',
      closedDate: null,
      status: 'ACTIVE',
    ),
  ];

  final List<CreditApplicationModel> _applications = [
    const CreditApplicationModel(
      id: 1,
      userId: 1,
      name: 'Mở thẻ mua sắm',
      creditType: 'CREDIT_CARD',
      applicationDate: '2026-11-04T17:00:00.000Z',
    ),
    const CreditApplicationModel(
      id: 2,
      userId: 1,
      name: 'Hạn mức thấu chi',
      creditType: 'OVERDRAFT',
      applicationDate: '2026-11-04T17:00:00.000Z',
    ),
  ];

  int _nextAccountId = 3;
  int _nextAppId = 3;

  @override
  Future<List<CreditAccountModel>> getCreditAccounts({String? token}) async {
    await Future.delayed(delay);
    return List.from(_accounts);
  }

  @override
  Future<CreditAccountModel> getCreditAccountById(
    int accountId, {
    String? token,
  }) async {
    await Future.delayed(delay);
    final index = _accounts.indexWhere((e) => e.id == accountId);
    if (index == -1) {
      throw ApiException('Không tìm thấy tài khoản', statusCode: 404);
    }
    return _accounts[index];
  }

  @override
  Future<String> addCreditAccount({
    required String accountType,
    required String bankName,
    required double creditLimit,
    required double currentBalance,
    String? token,
  }) async {
    await Future.delayed(delay);
    _accounts.add(
      CreditAccountModel(
        id: _nextAccountId++,
        userId: 1,
        accountType: accountType,
        bankName: bankName,
        creditLimit: creditLimit,
        currentBalance: currentBalance,
        openedDate: DateTime.now().toIso8601String(),
        closedDate: null,
        status: 'ACTIVE',
      ),
    );
    return 'Đã thêm tài khoản tín dụng thành công';
  }

  @override
  Future<String> updateCreditAccount({
    required int accountId,
    required String accountType,
    required String bankName,
    required double creditLimit,
    required double currentBalance,
    String? token,
  }) async {
    await Future.delayed(delay);
    final index = _accounts.indexWhere((e) => e.id == accountId);
    if (index == -1) {
      throw ApiException('Không tìm thấy tài khoản', statusCode: 404);
    }
    final old = _accounts[index];
    _accounts[index] = CreditAccountModel(
      id: old.id,
      userId: old.userId,
      accountType: accountType,
      bankName: bankName,
      creditLimit: creditLimit,
      currentBalance: currentBalance,
      openedDate: old.openedDate,
      closedDate: old.closedDate,
      status: old.status,
    );
    return 'Đã cập nhật tài khoản tín dụng thành công';
  }

  @override
  Future<String> closeCreditAccount(int accountId, {String? token}) async {
    await Future.delayed(delay);
    final index = _accounts.indexWhere((e) => e.id == accountId);
    if (index == -1) {
      throw ApiException('Không tìm thấy tài khoản', statusCode: 404);
    }
    final old = _accounts[index];
    _accounts[index] = CreditAccountModel(
      id: old.id,
      userId: old.userId,
      accountType: old.accountType,
      bankName: old.bankName,
      creditLimit: old.creditLimit,
      currentBalance: old.currentBalance,
      openedDate: old.openedDate,
      closedDate: DateTime.now().toIso8601String(),
      status: 'CLOSED',
    );
    return 'Đã đóng tài khoản tín dụng thành công';
  }

  @override
  Future<List<CreditApplicationModel>> getCreditApplications({
    String? token,
  }) async {
    await Future.delayed(delay);
    return List.from(_applications);
  }

  @override
  Future<CreditApplicationModel> getCreditApplicationById(
    int applicationId, {
    String? token,
  }) async {
    await Future.delayed(delay);
    final index = _applications.indexWhere((e) => e.id == applicationId);
    if (index == -1) {
      throw ApiException('Không tìm thấy dữ liệu', statusCode: 404);
    }
    return _applications[index];
  }

  @override
  Future<String> addCreditApplication({
    required String name,
    required String creditType,
    String? token,
  }) async {
    await Future.delayed(delay);
    _applications.add(
      CreditApplicationModel(
        id: _nextAppId++,
        userId: 1,
        name: name,
        creditType: creditType,
        applicationDate: DateTime.now().toIso8601String(),
      ),
    );
    return 'Tạo yêu cầu tín dụng thành công';
  }

  @override
  Future<String> deleteCreditApplication(
    int applicationId, {
    String? token,
  }) async {
    await Future.delayed(delay);
    final index = _applications.indexWhere((e) => e.id == applicationId);
    if (index == -1) {
      throw ApiException('Không tìm thấy tài khoản', statusCode: 404);
    }
    _applications.removeAt(index);
    return 'Đã xóa yêu cầu tín dụng thành công';
  }
}
