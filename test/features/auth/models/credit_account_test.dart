import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/models/credit_account.dart';
import 'package:frontend/features/auth/models/credit_application.dart';

void main() {
  group('CreditAccount Model', () {
    test('parses from backend JSON correctly with string decimal numbers', () {
      final json = {
        'id': 1,
        'user_id': 10,
        'account_type': 'CREDIT_CARD',
        'bank_name': 'Ngân hàng ABC',
        'credit_limit': '5000000.00',
        'current_balance': '200000.00',
        'opened_date': '2026-11-03T17:00:00.000Z',
        'closed_date': null,
        'status': 'ACTIVE',
      };

      final account = CreditAccount.fromJson(json);

      expect(account.id, 1);
      expect(account.userId, 10);
      expect(account.accountType, 'CREDIT_CARD');
      expect(account.bankName, 'Ngân hàng ABC');
      expect(account.creditLimit, 5000000.0);
      expect(account.currentBalance, 200000.0);
      expect(account.availableLimit, 4800000.0);
      expect(account.isActive, isTrue);
      expect(account.isClosed, isFalse);
      expect(account.isCreditCard, isTrue);
      expect(account.accountTypeDisplay, 'Thẻ tín dụng');
      expect(account.statusDisplay, 'Đang hoạt động');
    });

    test('calculates utilization ratio correctly', () {
      final account = CreditAccount(
        id: 1,
        userId: 1,
        accountType: 'OVERDRAFT',
        bankName: 'VCB',
        creditLimit: 10000000.0,
        currentBalance: 5000000.0,
        openedDate: DateTime.now(),
        status: 'ACTIVE',
      );

      expect(account.utilizationPercentage, 0.5);
      expect(account.availableLimit, 5000000.0);
      expect(account.isOverdraft, isTrue);
      expect(account.accountTypeDisplay, 'Thấu chi');
    });

    test('formatCurrency formats VND numbers with dot separators', () {
      expect(CreditAccount.formatCurrency(700000), '700.000 ₫');
      expect(CreditAccount.formatCurrency(5000000), '5.000.000 ₫');
      expect(CreditAccount.formatCurrency(0), '0 ₫');
    });
  });

  group('CreditApplication Model', () {
    test('parses from JSON correctly', () {
      final json = {
        'id': 2,
        'user_id': 1,
        'name': 'Thẻ mua sắm',
        'credit_type': 'CREDIT_CARD',
        'application_date': '2026-11-04T17:00:00.000Z',
      };

      final app = CreditApplication.fromJson(json);

      expect(app.id, 2);
      expect(app.name, 'Thẻ mua sắm');
      expect(app.creditType, 'CREDIT_CARD');
      expect(app.isCreditCard, isTrue);
      expect(app.creditTypeDisplay, 'Thẻ tín dụng');
    });
  });
}
