class IncomeModel {
  final int id;
  final String amount;
  final String source;
  final String incomeType;
  final String transactionDate;
  final String? description;

  IncomeModel({
    required this.id,
    required this.amount,
    required this.source,
    required this.incomeType,
    required this.transactionDate,
    this.description,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      amount: json['amount']?.toString() ?? '0',
      source: json['source']?.toString() ?? '',
      incomeType: json['income_type']?.toString() ?? 'OTHER',
      transactionDate: json['transaction_date']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'source': source,
      'income_type': incomeType,
      'transaction_date': transactionDate,
      'description': description,
    };
  }
}

class IncomeStatisticModel {
  final String totalIncome;
  final List<IncomeChartPoint> chartData;
  final Map<String, String> structure;

  IncomeStatisticModel({
    required this.totalIncome,
    required this.chartData,
    required this.structure,
  });

  factory IncomeStatisticModel.fromJson(Map<String, dynamic> json) {
    var rawData = json['data'] as List? ?? [];
    List<IncomeChartPoint> points = rawData.map((e) => IncomeChartPoint.fromJson(e)).toList();

    var rawStructure = json['structure'] as Map<String, dynamic>? ?? {};
    Map<String, String> structMap = rawStructure.map((key, value) => MapEntry(key, value.toString()));

    return IncomeStatisticModel(
      totalIncome: json['total_income']?.toString() ?? '0',
      chartData: points,
      structure: structMap,
    );
  }
}

class IncomeChartPoint {
  final String amount;
  final String date;

  IncomeChartPoint({required this.amount, required this.date});

  factory IncomeChartPoint.fromJson(Map<String, dynamic> json) {
    return IncomeChartPoint(
      amount: json['amount']?.toString() ?? '0',
      date: json['date']?.toString() ?? '',
    );
  }
}