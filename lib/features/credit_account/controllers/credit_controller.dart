import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../models/credit_account_model.dart';
import '../models/credit_application_model.dart';
import '../services/credit_service.dart';

/// Controller quản lý trạng thái và nghiệp vụ Tài khoản tín dụng & Yêu cầu mở tín dụng.
class CreditController extends ChangeNotifier {
  final CreditService _service;
  final String? token;

  List<CreditAccountModel> accounts = [];
  List<CreditApplicationModel> applications = [];
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  CreditController({CreditService? service, this.token})
      : _service = service ?? CreditService();

  // =============================
  // VALIDATION ĐƠN GIẢN THEO API
  // =============================

  static bool isValidDecimal2(String text) {
    final regex = RegExp(r'^\d+(\.\d{1,2})?$');
    return regex.hasMatch(text.trim());
  }

  // =============================
  // 1. TÀI KHOẢN TÍN DỤNG
  // =============================

  Future<void> fetchAccounts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      accounts = await _service.getCreditAccounts(token: token);
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Không thể tải danh sách tài khoản tín dụng.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAccount({
    required String accountType,
    required String bankName,
    required String creditLimitText,
    required String currentBalanceText,
  }) async {
    if (bankName.trim().isEmpty) {
      errorMessage = 'Vui lòng nhập tên ngân hàng';
      notifyListeners();
      return false;
    }
    if (!isValidDecimal2(creditLimitText)) {
      errorMessage =
          'Hạn mức tín dụng phải là 1 số thập phân không âm, tối đa 2 chữ số sau dấu phảy';
      notifyListeners();
      return false;
    }
    if (!isValidDecimal2(currentBalanceText)) {
      errorMessage =
          'Số dư tài khoản phải là 1 số thập phân không âm, tối đa 2 chữ số sau dấu phảy';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      successMessage = await _service.addCreditAccount(
        accountType: accountType,
        bankName: bankName.trim(),
        creditLimit: double.parse(creditLimitText.trim()),
        currentBalance: double.parse(currentBalanceText.trim()),
        token: token,
      );
      await fetchAccounts();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Lỗi khi thêm tài khoản tín dụng.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAccount({
    required int accountId,
    required String accountType,
    required String bankName,
    required String creditLimitText,
    required String currentBalanceText,
  }) async {
    if (bankName.trim().isEmpty) {
      errorMessage = 'Vui lòng nhập tên ngân hàng';
      notifyListeners();
      return false;
    }
    if (!isValidDecimal2(creditLimitText)) {
      errorMessage =
          'Hạn mức tín dụng phải là 1 số thập phân không âm, tối đa 2 chữ số sau dấu phảy';
      notifyListeners();
      return false;
    }
    if (!isValidDecimal2(currentBalanceText)) {
      errorMessage =
          'Số dư tài khoản phải là 1 số thập phân không âm, tối đa 2 chữ số sau dấu phảy';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      successMessage = await _service.updateCreditAccount(
        accountId: accountId,
        accountType: accountType,
        bankName: bankName.trim(),
        creditLimit: double.parse(creditLimitText.trim()),
        currentBalance: double.parse(currentBalanceText.trim()),
        token: token,
      );
      await fetchAccounts();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Lỗi khi cập nhật tài khoản tín dụng.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> closeAccount(int accountId) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      successMessage = await _service.closeCreditAccount(
        accountId,
        token: token,
      );
      await fetchAccounts();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Lỗi khi đóng tài khoản tín dụng.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // =============================
  // 2. YÊU CẦU MỞ TÍN DỤNG
  // =============================

  Future<void> fetchApplications() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      applications = await _service.getCreditApplications(token: token);
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Không thể tải danh sách yêu cầu mở tín dụng.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addApplication({
    required String name,
    required String creditType,
  }) async {
    if (name.trim().isEmpty) {
      errorMessage = 'Vui lòng nhập tên yêu cầu tín dụng';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      successMessage = await _service.addCreditApplication(
        name: name.trim(),
        creditType: creditType,
        token: token,
      );
      await fetchApplications();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Lỗi khi tạo yêu cầu mở tín dụng.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteApplication(int applicationId) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      successMessage = await _service.deleteCreditApplication(
        applicationId,
        token: token,
      );
      await fetchApplications();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Lỗi khi xóa yêu cầu mở tín dụng.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
