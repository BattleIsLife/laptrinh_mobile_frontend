import 'dart:async';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../models/saving_goal.dart';

/// Contract for Savings Goal operations.
abstract class SavingService {
  /// Factory constructor returning [MockSavingService] or [HttpSavingService]
  /// based on configuration.
  factory SavingService({ApiClient? apiClient, bool? useMock}) {
    final shouldUseMock = useMock ?? ApiConfig.useMockService;
    if (shouldUseMock) {
      return MockSavingService();
    }
    return HttpSavingService(apiClient: apiClient);
  }

  Future<List<SavingGoal>> getSavings({
    int? page,
    int? month,
    int? year,
    String? token,
  });

  Future<SavingGoal> getSavingById(int savingId, {String? token});

  Future<String> addSaving({
    required String name,
    required double targetAmount,
    required double monthlyContribution,
    required String targetDate,
    required double interestRate,
    String? token,
  });

  Future<String> updateSaving({
    required int savingId,
    String? name,
    double? targetAmount,
    double? monthlyContribution,
    String? targetDate,
    double? interestRate,
    String? status,
    double? currentAmount,
    String? token,
  });

  Future<String> deleteSaving(int savingId, {String? token});
}

/// Real HTTP implementation connecting to Node.js backend.
class HttpSavingService implements SavingService {
  final ApiClient _apiClient;

