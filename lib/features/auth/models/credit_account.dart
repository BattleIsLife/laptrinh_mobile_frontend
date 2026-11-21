/// Represents a credit account entity in the system.
///
/// Follows the backend specification for `/api/credit_accounts`:
/// - [accountType]: 'CREDIT_CARD' or 'OVERDRAFT'
/// - [status]: 'ACTIVE' or 'CLOSED'
class CreditAccount {
  final int id;
  final int userId;
  final String accountType;
  final String bankName;
  final double creditLimit;
  final double currentBalance;
  final DateTime openedDate;
  final DateTime? closedDate;
  final String status;

  const CreditAccount({
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

  /// Factory constructor to parse JSON from backend.
  /// Handles numeric and string representations of decimal numbers.
  factory CreditAccount.fromJson(Map<String, dynamic> json) {
    return CreditAccount(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id'].toString()) ?? 0,
      accountType: json['account_type'] as String? ?? 'CREDIT_CARD',
      bankName: json['bank_name'] as String? ?? '',
      creditLimit: _parseDouble(json['credit_limit']),
      currentBalance: _parseDouble(json['current_balance']),
      openedDate: json['opened_date'] != null
          ? DateTime.tryParse(json['opened_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      closedDate: json['closed_date'] != null
          ? DateTime.tryParse(json['closed_date'].toString())
          : null,
      status: (json['status'] as String? ?? 'ACTIVE').toUpperCase(),
    );
  }

  /// Converts this entity into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_type': accountType,
      'bank_name': bankName,
      'credit_limit': creditLimit,
      'current_balance': currentBalance,
      'opened_date': openedDate.toIso8601String(),
      'closed_date': closedDate?.toIso8601String(),
      'status': status,
    };
  }

  /// Creates a copy of this [CreditAccount] with the given fields replaced.
  CreditAccount copyWith({
    int? id,
    int? userId,
    String? accountType,
    String? bankName,
    double? creditLimit,
    double? currentBalance,
    DateTime? openedDate,
    DateTime? closedDate,
    String? status,
  }) {
    return CreditAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountType: accountType ?? this.accountType,
      bankName: bankName ?? this.bankName,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      openedDate: openedDate ?? this.openedDate,
      closedDate: closedDate ?? this.closedDate,
      status: status ?? this.status,
    );
  }

  // --- Convenience Getters ---

  bool get isActive => status == 'ACTIVE';
  bool get isClosed => status == 'CLOSED';

  bool get isCreditCard => accountType == 'CREDIT_CARD';
  bool get isOverdraft => accountType == 'OVERDRAFT';

  /// Remaining available credit limit
  double get availableLimit {
    final available = creditLimit - currentBalance;
    return available > 0 ? available : 0;
  }

  /// Utilization percentage from 0.0 to 1.0 (capped)
  double get utilizationPercentage {
    if (creditLimit <= 0) return 0.0;
    final ratio = currentBalance / creditLimit;
    return ratio > 1.0 ? 1.0 : (ratio < 0 ? 0.0 : ratio);
  }

  /// Human-friendly display for account type
  String get accountTypeDisplay {
    switch (accountType.toUpperCase()) {
      case 'CREDIT_CARD':
        return 'Thẻ tín dụng';
      case 'OVERDRAFT':
        return 'Thấu chi';
      default:
        return accountType;
    }
  }

  /// Human-friendly display for account status
  String get statusDisplay {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Đang hoạt động';
      case 'CLOSED':
        return 'Đã đóng';
      default:
        return status;
    }
  }

  /// Formatted opened date (DD/MM/YYYY)
  String get formattedOpenedDate => _formatDate(openedDate);

  /// Formatted closed date (DD/MM/YYYY)
  String? get formattedClosedDate =>
      closedDate != null ? _formatDate(closedDate!) : null;

  /// Formats VND amount with dot separator (e.g. 5.000.000 ₫)
  static String formatCurrency(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs().round();
    final str = absAmount.toString();
    final buffer = StringBuffer();
    final len = str.length;

    for (int i = 0; i < len; i++) {
      buffer.write(str[i]);
      final remaining = len - 1 - i;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    final formatted = buffer.toString();
    return isNegative ? '-$formatted ₫' : '$formatted ₫';
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditAccount &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          accountType == other.accountType &&
          bankName == other.bankName &&
          creditLimit == other.creditLimit &&
          currentBalance == other.currentBalance &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      accountType.hashCode ^
      bankName.hashCode ^
      creditLimit.hashCode ^
      currentBalance.hashCode ^
      status.hashCode;
}
