/// Represents a credit application entity in the system.
///
/// Follows the backend specification for `/api/credit_applications`:
/// - [creditType]: 'CREDIT_CARD' or 'OVERDRAFT'
class CreditApplication {
  final int id;
  final int userId;
  final String name;
  final String creditType;
  final DateTime applicationDate;

  const CreditApplication({
    required this.id,
    required this.userId,
    required this.name,
    required this.creditType,
    required this.applicationDate,
  });

  /// Factory constructor to parse JSON from backend.
  factory CreditApplication.fromJson(Map<String, dynamic> json) {
    return CreditApplication(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      creditType: json['credit_type'] as String? ?? 'CREDIT_CARD',
      applicationDate: json['application_date'] != null
          ? DateTime.tryParse(json['application_date'].toString()) ??
              DateTime.now()
          : DateTime.now(),
    );
  }

  /// Converts this entity into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'credit_type': creditType,
      'application_date': applicationDate.toIso8601String(),
    };
  }

  bool get isCreditCard => creditType.toUpperCase() == 'CREDIT_CARD';
  bool get isOverdraft => creditType.toUpperCase() == 'OVERDRAFT';

  String get creditTypeDisplay {
    switch (creditType.toUpperCase()) {
      case 'CREDIT_CARD':
        return 'Thẻ tín dụng';
      case 'OVERDRAFT':
        return 'Thấu chi';
      default:
        return creditType;
    }
  }

  String get formattedDate {
    final day = applicationDate.day.toString().padLeft(2, '0');
    final month = applicationDate.month.toString().padLeft(2, '0');
    final year = applicationDate.year.toString();
    final hour = applicationDate.hour.toString().padLeft(2, '0');
    final minute = applicationDate.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditApplication &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          name == other.name &&
          creditType == other.creditType;

  @override
  int get hashCode =>
      id.hashCode ^ userId.hashCode ^ name.hashCode ^ creditType.hashCode;
}
