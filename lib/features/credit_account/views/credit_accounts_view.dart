import 'package:flutter/material.dart';

import '../controllers/credit_controller.dart';
import '../models/credit_account_model.dart';
import '../models/credit_application_model.dart';
import 'credit_account_form_view.dart';

/// Màn hình chính Quản lý Tài khoản tín dụng & Yêu cầu mở tín dụng.
class CreditAccountsView extends StatefulWidget {
  final String? token;
  final CreditController? controller;

  const CreditAccountsView({super.key, this.token, this.controller});

  @override
  State<CreditAccountsView> createState() => _CreditAccountsViewState();
}

class _CreditAccountsViewState extends State<CreditAccountsView> {
  late final CreditController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = CreditController(token: widget.token);
      _ownsController = true;
    }

    _loadAll();
  }

  Future<void> _loadAll() async {
    await _controller.fetchAccounts();
    await _controller.fetchApplications();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _openAccountForm([CreditAccountModel? account]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreditAccountFormView(
          controller: _controller,
          accountToEdit: account,
        ),
      ),
    );
  }

  Future<void> _confirmCloseAccount(CreditAccountModel account) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đóng tài khoản tín dụng'),
        content: Text(
          'Bạn có chắc muốn đóng tài khoản "${account.bankName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đóng tài khoản'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await _controller.closeAccount(account.id);
      if (!mounted) return;
      _showSnackBar(
        ok
            ? (_controller.successMessage ?? 'Đã đóng tài khoản')
            : (_controller.errorMessage ?? 'Đóng tài khoản thất bại'),
        isError: !ok,
      );
    }
  }

  Future<void> _showAddApplicationDialog() async {
    final nameController = TextEditingController();
    String selectedType = 'CREDIT_CARD';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Thêm yêu cầu mở tín dụng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên yêu cầu',
                  hintText: 'Ví dụ: Mở thẻ chi tiêu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Loại tín dụng',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'CREDIT_CARD',
                    child: Text('Thẻ tín dụng'),
                  ),
                  DropdownMenuItem(
                    value: 'OVERDRAFT',
                    child: Text('Thấu chi'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedType = val);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await _controller.addApplication(
                  name: nameController.text,
                  creditType: selectedType,
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx, success);
                }
              },
              child: const Text('Tạo yêu cầu'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();

    if (ok != null && mounted) {
      _showSnackBar(
        ok
            ? (_controller.successMessage ?? 'Tạo yêu cầu tín dụng thành công')
            : (_controller.errorMessage ?? 'Tạo yêu cầu thất bại'),
        isError: !ok,
      );
    }
  }

  Future<void> _confirmDeleteApplication(CreditApplicationModel app) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa yêu cầu tín dụng'),
        content: Text('Bạn có chắc muốn xóa yêu cầu "${app.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await _controller.deleteApplication(app.id);
      if (!mounted) return;
      _showSnackBar(
        ok
            ? (_controller.successMessage ?? 'Đã xóa yêu cầu')
            : (_controller.errorMessage ?? 'Xóa thất bại'),
        isError: !ok,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tài khoản tín dụng'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tài khoản'),
              Tab(text: 'Yêu cầu mở thẻ'),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            if (_controller.isLoading &&
                _controller.accounts.isEmpty &&
                _controller.applications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children: [
                _buildAccountsTab(),
                _buildApplicationsTab(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccountsTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAccountForm(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm tài khoản'),
      ),
      body: RefreshIndicator(
        onRefresh: _controller.fetchAccounts,
        child: _controller.accounts.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      _controller.errorMessage ??
                          'Chưa có tài khoản tín dụng nào',
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _controller.accounts.length,
                itemBuilder: (context, index) {
                  final acc = _controller.accounts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        acc.accountType == 'OVERDRAFT'
                            ? Icons.account_balance
                            : Icons.credit_card,
                        color: acc.isActive ? Colors.blue : Colors.grey,
                      ),
                      title: Text(
                        acc.bankName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${acc.accountTypeLabel} • Trạng thái: ${acc.status}\n'
                        'Hạn mức: ${acc.creditLimit.toStringAsFixed(0)} đ\n'
                        'Số dư: ${acc.currentBalance.toStringAsFixed(0)} đ',
                      ),
                      isThreeLine: true,
                      trailing: acc.isActive
                          ? PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _openAccountForm(acc);
                                } else if (value == 'close') {
                                  _confirmCloseAccount(acc);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Chỉnh sửa'),
                                ),
                                PopupMenuItem(
                                  value: 'close',
                                  child: Text(
                                    'Đóng tài khoản',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            )
                          : const Chip(label: Text('Đã đóng')),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildApplicationsTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddApplicationDialog,
        icon: const Icon(Icons.add),
        label: const Text('Tạo yêu cầu'),
      ),
      body: RefreshIndicator(
        onRefresh: _controller.fetchApplications,
        child: _controller.applications.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      _controller.errorMessage ??
                          'Chưa có yêu cầu mở tín dụng nào',
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _controller.applications.length,
                itemBuilder: (context, index) {
                  final app = _controller.applications[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.description, color: Colors.orange),
                      title: Text(
                        app.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Loại: ${app.creditTypeLabel}\nNgày tạo: ${app.applicationDate}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteApplication(app),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
