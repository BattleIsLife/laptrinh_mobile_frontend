import 'package:flutter/material.dart';

/// Represents a Saving Goal entity in the system.
///
/// Follows backend specification for `/api/savings`:
/// - [status]: 'ACTIVE', 'COMPLETED', 'CANCELLED'
class SavingGoal {
  final int id;
  final int userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final double monthlyContribution;
  final double interestRate;
  final DateTime targetDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.monthlyContribution,
    required this.interestRate,
    required this.targetDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor to parse JSON from backend.
  factory SavingGoal.fromJson(Map<String, dynamic> json) {
    return SavingGoal(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      targetAmount: _parseDouble(json['target_amount']),
      currentAmount: _parseDouble(json['current_amount']),
      monthlyContribution: _parseDouble(json['monthly_contribution']),
      interestRate: _parseDouble(json['interest_rate']),
      targetDate: json['target_date'] != null
          ? DateTime.tryParse(json['target_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: (json['status'] as String? ?? 'ACTIVE').toUpperCase(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Converts this entity into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'monthly_contribution': monthlyContribution,
      'interest_rate': interestRate,
      'target_date': _formatIsoDateOnly(targetDate),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy with optionally modified fields.
  SavingGoal copyWith({
    int? id,
    int? userId,
    String? name,
    double? targetAmount,
    double? currentAmount,
    double? monthlyContribution,
    double? interestRate,
    DateTime? targetDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      interestRate: interestRate ?? this.interestRate,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // --- Convenience Getters & Calculations ---

  bool get isActive => status == 'ACTIVE';
  bool get isCompleted => status == 'COMPLETED' || (targetAmount > 0 && currentAmount >= targetAmount);
  bool get isCancelled => status == 'CANCELLED';

  /// Remaining amount needed to reach the target
  double get remainingAmount {
    final remaining = targetAmount - currentAmount;
    return remaining > 0 ? remaining : 0.0;
  }

  /// Completion percentage from 0.0 to 1.0 (capped)
  double get progressRatio {
    if (targetAmount <= 0) return 0.0;
    final ratio = currentAmount / targetAmount;
    return ratio > 1.0 ? 1.0 : (ratio < 0.0 ? 0.0 : ratio);
  }

  /// Remaining days until target date
  int get remainingDays {
    final diff = targetDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  /// Estimated months remaining to achieve goal based on monthly contribution
  int get estimatedMonthsRemaining {
    if (monthlyContribution <= 0 || remainingAmount <= 0) return 0;
    return (remainingAmount / monthlyContribution).ceil();
  }

  /// Human-friendly status label in Vietnamese
  String get statusDisplay {
    if (currentAmount >= targetAmount && targetAmount > 0) {
      return 'Đã hoàn thành';
    }
    switch (status) {
      case 'ACTIVE':
        return 'Đang tiến hành';
      case 'COMPLETED':
        return 'Đã hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  /// Color associated with status
  Color get statusColor {
    if (currentAmount >= targetAmount && targetAmount > 0) {
      return const Color(0xFF10B981);
    }
    switch (status) {
      case 'ACTIVE':
        return const Color(0xFF2563EB); // Royal Blue
      case 'COMPLETED':
        return const Color(0xFF10B981); // Emerald
      case 'CANCELLED':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF64748B);
    }
  }

  /// Formatted target date (DD/MM/YYYY)
  String get formattedTargetDate => _formatDate(targetDate);

  /// Formatted creation date (DD/MM/YYYY)
  String get formattedCreatedAt => _formatDate(createdAt);

  /// Target date formatted as YYYY-MM-DD for backend requests
  String get apiTargetDate => _formatIsoDateOnly(targetDate);

  /// Formats VND currency (e.g. 10.000.000 ₫)
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

  static String _formatIsoDateOnly(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
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
      other is SavingGoal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          name == other.name &&
          targetAmount == other.targetAmount &&
          currentAmount == other.currentAmount &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      targetAmount.hashCode ^
      currentAmount.hashCode ^
      status.hashCode;
}
