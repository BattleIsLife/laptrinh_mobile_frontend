
import 'dart:async';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../models/income_model.dart';

abstract class IncomeService {
  factory IncomeService({ApiClient? apiClient, bool? useMock}) {
    final shouldUseMock = useMock ?? ApiConfig.useMockService;

    if (shouldUseMock) {
      return MockIncomeService();
    }

    return HttpIncomeService(apiClient: apiClient);
  }

  Future<IncomeModel> getIncomeById(int id);

  Future<Map<String, dynamic>> getIncomes({
    int page = 0,
    required int month,
    required int year,
  });

  Future<IncomeStatisticModel> getIncomeStatistic({
    required int month,
    required int year,
  });

  Future<void> createIncome(IncomeModel income);

  Future<void> updateIncome(int id, IncomeModel income);

  Future<void> deleteIncome(int id);
}

// ======================================================
// HTTP INCOME SERVICE
// ======================================================

class HttpIncomeService implements IncomeService {
  final ApiClient _apiClient;

  HttpIncomeService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<IncomeModel> getIncomeById(int id) async {
    final response = await _apiClient.get('/api/income/$id');

    final data = response['data'] as Map<String, dynamic>? ?? response;

    return IncomeModel.fromJson(data);
  }

  @override
  Future<Map<String, dynamic>> getIncomes({
    int page = 0,
    required int month,
    required int year,
  }) async {
    final response = await _apiClient.get(
      '/api/income?page=$page&month=$month&year=$year',
    );

    final rawList = response['data'] as List? ?? [];

    final incomes = rawList
        .map(
          (e) => IncomeModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();

    final totalItems = response['total_items'] is int
        ? response['total_items'] as int
        : int.tryParse(
              response['total_items']?.toString() ?? '',
            ) ??
            incomes.length;

    return {
      'incomes': incomes,
      'total_items': totalItems,
    };
  }

  @override
  Future<IncomeStatisticModel> getIncomeStatistic({
    required int month,
    required int year,
  }) async {
    final response = await _apiClient.get(
      '/api/income/statistic?month=$month&year=$year',
    );

    return IncomeStatisticModel.fromJson(response);
  }

  @override
  Future<void> createIncome(IncomeModel income) async {
    await _apiClient.post(
      '/api/income/',
      body: income.toJson(),
    );
  }

  @override
  Future<void> updateIncome(int id, IncomeModel income) async {
    await _apiClient.put(
      '/api/income/$id',
      body: income.toJson(),
    );
  }

  @override
  Future<void> deleteIncome(int id) async {
    await _apiClient.delete('/api/income/$id');
  }
}

// ======================================================
// MOCK INCOME SERVICE
// ======================================================

class MockIncomeService implements IncomeService {
  final Duration simulatedDelay;

  MockIncomeService({
    this.simulatedDelay = const Duration(milliseconds: 500),
  });

  final List<IncomeModel> _mockItems = [
    IncomeModel(
      id: 1,
      amount: '15000000.00',
      source: 'Lương tháng',
      incomeType: 'SALARY',
      transactionDate: '2026-11-05',
      description: 'Chuyển khoản định kỳ',
    ),
    IncomeModel(
      id: 2,
      amount: '5000000.00',
      source: 'Làm thêm',
      incomeType: 'BUSINESS',
      transactionDate: '2026-11-08',
      description: 'Khách hàng tự do',
    ),
    IncomeModel(
      id: 3,
      amount: '3000000.00',
      source: 'Thưởng dự án',
      incomeType: 'OTHER',
      transactionDate: '2026-11-12',
      description: 'Đột xuất theo KPI',
    ),
    IncomeModel(
      id: 4,
      amount: '2000000.00',
      source: 'Đầu tư',
      incomeType: 'INVESTMENT',
      transactionDate: '2026-11-15',
      description: 'Lợi tức quỹ định kỳ',
    ),
  ];

  Future<void> _delay() async {
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }
  }

  @override
  Future<IncomeModel> getIncomeById(int id) async {
    await _delay();

    return _mockItems.firstWhere(
      (item) => item.id == id,
      orElse: () => throw ApiException(
        'Không tìm thấy giao dịch thu nhập',
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> getIncomes({
    int page = 0,
    required int month,
    required int year,
  }) async {
    await _delay();

    return {
      'incomes': List<IncomeModel>.from(_mockItems),
      'total_items': _mockItems.length,
    };
  }

  @override
  Future<IncomeStatisticModel> getIncomeStatistic({
    required int month,
    required int year,
  }) async {
    await _delay();

    return IncomeStatisticModel(
      totalIncome: '25000000.00',
      chartData: [
        IncomeChartPoint(
          amount: '15000000.00',
          date: '$year-${month.toString().padLeft(2, '0')}-05',
        ),
        IncomeChartPoint(
          amount: '5000000.00',
          date: '$year-${month.toString().padLeft(2, '0')}-08',
        ),
        IncomeChartPoint(
          amount: '3000000.00',
          date: '$year-${month.toString().padLeft(2, '0')}-12',
        ),
        IncomeChartPoint(
          amount: '2000000.00',
          date: '$year-${month.toString().padLeft(2, '0')}-15',
        ),
      ],
      structure: {
        'SALARY': '60',
        'BUSINESS': '20',
        'OTHER': '12',
        'INVESTMENT': '8',
      },
    );
  }

  @override
  Future<void> createIncome(IncomeModel income) async {
    await _delay();

    final nextId = _mockItems.isEmpty
        ? 1
        : _mockItems
                .map((e) => e.id)
                .reduce((a, b) => a > b ? a : b) +
            1;

    _mockItems.insert(
      0,
      IncomeModel(
        id: nextId,
        amount: income.amount,
        source: income.source,
        incomeType: income.incomeType,
        transactionDate: income.transactionDate,
        description: income.description,
      ),
    );
  }

  @override
  Future<void> updateIncome(int id, IncomeModel income) async {
    await _delay();

    final idx = _mockItems.indexWhere((e) => e.id == id);

    if (idx == -1) {
      throw ApiException(
        'Không tìm thấy giao dịch thu nhập để cập nhật',
      );
    }

    _mockItems[idx] = IncomeModel(
      id: id,
      amount: income.amount,
      source: income.source,
      incomeType: income.incomeType,
      transactionDate: income.transactionDate,
      description: income.description,
    );
  }

  @override
  Future<void> deleteIncome(int id) async {
    await _delay();

    _mockItems.removeWhere((e) => e.id == id);
  }
}
