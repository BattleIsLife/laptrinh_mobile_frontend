import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/asset.dart';

/// Summary card showing total portfolio valuation and category breakdown.
class AssetStatCard extends StatelessWidget {
  final double totalValue;
  final int totalCount;
  final Map<String, double> valuationByType;

  const AssetStatCard({
    super.key,
    required this.totalValue,
    required this.totalCount,
    required this.valuationByType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.account_balance_outlined,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Tổng giá trị tài sản',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$totalCount tài sản',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Big Total Valuation Display
          Text(
            Asset.formatCurrency(totalValue),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 16),

          // Colored Distribution Bar
          if (totalValue > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 8,
                child: Row(
                  children: _buildDistributionSegments(),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Legend Chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _buildLegendItems(),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildDistributionSegments() {
    final segments = <Widget>[];
    valuationByType.forEach((type, val) {
      if (val > 0) {
        final flex = (val / totalValue * 1000).round();
        if (flex > 0) {
          final dummyAsset = Asset(
            id: 0,
            userId: 0,
            assetType: type,
            name: '',
            currentValue: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          segments.add(
            Expanded(
              flex: flex,
              child: Container(color: dummyAsset.typeColor),
            ),
          );
        }
      }
    });
    return segments;
  }

  List<Widget> _buildLegendItems() {
    final items = <Widget>[];
    valuationByType.forEach((type, val) {
      if (val > 0) {
        final dummyAsset = Asset(
          id: 0,
          userId: 0,
          assetType: type,
          name: '',
          currentValue: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final percent = (val / totalValue * 100).toStringAsFixed(1);

        items.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dummyAsset.typeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${dummyAsset.typeDisplay} ($percent%)',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }
    });
    return items;
  }
}
