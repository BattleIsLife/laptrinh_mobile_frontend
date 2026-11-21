import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/credit_account_controller.dart';
import '../models/credit_account.dart';
import 'add_edit_credit_account_view.dart';
import 'components/credit_card_widget.dart';
import 'components/credit_stat_card.dart';
import 'credit_account_detail_view.dart';
import 'credit_applications_view.dart';

/// Main screen for Credit Accounts Management (Quản lý tài khoản tín dụng).
/// Follows MVC: Observes [CreditAccountController] for reactive state updates.
class CreditAccountsView extends StatefulWidget {
  final String? token;
  final CreditAccountController? controller;

  const CreditAccountsView({super.key, this.token, this.controller});

  @override
  State<CreditAccountsView> createState() => _CreditAccountsViewState();
}

class _CreditAccountsViewState extends State<CreditAccountsView> {
  late final CreditAccountController _controller;
  bool _ownsController = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = CreditAccountController(token: widget.token);
      _ownsController = true;
    }

    if (widget.token != null) {
      _controller.setToken(widget.token);
    }

    _controller.fetchAccounts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _navigateToAddAccount() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditCreditAccountView(controller: _controller),
      ),
    );

    if (added == true && mounted) {
      _controller.fetchAccounts();
    }
  }

  void _navigateToDetail(CreditAccount account) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreditAccountDetailView(
          accountId: account.id,
          controller: _controller,
        ),
      ),
    );
    if (mounted) {
      _controller.fetchAccounts();
    }
  }

  void _navigateToEdit(CreditAccount account) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditCreditAccountView(
          controller: _controller,
          accountToEdit: account,
        ),
      ),
    );

    if (updated == true && mounted) {
      _controller.fetchAccounts();
    }
  }

  void _confirmCloseAccount(CreditAccount account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
            SizedBox(width: 8),
            Text('Đóng tài khoản'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn đóng tài khoản "${account.bankName}" không?\n\n'
          'Tài khoản sẽ được chuyển sang trạng thái ĐÃ ĐÓNG.',
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
              final success = await _controller.closeAccount(account.id);
              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _controller.successMessage ?? 'Đã đóng tài khoản',
                    ),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _controller.errorMessage ?? 'Không thể đóng tài khoản',
                    ),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Đồng ý đóng'),
          ),
        ],
      ),
    );
  }

  void _navigateToApplications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreditApplicationsView(controller: _controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản tín dụng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_outlined),
            tooltip: 'Yêu cầu mở tín dụng',
            onPressed: _navigateToApplications,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: _controller.fetchAccounts,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final accounts = _controller.filteredAccounts;

          return RefreshIndicator(
            onRefresh: _controller.fetchAccounts,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Top Aggregate Stat Card
                CreditStatCard(
                  totalLimit: _controller.totalCreditLimit,
                  totalBalance: _controller.totalCurrentBalance,
                  availableLimit: _controller.totalAvailableLimit,
                  utilizationRatio: _controller.overallUtilization,
                  activeAccounts: _controller.activeAccountCount,
                  closedAccounts: _controller.closedAccountCount,
                ),

                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên ngân hàng...',
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

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tất cả', 'ALL'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Thẻ tín dụng', 'CREDIT_CARD'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Thấu chi', 'OVERDRAFT'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Đang hoạt động', 'ACTIVE'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Đã đóng', 'CLOSED'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Applications Shortcut Banner
                InkWell(
                  onTap: _navigateToApplications,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.post_add_outlined,
                          color: AppTheme.primaryColor,
                          size: 22,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Yêu cầu mở tín dụng',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              Text(
                                'Xem và quản lý các đơn xin cấp hạn mức tín dụng',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // List Header with count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Danh sách tài khoản (${accounts.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Thêm mới'),
                      onPressed: _navigateToAddAccount,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Error Banner if present
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

                // Accounts List or Empty State
                if (accounts.isEmpty) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.credit_card_off_outlined,
                            size: 56,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Không tìm thấy tài khoản nào',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Thử đổi bộ lọc hoặc thêm tài khoản tín dụng mới.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm tài khoản mới'),
                            onPressed: _navigateToAddAccount,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  for (final account in accounts) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: CreditCardWidget(
                        account: account,
                        onTap: () => _navigateToDetail(account),
                        onEdit: account.isActive
                            ? () => _navigateToEdit(account)
                            : null,
                        onClose: account.isActive
                            ? () => _confirmCloseAccount(account)
                            : null,
                      ),
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
        onPressed: _navigateToAddAccount,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_card),
        label: const Text('Thêm tài khoản'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _controller.filterType == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _controller.setFilterType(value);
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
