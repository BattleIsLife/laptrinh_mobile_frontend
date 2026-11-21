import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../services/profile_service.dart';
import '../../../core/network/api_client.dart';

class ProfileController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Profile? _profile;
  Profile? get profile => _profile;
  bool _isSaving = false; // đang lưu hồ sơ
  bool get isSaving => _isSaving;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final ProfileService _profileservice;
  ProfileController({
    ProfileService? profileservice,
    String? token,
    bool? useMock,
  }) : _profileservice =
           profileservice ?? ProfileService(token: token, useMock: useMock);

  Future<void> loadprofile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _profile = await _profileservice.getProfile();
      // Cập nhật dữ liệu profile trong controller nếu cần
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } on ApiException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = "Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateprofile(Profile profile) async {
    try {
      _isSaving = true;
      _errorMessage = null;
      notifyListeners();
      _profile = await _profileservice.updateProfile(profile);
      return true;
    } on ApiException catch (e) {
      _isLoading = false;
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