  HttpSavingService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<SavingGoal>> getSavings({
    int? page,
    int? month,
    int? year,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (month != null && year != null) {
      queryParams['month'] = month;
      queryParams['year'] = year;
    }

    final response = await _apiClient.get(
      ApiConfig.savingsEndpoint,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      token: token,
    );

    final rawData = response['data'];
    if (rawData is List) {
      return rawData
          .map((item) => SavingGoal.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<SavingGoal> getSavingById(int savingId, {String? token}) async {
    final response = await _apiClient.get(
      ApiConfig.savingsEndpoint,
      queryParams: {'saving_id': savingId},
      token: token,
    );

    final rawData = response['data'];
    if (rawData is Map<String, dynamic>) {
      return SavingGoal.fromJson(rawData);
    } else if (rawData is List && rawData.isNotEmpty) {
      return SavingGoal.fromJson(rawData.first as Map<String, dynamic>);
    }
    throw ApiException('Không tìm thấy dữ liệu mục tiêu tiết kiệm');
  }

  @override
  Future<String> addSaving({
    required String name,
    required double targetAmount,
    required double monthlyContribution,
    required String targetDate,
    required double interestRate,
    String? token,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.savingsEndpoint,
      body: {
        'name': name,
        'target_amount': targetAmount,
        'monthly_contribution': monthlyContribution,
        'target_date': targetDate,
        'interest_rate': interestRate,
      },
      token: token,
    );

    return response['message'] as String? ??
        'Đã thêm mục tiêu tiết kiệm thành công';
  }

  @override
  Future<String> updateSaving({
    required int savingId,
    String? name,
    double? targetAmount,
    double? monthlyContribution,
    String? targetDate,
    double? interestRate,
    String? status,
    double? currentAmount,
    String? token,
  }) async {
    final body = <String, dynamic>{'saving_id': savingId};
    if (name != null) body['name'] = name;
    if (targetAmount != null) body['target_amount'] = targetAmount;
    if (monthlyContribution != null) {
      body['monthly_contribution'] = monthlyContribution;
    }
    if (targetDate != null) body['target_date'] = targetDate;
    if (interestRate != null) body['interest_rate'] = interestRate;
    if (status != null) body['status'] = status;
    if (currentAmount != null) body['current_amount'] = currentAmount;

    final response = await _apiClient.patch(
      ApiConfig.savingsEndpoint,
      body: body,
      token: token,
    );

    return response['message'] as String? ??
        'Đã sửa mục tiêu tiết kiệm thành công';
  }

  @override
  Future<String> deleteSaving(int savingId, {String? token}) async {
    final response = await _apiClient.delete(
      ApiConfig.savingsEndpoint,
      body: {'saving_id': savingId},
      token: token,
    );

    return response['message'] as String? ??
        'Đã xóa mục tiêu tiết kiệm thành công';
  }
}

/// In-memory mock service for testing, offline demo, and verification.
class MockSavingService implements SavingService {
  final Duration simulatedDelay;

  MockSavingService({this.simulatedDelay = const Duration(milliseconds: 400)});

  static final List<SavingGoal> _mockSavings = [
    SavingGoal(
      id: 1,
      userId: 1,
      name: 'Mua xe máy Honda SH 160i',
      targetAmount: 110000000.0,
      currentAmount: 45000000.0,
      monthlyContribution: 5000000.0,
      interestRate: 6.5,
      targetDate: DateTime.now().add(const Duration(days: 220)),
      status: 'ACTIVE',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    SavingGoal(
      id: 2,
      userId: 1,
      name: 'Quỹ tài chính khẩn cấp',
      targetAmount: 60000000.0,
      currentAmount: 60000000.0,
      monthlyContribution: 5000000.0,
      interestRate: 5.0,
      targetDate: DateTime.now().add(const Duration(days: 40)),
      status: 'COMPLETED',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    SavingGoal(
      id: 3,
      userId: 1,
      name: 'Chuyến du lịch Nhật Bản mùa xuân',
      targetAmount: 40000000.0,
      currentAmount: 18000000.0,
      monthlyContribution: 4000000.0,
      interestRate: 0.0,
      targetDate: DateTime.now().add(const Duration(days: 150)),
      status: 'ACTIVE',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SavingGoal(
      id: 4,
      userId: 1,
      name: 'Nâng cấp Macbook Pro M4',
      targetAmount: 55000000.0,
      currentAmount: 20000000.0,
      monthlyContribution: 6000000.0,
      interestRate: 0.0,
      targetDate: DateTime.now().add(const Duration(days: 90)),
      status: 'CANCELLED',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  @override
  Future<List<SavingGoal>> getSavings({
    int? page,
    int? month,
    int? year,
    String? token,
  }) async {
    await Future.delayed(simulatedDelay);
    List<SavingGoal> result = List.from(_mockSavings);

    if (month != null && year != null) {
      result = result
          .where(
            (s) => s.createdAt.month == month && s.createdAt.year == year,
          )
          .toList();
    }

    if (page != null && page > 0) {
      final startIndex = (page - 1) * 10;
      if (startIndex >= result.length) return [];
      final endIndex = (startIndex + 10).clamp(0, result.length);
      return result.sublist(startIndex, endIndex);
    }

    return result;
  }

  @override
  Future<SavingGoal> getSavingById(int savingId, {String? token}) async {
    await Future.delayed(simulatedDelay);
    final match = _mockSavings.where((s) => s.id == savingId);
    if (match.isEmpty) {
      throw ApiException('Không tìm thấy dữ liệu!');
    }
    return match.first;
  }

  @override
  Future<String> addSaving({
    required String name,
    required double targetAmount,
    required double monthlyContribution,
    required String targetDate,
    required double interestRate,
    String? token,
  }) async {
    await Future.delayed(simulatedDelay);
    final newId = _mockSavings.isEmpty
        ? 1
        : _mockSavings.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1;
    final now = DateTime.now();
    final parsedDate = DateTime.tryParse(targetDate) ??
        DateTime.now().add(const Duration(days: 180));

    final newGoal = SavingGoal(
      id: newId,
      userId: 1,
      name: name,
      targetAmount: targetAmount,
      currentAmount: 0.0,
      monthlyContribution: monthlyContribution,
      interestRate: interestRate,
      targetDate: parsedDate,
      status: 'ACTIVE',
      createdAt: now,
      updatedAt: now,
    );
    _mockSavings.add(newGoal);
    return 'Đã thêm mục tiêu tiết kiệm thành công';
  }

  @override
  Future<String> updateSaving({
    required int savingId,
    String? name,
    double? targetAmount,
    double? monthlyContribution,
    String? targetDate,
    double? interestRate,
    String? status,
    double? currentAmount,
    String? token,
  }) async {
    await Future.delayed(simulatedDelay);
    final index = _mockSavings.indexWhere((s) => s.id == savingId);
    if (index == -1) {
      throw ApiException('Mục tiêu tiết kiệm không tồn tại');
    }

    final current = _mockSavings[index];
    final parsedDate =
        targetDate != null ? DateTime.tryParse(targetDate) : null;

    final updatedAmount = currentAmount ?? current.currentAmount;
    final effectiveTarget = targetAmount ?? current.targetAmount;

    // Automatically mark as completed if target reached
    String newStatus = status ?? current.status;
    if (updatedAmount >= effectiveTarget && effectiveTarget > 0) {
      newStatus = 'COMPLETED';
    }

    _mockSavings[index] = current.copyWith(
      name: name,
      targetAmount: targetAmount,
      monthlyContribution: monthlyContribution,
      targetDate: parsedDate,
      interestRate: interestRate,
      status: newStatus,
      currentAmount: updatedAmount,
      updatedAt: DateTime.now(),
    );
    return 'Đã sửa mục tiêu tiết kiệm thành công';
  }

  @override
  Future<String> deleteSaving(int savingId, {String? token}) async {
    await Future.delayed(simulatedDelay);
    final index = _mockSavings.indexWhere((s) => s.id == savingId);
    if (index == -1) {
      throw ApiException('Xóa mục tiêu tiết kiệm thất bại!!');
    }
    _mockSavings.removeAt(index);
    return 'Đã xóa mục tiêu tiết kiệm thành công';
  }
}
