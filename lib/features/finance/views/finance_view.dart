import 'package:flutter/material.dart';

import 'components/monthly_summary_card.dart';
import 'components/category_list_card.dart';
import 'components/policy.dart';

class FinanceView extends StatefulWidget {
  const FinanceView({super.key});
  @override
  State<FinanceView> createState() => _FinanceViewState();
}

class _FinanceViewState extends State<FinanceView> {
  bool _isLoading = false;
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(padding: const EdgeInsets.all(8)), //căn trái
        title: const Text('Quản lý tài chính'),
        actions: [
          //căn phải
          IconButton(
            onPressed: () => {},
            icon: const Icon(Icons.notifications_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 8,
            ), // giúp tách padding bên phải một khoảng 8
            child: CircleAvatar(radius: 16),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return const SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          MonthlySummaryCard(),
          const SizedBox(height: 8),
          CategoryListCard(),
          const SizedBox(height: 8),
          Policy(),
        ],
      ),
    ); //để có thanh trượt khi dài quá
  }
}
