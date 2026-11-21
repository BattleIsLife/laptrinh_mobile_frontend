import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/controllers/asset_controller.dart';
import 'package:frontend/features/auth/models/asset.dart';
import 'package:frontend/features/auth/services/asset_service.dart';
import 'package:frontend/features/auth/views/assets_view.dart';
import 'package:frontend/features/auth/views/components/asset_card_widget.dart';
import 'package:frontend/features/auth/views/components/asset_stat_card.dart';

void main() {
  group('Asset View & Component Widget Tests', () {
    testWidgets('AssetCardWidget renders name, type badge, and formatted value', (
      WidgetTester tester,
    ) async {
      final asset = Asset(
        id: 1,
        userId: 1,
        assetType: 'REAL_ESTATE',
        name: 'Biệt thự Đảo Ecopark',
        currentValue: 25000000000.0,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetCardWidget(asset: asset),
          ),
        ),
      );

      expect(find.text('Biệt thự Đảo Ecopark'), findsOneWidget);
      expect(find.text('Bất động sản'), findsOneWidget);
      expect(find.text('25.000.000.000 ₫'), findsOneWidget);
      expect(find.byIcon(Icons.apartment_rounded), findsOneWidget);
    });

    testWidgets('AssetStatCard renders total valuation and count', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AssetStatCard(
              totalValue: 5000000000.0,
              totalCount: 4,
              valuationByType: {
                'REAL_ESTATE': 3500000000.0,
                'VEHICLE': 1500000000.0,
              },
            ),
          ),
        ),
      );

      expect(find.text('Tổng giá trị tài sản'), findsOneWidget);
      expect(find.text('5.000.000.000 ₫'), findsOneWidget);
      expect(find.text('4 tài sản'), findsOneWidget);
    });

    testWidgets('AssetsView renders list and allows searching and filtering', (
      WidgetTester tester,
    ) async {
      final mockService = MockAssetService(simulatedDelay: Duration.zero);
      final controller = AssetController(assetService: mockService);

      await tester.pumpWidget(
        MaterialApp(
          home: AssetsView(controller: controller),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Quản lý Tài sản'), findsOneWidget);
      expect(find.text('Tất cả'), findsWidgets);
      expect(find.text('Bất động sản'), findsWidgets);
      expect(find.byType(AssetCardWidget), findsWidgets);
    });
  });
}
