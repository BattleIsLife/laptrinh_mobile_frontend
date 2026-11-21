class ExpenseModel {
  final int id;
  final String amount;
  final String? categoryId;
  final String categoryName;
  final String transactionDate;
  final String? description;

  const ExpenseModel({
    required this.id,
    required this.amount,
    this.categoryId,
    required this.categoryName,
    required this.transactionDate,
    this.description,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: (json['id'] as num?)?.toInt() ?? int.tryParse('${json['id'] ?? 0}') ?? 0,
      amount: (json['amount'] ?? '0').toString(),
      categoryId: json['category_id']?.toString(),
      categoryName: (json['category_name'] ?? '').toString(),
      transactionDate: (json['transaction_date'] ?? '').toString(),
      description: json['description']?.toString(),
    );
  }
}
class ExpenseCategoryModel {
  final String id;
  final String name;
  final String icon;
  final bool isEssential;

  const ExpenseCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.isEssential,
  });

  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    final essentialRaw = json['is_essential']?.toString().trim() ?? '0';
    return ExpenseCategoryModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
      isEssential: essentialRaw == '1' || essentialRaw.toLowerCase() == 'true',
    );
  }
}
class ExpenseChartPoint {
  final String amount;
  final String date;

  const ExpenseChartPoint({
    required this.amount,
    required this.date,
  });

  factory ExpenseChartPoint.fromJson(Map<String, dynamic> json) {
    return ExpenseChartPoint(
      amount: (json['amount'] ?? '0').toString(),
      date: (json['date'] ?? '').toString(),
    );
  }
}

class ExpenseStatisticModel {
  final String totalExpense;
  final List<ExpenseChartPoint> points;
  final Map<String, String> structure;
  final String essentialRate;

  const ExpenseStatisticModel({
    required this.totalExpense,
    required this.points,
    required this.structure,
    required this.essentialRate,
  });

  factory ExpenseStatisticModel.fromJson(Map<String, dynamic> json) {
    final rawPoints = (json['data'] as List<dynamic>?) ?? const [];
final points = rawPoints
    .whereType<Map<String, dynamic>>()
    .map((item) => ExpenseChartPoint.fromJson(item))
    .toList();

    final rawStructure = (json['structure'] as Map<String, dynamic>?) ?? const {};
    final structure = rawStructure.map(
      (k, v) => MapEntry(k.toString(), v.toString()),
    );

    final essentialRaw =
        json['essential rate'] ?? json['essential_rate'] ?? json['essentialRate'] ?? '80';

    return ExpenseStatisticModel(
      totalExpense: (json['total_expense'] ?? '0').toString(),
      points: points,
      structure: structure,
      essentialRate: essentialRaw.toString(),
    );
  }
  
}