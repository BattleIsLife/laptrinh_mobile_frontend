import 'package:flutter/material.dart';

/// Represents an Asset entity in the system.
///
/// Follows backend specification for `/api/assets`:
/// [assetType] can be:
/// - 'REAL_ESTATE'
/// - 'VEHICLE'
/// - 'GOLD'
/// - 'STOCK'
/// - 'CASH'
/// - 'OTHER'
class Asset {
  final int id;
  final int userId;
  final String assetType;
  final String name;
  final double currentValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Asset({
    required this.id,
    required this.userId,
    required this.assetType,
    required this.name,
    required this.currentValue,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor to parse JSON from backend.
  /// Handles both string decimal representation (e.g. "200000000.00") and numeric values.
  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id'].toString()) ?? 0,
      assetType: (json['asset_type'] as String? ?? 'OTHER').toUpperCase(),
      name: json['name'] as String? ?? '',
      currentValue: _parseDouble(json['current_value']),
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
      'asset_type': assetType,
      'name': name,
      'current_value': currentValue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy with optionally replaced fields.
  Asset copyWith({
    int? id,
    int? userId,
    String? assetType,
    String? name,
    double? currentValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Asset(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      assetType: assetType ?? this.assetType,
      name: name ?? this.name,
      currentValue: currentValue ?? this.currentValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // --- Display Helpers ---

  /// Human-friendly display for asset type in Vietnamese.
  String get typeDisplay {
    switch (assetType.toUpperCase()) {
      case 'REAL_ESTATE':
        return 'Bất động sản';
      case 'VEHICLE':
        return 'Phương tiện';
      case 'GOLD':
        return 'Vàng & Kim loại quý';
      case 'STOCK':
        return 'Chứng khoán / Cổ phiếu';
      case 'CASH':
        return 'Tiền mặt & Tiết kiệm';
      case 'OTHER':
      default:
        return 'Tài sản khác';
    }
  }

  /// Icon corresponding to asset type.
  IconData get typeIcon {
    switch (assetType.toUpperCase()) {
      case 'REAL_ESTATE':
        return Icons.apartment_rounded;
      case 'VEHICLE':
        return Icons.directions_car_rounded;
      case 'GOLD':
        return Icons.monetization_on_rounded;
      case 'STOCK':
        return Icons.trending_up_rounded;
      case 'CASH':
        return Icons.account_balance_wallet_rounded;
      case 'OTHER':
      default:
        return Icons.category_rounded;
    }
  }

  /// Primary color theme corresponding to asset type.
  Color get typeColor {
    switch (assetType.toUpperCase()) {
      case 'REAL_ESTATE':
        return const Color(0xFFF59E0B); // Amber
      case 'VEHICLE':
        return const Color(0xFF3B82F6); // Blue
      case 'GOLD':
        return const Color(0xFFEAB308); // Gold Yellow
      case 'STOCK':
        return const Color(0xFF8B5CF6); // Purple
      case 'CASH':
        return const Color(0xFF10B981); // Emerald
      case 'OTHER':
      default:
        return const Color(0xFF64748B); // Slate
    }
  }

  /// Formatted creation date (DD/MM/YYYY HH:mm).
  String get formattedCreatedAt => _formatDateTime(createdAt);

  /// Formatted update date (DD/MM/YYYY HH:mm).
  String get formattedUpdatedAt => _formatDateTime(updatedAt);

  /// Formats VND amount with dot separator (e.g. 200.000.000 ₫).
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

  static String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
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
      other is Asset &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          assetType == other.assetType &&
          name == other.name &&
          currentValue == other.currentValue;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      assetType.hashCode ^
      name.hashCode ^
      currentValue.hashCode;
}
