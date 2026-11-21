import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/asset_controller.dart';
import '../models/asset.dart';
import 'add_edit_asset_view.dart';
import 'asset_detail_view.dart';
import 'components/asset_card_widget.dart';
import 'components/asset_stat_card.dart';

/// Main screen for Asset Management (Quản lý tài sản).
/// Follows MVC: Observes [AssetController] for state updates.
class AssetsView extends StatefulWidget {
  final String? token;
  final AssetController? controller;

  const AssetsView({super.key, this.token, this.controller});

  @override
  State<AssetsView> createState() => _AssetsViewState();
}

class _AssetsViewState extends State<AssetsView> {
  late final AssetController _controller;
  bool _ownsController = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = AssetController(token: widget.token);
      _ownsController = true;
    }

    if (widget.token != null) {
      _controller.setToken(widget.token);
    }

    _controller.fetchAssets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _navigateToAddAsset() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditAssetView(controller: _controller),
      ),
    );

    if (added == true && mounted) {
      _controller.fetchAssets();
    }
  }

  void _navigateToDetail(Asset asset) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AssetDetailView(
          assetId: asset.id,
          controller: _controller,
        ),
      ),
    );

    if (changed == true && mounted) {
      _controller.fetchAssets();
    }
  }

  void _navigateToEdit(Asset asset) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditAssetView(
          controller: _controller,
          assetToEdit: asset,
        ),
      ),
    );

    if (updated == true && mounted) {
      _controller.fetchAssets();
    }
  }

  void _confirmDeleteAsset(Asset asset) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa tài sản'),
        content: Text('Bạn có chắc chắn muốn xóa "${asset.name}" không?'),
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
              final success = await _controller.deleteAsset(asset.id);
              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _controller.successMessage ?? 'Đã xóa tài sản',
                    ),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _controller.errorMessage ?? 'Không thể xóa tài sản',
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

  void _showMonthYearFilterDialog() async {
    int selectedMonth = _controller.filterMonth ?? DateTime.now().month;
    int selectedYear = _controller.filterYear ?? DateTime.now().year;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Lọc theo tháng ghi nhận'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selectedMonth,
                  decoration: const InputDecoration(labelText: 'Tháng'),
                  items: List.generate(
                    12,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text('Tháng ${i + 1}'),
                    ),
                  ),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedMonth = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: selectedYear,
                  decoration: const InputDecoration(labelText: 'Năm'),
                  items: [2024, 2025, 2026, 2027].map(
                    (y) => DropdownMenuItem(
                      value: y,
                      child: Text('Năm $y'),
                    ),
                  ).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedYear = val);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _controller.clearDateFilter();
                  Navigator.of(ctx).pop(false);
                },
                child: const Text('Bỏ lọc'),
              ),
              ElevatedButton(
                onPressed: () {
                  _controller.setDateFilter(selectedMonth, selectedYear);
                  Navigator.of(ctx).pop(true);
                },
                child: const Text('Áp dụng'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Tài sản'),
        actions: [
          IconButton(
            icon: Icon(
              _controller.filterMonth != null
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
              color: _controller.filterMonth != null
                  ? AppTheme.primaryColor
                  : null,
            ),
            tooltip: 'Lọc theo tháng/năm',
            onPressed: _showMonthYearFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: _controller.fetchAssets,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final assets = _controller.filteredAssets;

          return RefreshIndicator(
            onRefresh: _controller.fetchAssets,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Portfolio Stat Summary
                AssetStatCard(
                  totalValue: _controller.totalAssetValue,
                  totalCount: _controller.totalAssetCount,
                  valuationByType: _controller.valuationByType,
                ),

                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm tên tài sản, danh mục...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _controller.setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Type Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTypeFilterChip('Tất cả', 'ALL'),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip('Bất động sản', 'REAL_ESTATE'),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip('Phương tiện', 'VEHICLE'),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip('Vàng', 'GOLD'),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip('Chứng khoán', 'STOCK'),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip('Tiền mặt', 'CASH'),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip('Khác', 'OTHER'),
                    ],
                  ),
                ),

                // Active Month/Year Filter Banner if applied
                if (_controller.filterMonth != null &&
                    _controller.filterYear != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đang lọc theo: Tháng ${_controller.filterMonth}/${_controller.filterYear}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        InkWell(
                          onTap: _controller.clearDateFilter,
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Header with count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Danh mục tài sản (${assets.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Thêm tài sản'),
                      onPressed: _navigateToAddAsset,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Error Banner if any
                if (_controller.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorBgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.errorColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppTheme.errorColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _controller.errorMessage!,
                            style: const TextStyle(
                              color: AppTheme.errorColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: _controller.clearMessages,
                        ),
                      ],
                    ),
                  ),
                ],

                // Asset List or Empty State
                if (assets.isEmpty) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 56,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Không tìm thấy tài sản nào',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Thử đổi bộ lọc hoặc thêm tài sản mới vào danh mục.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm tài sản mới'),
                            onPressed: _navigateToAddAsset,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  for (final asset in assets) ...[
                    AssetCardWidget(
                      asset: asset,
                      onTap: () => _navigateToDetail(asset),
                      onEdit: () => _navigateToEdit(asset),
                      onDelete: () => _confirmDeleteAsset(asset),
                    ),
                  ],
                ],

                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddAsset,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Thêm tài sản'),
      ),
    );
  }

  Widget _buildTypeFilterChip(String label, String value) {
    final isSelected = _controller.selectedTypeFilter == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _controller.setTypeFilter(value);
        }
      },
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: AppTheme.surfaceColor,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      showCheckmark: false,
    );
  }
}
