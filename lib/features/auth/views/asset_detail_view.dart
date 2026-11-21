import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/asset_controller.dart';
import '../models/asset.dart';
import 'add_edit_asset_view.dart';
import 'components/asset_card_widget.dart';

/// Screen displaying in-depth details of a specific asset.
class AssetDetailView extends StatefulWidget {
  final int assetId;
  final AssetController controller;

  const AssetDetailView({
    super.key,
    required this.assetId,
    required this.controller,
  });

  @override
  State<AssetDetailView> createState() => _AssetDetailViewState();
}

class _AssetDetailViewState extends State<AssetDetailView> {
  Asset? _asset;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    final asset = await widget.controller.fetchAssetDetail(widget.assetId);
    if (mounted) {
      setState(() {
        _asset = asset;
        _isLoading = false;
      });
    }
  }

  void _onEditAsset() async {
    if (_asset == null) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditAssetView(
          controller: widget.controller,
          assetToEdit: _asset,
        ),
      ),
    );

    if (updated == true && mounted) {
      _loadDetail();
    }
  }

  void _confirmDeleteAsset() {
    if (_asset == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
            SizedBox(width: 8),
            Text('Xóa tài sản'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa tài sản "${_asset!.name}" khỏi danh mục không?\n\n'
          'Hành động này sẽ xóa dữ liệu tài sản vĩnh viễn khỏi hệ thống.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await widget.controller.deleteAsset(widget.assetId);
              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.controller.successMessage ?? 'Đã xóa tài sản',
                    ),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.controller.errorMessage ?? 'Không thể xóa tài sản',
                    ),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Đồng ý xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết tài sản'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: _loadDetail,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _asset == null
              ? _buildErrorView()
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Asset Card Representation
                          AssetCardWidget(
                            asset: _asset!,
                            onEdit: _onEditAsset,
                            onDelete: _confirmDeleteAsset,
                          ),

                          const SizedBox(height: 20),

                          // Asset Specification Details
                          _buildAssetSpecsCard(),

                          const SizedBox(height: 28),

                          // Actions
                          AppButton(
                            text: 'Chỉnh sửa tài sản',
                            icon: Icons.edit,
                            onPressed: _onEditAsset,
                          ),

                          const SizedBox(height: 12),

                          OutlinedButton.icon(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppTheme.errorColor,
                            ),
                            label: const Text(
                              'Xóa tài sản',
                              style: TextStyle(
                                color: AppTheme.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppTheme.errorColor,
                              ),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _confirmDeleteAsset,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildAssetSpecsCard() {
    final asset = _asset!;
    final totalPortfolio = widget.controller.totalAssetValue;
    final proportion = totalPortfolio > 0
        ? (asset.currentValue / totalPortfolio * 100).toStringAsFixed(1)
        : '100.0';

    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin chi tiết',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Mã tài sản:', '#${asset.id}'),
            const Divider(color: AppTheme.borderColor, height: 20),
            _buildDetailRow('Tên tài sản:', asset.name, isBold: true),
            const Divider(color: AppTheme.borderColor, height: 20),
            _buildDetailRow(
              'Loại tài sản:',
              asset.typeDisplay,
              valueColor: asset.typeColor,
            ),
            const Divider(color: AppTheme.borderColor, height: 20),
            _buildDetailRow(
              'Giá trị hiện tại:',
              Asset.formatCurrency(asset.currentValue),
              valueColor: AppTheme.primaryColor,
              isBold: true,
            ),
            const Divider(color: AppTheme.borderColor, height: 20),
            _buildDetailRow(
              'Tỷ trọng trong danh mục:',
              '$proportion%',
              valueColor: asset.typeColor,
            ),
            const Divider(color: AppTheme.borderColor, height: 20),
            _buildDetailRow('Thời điểm ghi nhận:', asset.formattedCreatedAt),
            const Divider(color: AppTheme.borderColor, height: 20),
            _buildDetailRow('Cập nhật lần cuối:', asset.formattedUpdatedAt),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              widget.controller.errorMessage ??
                  'Không tìm thấy thông tin tài sản',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadDetail,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
