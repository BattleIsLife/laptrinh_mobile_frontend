class Debt {
  final String id;
  final String userId;
  final String lenderName;
  final String debtType;
  final double totalAmount;
  final double remainingAmount;
  final double? creditLimit;
  final double monthlyPayment;
  final double interestRate;
  final DateTime startDate;
  final DateTime endDate;
  final int dueDayOfMonth;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  Debt({
    required this.id,
    required this.userId,
    required this.lenderName,
    required this.debtType,
    required this.totalAmount,
    required this.remainingAmount,
    this.creditLimit,
    required this.monthlyPayment,
    required this.interestRate,
    required this.startDate,
    required this.endDate,
    required this.dueDayOfMonth,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  //kiểm tra đã tất toán chưa
  bool get isSettled => status == 'settled' || remainingAmount <= 0;
  // số tiền gốc đã trả
  double get paidAmount =>
      (totalAmount - remainingAmount).clamp(0.0, totalAmount);
  //tỷ lệ đã trả
  double get paidProgress =>
      totalAmount > 0 ? (paidAmount / totalAmount).clamp(0.0, 1.0) : 0.0;
  // Phần trăm hiển thị số nguyên (VD: 25%)
  int get paidPercentage => (paidProgress * 100).round();
  // Tổng số tháng của hợp đồng (VD: 36 tháng)
  int get totalMonths =>
      ((endDate.year - startDate.year) * 12 + endDate.month - startDate.month)
          .clamp(1, 999);

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      userId: json['user_id'],
      lenderName: json['lender_name'] ?? '',
      debtType: json['debt_type'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remaining_amount'] as num?)?.toDouble() ?? 0.0,
      creditLimit: (json['credit_limit'] as num?)?.toDouble(),
      monthlyPayment: (json['monthly_payment'] as num?)?.toDouble() ?? 0.0,
      interestRate: (json['interest_rate'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      dueDayOfMonth: json['due_day_of_month'] as int? ?? 1,
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lender_name': lenderName,
      'debt_type': debtType,
      'total_amount': totalAmount,
      'remaining_amount': remainingAmount,
      'credit_limit': creditLimit,
      'monthly_payment': monthlyPayment,
      'interest_rate': interestRate,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'due_day_of_month': dueDayOfMonth,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
