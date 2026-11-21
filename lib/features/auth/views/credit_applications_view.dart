import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/credit_account_controller.dart';
import 'components/application_card_widget.dart';

/// Screen managing credit applications (GET, POST, DELETE /api/credit_applications).
class CreditApplicationsView extends StatefulWidget {
  final CreditAccountController controller;

  const CreditApplicationsView({super.key, required this.controller});

  @override
  State<CreditApplicationsView> createState() => _CreditApplicationsViewState();
}

class _CreditApplicationsViewState extends State<CreditApplicationsView> {
  @override
  void initState() {
    super.initState();
    widget.controller.fetchApplications();
  }

  void _showCreateApplicationDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    String selectedType = 'CREDIT_CARD';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Yêu cầu mở tín dụng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Application Name Input
                    const Text(
                      'Tên yêu cầu *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameController,
                      validator:
                          CreditAccountController.validateApplicationName,
                      decoration: const InputDecoration(
                        hintText: 'Ví dụ: Thẻ hoàn tiền Shopee Platinum',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Credit Type Options
                    const Text(
                      'Loại tín dụng *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedType = 'CREDIT_CARD';
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selectedType == 'CREDIT_CARD'
                                    ? AppTheme.primaryColor
                                        .withValues(alpha: 0.1)
                                    : AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedType == 'CREDIT_CARD'
                                      ? AppTheme.primaryColor
                                      : AppTheme.borderColor,
                                  width: selectedType == 'CREDIT_CARD' ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    size: 18,
                                    color: selectedType == 'CREDIT_CARD'
                                        ? AppTheme.primaryColor
                                        : AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Thẻ tín dụng',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: selectedType == 'CREDIT_CARD'
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: selectedType == 'CREDIT_CARD'
                                          ? AppTheme.primaryColor
                                          : AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedType = 'OVERDRAFT';
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selectedType == 'OVERDRAFT'
                                    ? const Color(0xFF0D9488)
                                        .withValues(alpha: 0.1)
                                    : AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedType == 'OVERDRAFT'
                                      ? const Color(0xFF0D9488)
                                      : AppTheme.borderColor,
                                  width: selectedType == 'OVERDRAFT' ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.account_balance,
                                    size: 18,
                                    color: selectedType == 'OVERDRAFT'
                                        ? const Color(0xFF0D9488)
                                        : AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Thấu chi',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: selectedType == 'OVERDRAFT'
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: selectedType == 'OVERDRAFT'
                                          ? const Color(0xFF0D9488)
                                          : AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    AppButton(
                      text: 'Gửi yêu cầu mở tín dụng',
                      icon: Icons.send,
                      isLoading: widget.controller.isActionLoading,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final name = nameController.text.trim();
                        final success = await widget.controller.createApplication(
                          name: name,
                          creditType: selectedType,
                        );

                        if (!context.mounted) return;
                        if (success) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.controller.successMessage ??
                                    'Tạo yêu cầu tín dụng thành công',
                              ),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.controller.errorMessage ??
                                    'Không thể tạo yêu cầu',
                              ),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteApplication(int applicationId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hủy yêu cầu tín dụng'),
        content: Text('Bạn có chắc chắn muốn hủy yêu cầu "$name" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Quay lại'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success =
                  await widget.controller.deleteApplication(applicationId);
              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.controller.successMessage ??
                          'Đã xóa yêu cầu thành công',
                    ),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.controller.errorMessage ??
                          'Không thể xóa yêu cầu',
                    ),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Hủy yêu cầu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu cầu mở tín dụng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: widget.controller.fetchApplications,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          if (widget.controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final applications = widget.controller.applications;

          if (applications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.inbox_outlined,
                        size: 36,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có yêu cầu mở tín dụng nào',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tạo yêu cầu mới để đăng ký thẻ tín dụng hoặc hạn mức thấu chi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Tạo yêu cầu mới'),
                      onPressed: _showCreateApplicationDialog,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: widget.controller.fetchApplications,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final app = applications[index];
                return ApplicationCardWidget(
                  application: app,
                  onDelete: () => _confirmDeleteApplication(app.id, app.name),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateApplicationDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tạo yêu cầu'),
      ),
    );
  }
}
