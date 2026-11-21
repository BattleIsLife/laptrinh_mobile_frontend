import 'package:flutter/material.dart';

import '../models/debt.dart';
import '../models/payment.dart';
import '../services/debt_service.dart';
import '../../../core/network/api_client.dart';

class ProfileController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Debt? _debt;
  Debt? get debt => _debt;
  DebtPayment? _payment;
  DebtPayment? get payment => _payment;
  bool _isSaving = false; // đang lưu hồ sơ
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final DebtService _debtservice;
  ProfileController({DebtService? debtservice})
    : _debtservice = debtservice ?? MockDebtService();

  Future<void> loaddebt() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _debt = await _debtservice.getDebt();
      // Cập nhật dữ liệu profile trong controller nếu cần
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = "Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadpayment() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _payment = await _debtservice.getPayment();
      // Cập nhật dữ liệu profile trong controller nếu cần
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = "Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> adddebt(Debt debt) async {
    try {
      _isSaving = true;
      _errorMessage = null;
      notifyListeners();
      _debt = await _debtservice.addDebt(debt);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.";
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
