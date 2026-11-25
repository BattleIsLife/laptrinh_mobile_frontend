import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/saving_controller.dart';
import '../models/saving_goal.dart';
import 'add_edit_saving_view.dart';
import 'components/deposit_saving_dialog.dart';
import 'components/saving_goal_card_widget.dart';

/// Screen displaying comprehensive details and financial breakdown of a savings goal.
class SavingDetailView extends StatefulWidget {
  final int savingId;
  final SavingController controller;

  const SavingDetailView({
    super.key,
    required this.savingId,
    required this.controller,
  });

  @override
  State<SavingDetailView> createState() => _SavingDetailViewState();
}

class _SavingDetailViewState extends State<SavingDetailView> {
  SavingGoal? _saving;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    final goal = await widget.controller.fetchSavingDetail(widget.savingId);
    if (mounted) {
      setState(() {
        _saving = goal;
        _isLoading = false;
      });
    }
  }

  void _onEditGoal() async {
    if (_saving == null) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditSavingView(
          controller: widget.controller,
          goalToEdit: _saving,
        ),
      ),
    );

    if (updated == true && mounted) {
      _loadDetail();
    }
  }

  void _onDeposit() async {
    if (_saving == null) return;
    final deposited = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DepositSavingDialog(
        controller: widget.controller,
        goal: _saving!,
      ),
    );

    if (deposited == true && mounted) {
      _loadDetail();
    }
  }

  void _confirmDelete() {
    if (_saving == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.dangerColor),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa mục tiêu "${_saving!.name}" không? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await widget.controller.deleteSaving(_saving!.id);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa mục tiêu tiết kiệm thành công'),
                      backgroundColor: AppTheme.secondaryColor,
                    ),
                  );
                  Navigator.of(context).pop(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.controller.errorMessage ?? 'Xóa thất bại',
                      ),
                      backgroundColor: AppTheme.dangerColor,
                    ),
                  );
                }
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Chi tiết mục tiêu'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (_saving != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Chỉnh sửa',
              onPressed: _onEditGoal,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.dangerColor),
              tooltip: 'Xóa mục tiêu',
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _saving == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 56,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Không tìm thấy thông tin mục tiêu',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'Tải lại',
                        onPressed: _loadDetail,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDetail,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card preview
                        SavingGoalCardWidget(
                          goal: _saving!,
                          onTap: () {},
                          onDepositTap: _onDeposit,
                          onEditTap: _onEditGoal,
                          onDeleteTap: _confirmDelete,
                        ),
                        const SizedBox(height: 16),

                        // Action button: Nạp tiền
                        if (!_saving!.isCompleted && !_saving!.isCancelled)
                          ElevatedButton.icon(
                            onPressed: _onDeposit,
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text(
                              'Nạp tiền tích lũy',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),

                        // Chi tiết các chỉ số tài chính
                        _buildDetailSection(
                          title: 'Thông tin tài chính',
                          items: [
                            _DetailRow(
                              label: 'Mục tiêu cần đạt',
                              value: _saving!.formattedTargetAmount,
                              valueColor: AppTheme.primaryColor,
                              isBold: true,
                            ),
                            _DetailRow(
                              label: 'Đã tích lũy',
                              value: _saving!.formattedCurrentAmount,
                              valueColor: AppTheme.secondaryColor,
                              isBold: true,
                            ),
                            _DetailRow(
                              label: 'Còn thiếu',
                              value: _saving!.formattedRemainingAmount,
                              valueColor: AppTheme.accentColor,
                              isBold: true,
                            ),
                            _DetailRow(
                              label: 'Đóng góp hàng tháng',
                              value: _saving!.formattedMonthlyContribution,
                            ),
                            _DetailRow(
                              label: 'Lãi suất kỳ vọng',
                              value: _saving!.formattedInterestRate,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Kế hoạch và tiến độ
                        _buildDetailSection(
                          title: 'Kế hoạch & Thời gian',
                          items: [
                            _DetailRow(
                              label: 'Trạng thái',
                              value: _saving!.statusLabel,
                              valueColor: _saving!.statusColor,
                              isBold: true,
                            ),
                            _DetailRow(
                              label: 'Hạn hoàn thành',
                              value: _saving!.formattedTargetDate,
                            ),
                            _DetailRow(
                              label: 'Thời gian còn lại',
                              value: _saving!.remainingDays <= 0
                                  ? 'Đã đến hạn'
                                  : '${_saving!.remainingDays} ngày (~${_saving!.remainingMonths} tháng)',
                            ),
                            _DetailRow(
                              label: 'Ngày tạo',
                              value: _saving!.formattedCreatedAt,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required List<_DetailRow> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          item.isBold ? FontWeight.bold : FontWeight.w500,
                      color: item.valueColor ?? AppTheme.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });
}
