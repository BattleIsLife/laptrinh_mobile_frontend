import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/models/asset.dart';

void main() {
  group('Asset Model Tests', () {
    test('parses from backend JSON correctly with string decimal numbers', () {
      final json = {
        'id': 1,
        'user_id': 1,
        'asset_type': 'VEHICLE',
        'name': 'Lamborghini Huracan',
        'current_value': '15000000000.00',
        'created_at': '2026-11-10T09:47:40.000Z',
        'updated_at': '2026-11-10T10:23:57.000Z',
      };

      final asset = Asset.fromJson(json);

      expect(asset.id, 1);
      expect(asset.userId, 1);
      expect(asset.assetType, 'VEHICLE');
      expect(asset.name, 'Lamborghini Huracan');
      expect(asset.currentValue, 15000000000.0);
      expect(asset.typeDisplay, 'Phương tiện');
      expect(asset.formattedCreatedAt, isNotEmpty);
    });

    test('formatCurrency formats VND numbers with dot separators', () {
      expect(Asset.formatCurrency(200000000), '200.000.000 ₫');
      expect(Asset.formatCurrency(100000000), '100.000.000 ₫');
      expect(Asset.formatCurrency(0), '0 ₫');
    });

    test('displays correct labels and icons for all valid asset types', () {
      const types = [
        'REAL_ESTATE',
        'VEHICLE',
        'GOLD',
        'STOCK',
        'CASH',
        'OTHER',
      ];

      for (final type in types) {
        final asset = Asset(
          id: 1,
          userId: 1,
          assetType: type,
          name: 'Test',
          currentValue: 1000000,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(asset.typeDisplay.isNotEmpty, isTrue);
        expect(asset.typeIcon, isNotNull);
        expect(asset.typeColor, isNotNull);
      }
    });

    test('copyWith updates fields as expected', () {
      final original = Asset(
        id: 1,
        userId: 1,
        assetType: 'GOLD',
        name: 'Vàng 9999',
        currentValue: 100000000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(currentValue: 120000000);
      expect(updated.currentValue, 120000000);
      expect(updated.name, original.name);
      expect(updated.assetType, original.assetType);
    });
  });
}
