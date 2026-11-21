import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/controllers/asset_controller.dart';
import 'package:frontend/features/auth/services/asset_service.dart';

void main() {
  group('AssetController (MVC Logic Tests)', () {
    late AssetController controller;
    late MockAssetService mockService;

    setUp(() {
      mockService = MockAssetService(simulatedDelay: Duration.zero);
      controller = AssetController(assetService: mockService);
    });

    test('fetchAssets loads initial assets list and calculates valuation', () async {
      await controller.fetchAssets();

      expect(controller.assets.isNotEmpty, isTrue);
      expect(controller.totalAssetValue, greaterThan(0));
      expect(controller.totalAssetCount, equals(controller.assets.length));
      expect(controller.valuationByType.isNotEmpty, isTrue);
    });

    test('filter by asset type and search query', () async {
      await controller.fetchAssets();

      // Filter by REAL_ESTATE
      controller.setTypeFilter('REAL_ESTATE');
      expect(
        controller.filteredAssets.every((a) => a.assetType == 'REAL_ESTATE'),
        isTrue,
      );

      // Filter by VEHICLE
      controller.setTypeFilter('VEHICLE');
      expect(
        controller.filteredAssets.every((a) => a.assetType == 'VEHICLE'),
        isTrue,
      );

      // Search query
      controller.setTypeFilter('ALL');
      controller.setSearchQuery('vinhomes');
      expect(
        controller.filteredAssets.every(
          (a) => a.name.toLowerCase().contains('vinhomes'),
        ),
        isTrue,
      );
    });

    test('addAsset validates inputs and adds new asset', () async {
      final success = await controller.addAsset(
        assetType: 'VEHICLE',
        name: 'Lamborghini Urus',
        currentValue: 18000000000.0,
      );

      expect(success, isTrue);
      expect(controller.successMessage, isNotNull);
      expect(
        controller.assets.any((a) => a.name == 'Lamborghini Urus'),
        isTrue,
      );
    });

    test('updateAsset updates existing asset information', () async {
      await controller.fetchAssets();
      final target = controller.assets.first;

      final success = await controller.updateAsset(
        assetId: target.id,
        name: 'Tên tài sản mới',
        currentValue: 999999999.0,
      );

      expect(success, isTrue);
      final updated = controller.assets.firstWhere((a) => a.id == target.id);
      expect(updated.name, 'Tên tài sản mới');
      expect(updated.currentValue, 999999999.0);
    });

    test('deleteAsset removes asset from collection', () async {
      await controller.fetchAssets();
      final initialCount = controller.assets.length;
      final target = controller.assets.first;

      final success = await controller.deleteAsset(target.id);

      expect(success, isTrue);
      expect(controller.assets.length, initialCount - 1);
      expect(controller.assets.any((a) => a.id == target.id), isFalse);
    });

    test('validation rules strictly match backend specifications', () {
      // Type validation
      expect(AssetController.validateAssetType('INVALID_TYPE'), isNotNull);
      expect(AssetController.validateAssetType(''), isNotNull);
      expect(AssetController.validateAssetType('REAL_ESTATE'), isNull);
      expect(AssetController.validateAssetType('VEHICLE'), isNull);
      expect(AssetController.validateAssetType('GOLD'), isNull);
      expect(AssetController.validateAssetType('STOCK'), isNull);
      expect(AssetController.validateAssetType('CASH'), isNull);
      expect(AssetController.validateAssetType('OTHER'), isNull);

      // Name validation
      expect(AssetController.validateAssetName(''), isNotNull);
      expect(AssetController.validateAssetName('   '), isNotNull);
      expect(AssetController.validateAssetName('Nhà đất'), isNull);

      // Value validation (must be positive > 0)
      expect(AssetController.validateCurrentValue('0'), isNotNull);
      expect(AssetController.validateCurrentValue('-1000'), isNotNull);
      expect(AssetController.validateCurrentValue('abc'), isNotNull);
      expect(AssetController.validateCurrentValue('100000000'), isNull);
    });
  });
}
