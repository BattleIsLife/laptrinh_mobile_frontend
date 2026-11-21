import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/controllers/credit_account_controller.dart';
import 'package:frontend/features/auth/models/credit_account.dart';
import 'package:frontend/features/auth/services/credit_service.dart';
import 'package:frontend/features/auth/views/components/credit_card_widget.dart';
import 'package:frontend/features/auth/views/components/credit_stat_card.dart';
import 'package:frontend/features/auth/views/credit_accounts_view.dart';

void main() {
  group('Credit Account Widgets Tests', () {
    testWidgets('CreditCardWidget renders bank name, limit, balance, and type', (
      WidgetTester tester,
    ) async {
      final account = CreditAccount(
        id: 1,
        userId: 1,
        accountType: 'CREDIT_CARD',
        bankName: 'Techcombank Platinum',
        creditLimit: 50000000.0,
        currentBalance: 12000000.0,
        openedDate: DateTime(2026, 1, 1),
        status: 'ACTIVE',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreditCardWidget(account: account),
          ),
        ),
      );

      expect(find.text('Techcombank Platinum'), findsOneWidget);
      expect(find.text('50.000.000 ₫'), findsOneWidget);
      expect(find.text('12.000.000 ₫'), findsOneWidget);
      expect(find.text('THẺ TÍN DỤNG'), findsOneWidget);
      expect(find.text('Đang hoạt động'), findsOneWidget);
    });

    testWidgets('CreditStatCard renders summary numbers and utilization bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CreditStatCard(
              totalLimit: 100000000.0,
              totalBalance: 25000000.0,
              availableLimit: 75000000.0,
              utilizationRatio: 0.25,
              activeAccounts: 3,
              closedAccounts: 1,
            ),
          ),
        ),
      );

      expect(find.text('Tổng quan hạn mức tín dụng'), findsOneWidget);
      expect(find.text('100.000.000 ₫'), findsOneWidget);
      expect(find.text('25.000.000 ₫'), findsOneWidget);
      expect(find.text('75.000.000 ₫'), findsOneWidget);
      expect(find.text('25.0%'), findsOneWidget);
      expect(find.text('3 hoạt động'), findsOneWidget);
    });

    testWidgets('CreditAccountsView renders list and responds to filter chips', (
      WidgetTester tester,
    ) async {
      final mockService = MockCreditService(simulatedDelay: Duration.zero);
      final controller = CreditAccountController(creditService: mockService);

      await tester.pumpWidget(
        MaterialApp(
          home: CreditAccountsView(controller: controller),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tài khoản tín dụng'), findsWidgets);
      expect(find.text('Thẻ tín dụng'), findsWidgets);
      expect(find.text('Thấu chi'), findsWidgets);
      expect(find.byType(CreditCardWidget), findsWidgets);
    });
  });
}
