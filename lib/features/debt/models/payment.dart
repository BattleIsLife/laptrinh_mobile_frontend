class DebtPayment {
  final String id;
  final String debtId;
  final DateTime dueDate;
  final DateTime? paymentDate;
  final double amountDue; //số tiền phải trả
  final double amountPaid;
  final bool isLate;
  final int dayLate;
  final String status;
  final DateTime createdAt;
  DebtPayment({
    required this.id,
    required this.debtId,
    required this.dueDate,
    this.paymentDate,
    required this.amountDue,
    required this.amountPaid,
    required this.isLate,
    required this.dayLate,
    required this.status,
    required this.createdAt,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'debt_id': debtId,
      'due_date': dueDate.toIso8601String(),
      'payment_date': paymentDate?.toIso8601String(),
      'amount_due': amountDue,
      'amount_paid': amountPaid,
      'is_late': isLate,
      'day_late': dayLate,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DebtPayment.fromJson(Map<String, dynamic> json) {
    return DebtPayment(
      id: json['id'],
      debtId: json['debt_id'],
      dueDate: DateTime.parse(json['due_date']),
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
      amountDue: (json['amount_due'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0.0,
      isLate: json['is_late'] as bool? ?? false,
      dayLate: json['day_late'] as int? ?? 0,
      status: json['status'] ?? 'unpaid',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
