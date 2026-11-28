import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/income_list_view.dart';
import 'features/auth/views/expense_list_view.dart';
import 'features/credit_account/controllers/credit_controller.dart';
import 'features/credit_account/services/mock_credit_service.dart';
import 'features/credit_account/views/credit_accounts_view.dart';
/// Root Application Widget configuring theme and home route.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth MVC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: CreditAccountsView(
    controller: CreditController(
    service: MockCreditService(),
    ),
    ),
    );
  }
}
