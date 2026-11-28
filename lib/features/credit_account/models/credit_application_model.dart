/// Model đại diện cho 1 Yêu cầu mở tín dụng theo API /api/credit_applications.
class CreditApplicationModel {
  final int id;
  final int userId;
  final String name;
  final String creditType; // CREDIT_CARD hoặc OVERDRAFT
  final String applicationDate;

  const CreditApplicationModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.creditType,
    required this.applicationDate,
  });

  /// Tạo đối tượng từ JSON trả về của API.
  factory CreditApplicationModel.fromJson(Map<String, dynamic> json) {
    return CreditApplicationModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      creditType: json['credit_type']?.toString() ?? 'CREDIT_CARD',
      applicationDate: json['application_date']?.toString() ?? '',
    );
  }

  String get creditTypeLabel {
    if (creditType == 'OVERDRAFT') return 'Thấu chi';
    return 'Thẻ tín dụng';
  }
}
