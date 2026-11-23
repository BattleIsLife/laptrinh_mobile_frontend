
import 'dart:async';

import '../../../core/network/api_client.dart';
import '../models/expense_model.dart';

abstract class ExpenseService {
  factory ExpenseService({ApiClient? apiClient}) {
    return HttpExpenseService(apiClient: apiClient);
  }

  Future<List<ExpenseCategoryModel>> getCategories();

  Future<ExpenseModel> getExpenseById(int id);

  Future<Map<String, dynamic>> getExpenses({
    int page = 0,
    required int month,
    required int year,
  });

  Future<ExpenseStatisticModel> getStatistic({
    required int month,
    required int year,
  });

  Future<void> createExpense({
    required String amount,
    required String categoryId,
    required String transactionDate,
    String? description,
  });

  Future<void> updateExpense(
    int id, {
    required String amount,
    required String categoryId,
    required String transactionDate,
    String? description,
  });

  Future<void> deleteExpense(int id);
}

class HttpExpenseService implements ExpenseService {
  final ApiClient _apiClient;

  HttpExpenseService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(); 

@override
Future<List<ExpenseCategoryModel>> getCategories() async {
  final response = await _apiClient.get(
    '/api/expense_categories',
  );

  final rawList = response['data'] as List? ?? [];

  return rawList
      .map((e) => ExpenseCategoryModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ))
      .toList();
}

  @override
  Future<ExpenseModel> getExpenseById(int id) async {
    final response = await _apiClient.get('/api/expense/$id');
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return ExpenseModel.fromJson(data);
  }

  @override
  Future<Map<String, dynamic>> getExpenses({
    int page = 0,
    required int month,
    required int year,
  }) async {
    final response = await _apiClient.get(
      '/api/expense/',
      queryParams: {
        'page': page,
        'month': month,
        'year': year,
      },
    );

    final rawList = response['data'] as List? ?? [];

    final expenses = rawList
        .map(
          (e) => ExpenseModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();

    final totalItems = response['total_items'] is int
        ? response['total_items'] as int
        : int.tryParse(response['total_items']?.toString() ?? '') ??
            expenses.length;

    return {
      'expenses': expenses,
      'total_items': totalItems,
    };
  }

  @override
  Future<ExpenseStatisticModel> getStatistic({
    required int month,
    required int year,
  }) async {
    final response = await _apiClient.get(
      '/api/expense/statistic',
      queryParams: {
        'month': month,
        'year': year,
      },
    );

    return ExpenseStatisticModel.fromJson(response);
  }

  @override
  Future<void> createExpense({
    required String amount,
    required String categoryId,
    required String transactionDate,
    String? description,
  }) async {
    await _apiClient.post(
      '/api/expense/',
      body: {
        'amount': amount,
        'category_id': categoryId,
        'transaction_date': transactionDate,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
  }

  @override
  Future<void> updateExpense(
    int id, {
    required String amount,
    required String categoryId,
    required String transactionDate,
    String? description,
  }) async {
    await _apiClient.put(
      '/api/expense/$id',
      body: {
        'amount': amount,
        'category_id': categoryId,
        'transaction_date': transactionDate,
        if (description != null && description.isNotEmpty)
          'description': description ?? '',
      },
    );
  }

  @override
  Future<void> deleteExpense(int id) async {
    await _apiClient.delete('/api/expense/$id');
  }
}
