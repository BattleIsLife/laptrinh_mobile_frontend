
import '../../../core/network/api_client.dart';
import '../models/income_model.dart';

abstract class IncomeService {
  factory IncomeService({ApiClient? apiClient}) {
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
      '/api/income',
      queryParams: {
        'page': page,
        'month': month,
        'year': year,
      },
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
        : int.tryParse(response['total_items']?.toString() ?? '') ??
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
      '/api/income/statistic',
      queryParams: {
        'month': month,
        'year': year,
      },
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
