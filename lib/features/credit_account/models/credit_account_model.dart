/// Model đại diện cho 1 Tài khoản tín dụng theo API /api/credit_accounts.
class CreditAccountModel {
  final int id;
  final int userId;
  final String accountType; // CREDIT_CARD hoặc OVERDRAFT
  final String bankName;
  final double creditLimit;
  final double currentBalance;
  final String openedDate;
  final String? closedDate;
  final String status; // ACTIVE hoặc CLOSED

  const CreditAccountModel({
    required this.id,
    required this.userId,
    required this.accountType,
    required this.bankName,
    required this.creditLimit,
    required this.currentBalance,
    required this.openedDate,
    this.closedDate,
    required this.status,
  });

  /// Tạo đối tượng từ JSON trả về của API.
  factory CreditAccountModel.fromJson(Map<String, dynamic> json) {
    return CreditAccountModel(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      accountType: json['account_type']?.toString() ?? 'CREDIT_CARD',
      bankName: json['bank_name']?.toString() ?? '',
      creditLimit: _toDouble(json['credit_limit']),
      currentBalance: _toDouble(json['current_balance']),
      openedDate: json['opened_date']?.toString() ?? '',
      closedDate: json['closed_date']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  String get accountTypeLabel {
    if (accountType == 'OVERDRAFT') return 'Thấu chi';
    return 'Thẻ tín dụng';
  }
}
