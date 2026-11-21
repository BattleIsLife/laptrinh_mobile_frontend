import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/controllers/credit_account_controller.dart';
import 'package:frontend/features/auth/services/credit_service.dart';

void main() {
  group('CreditAccountController (MVC Logic)', () {
    late CreditAccountController controller;
    late MockCreditService mockService;

    setUp(() {
      mockService = MockCreditService(simulatedDelay: Duration.zero);
      controller = CreditAccountController(creditService: mockService);
    });

    test('fetchAccounts loads initial mock accounts', () async {
      await controller.fetchAccounts();

      expect(controller.accounts.isNotEmpty, isTrue);
      expect(controller.isLoading, isFalse);
      expect(controller.totalCreditLimit, greaterThan(0));
    });

    test('filter accounts by type and bank search query', () async {
      await controller.fetchAccounts();

      // Test filter by CREDIT_CARD
      controller.setFilterType('CREDIT_CARD');
      expect(
        controller.filteredAccounts.every((a) => a.isCreditCard),
        isTrue,
      );

      // Test filter by OVERDRAFT
      controller.setFilterType('OVERDRAFT');
      expect(
        controller.filteredAccounts.every((a) => a.isOverdraft),
        isTrue,
      );

      // Test search query
      controller.setFilterType('ALL');
      controller.setSearchQuery('techcombank');
      expect(
        controller.filteredAccounts.every(
          (a) => a.bankName.toLowerCase().contains('techcombank'),
        ),
        isTrue,
      );
    });

    test('addAccount validates inputs and adds new account', () async {
      final success = await controller.addAccount(
        accountType: 'CREDIT_CARD',
        bankName: 'Ngân hàng Sacombank',
        creditLimit: 25000000.0,
        currentBalance: 500000.0,
      );

      expect(success, isTrue);
      expect(controller.successMessage, isNotNull);
      expect(
        controller.accounts.any((a) => a.bankName == 'Ngân hàng Sacombank'),
        isTrue,
      );
    });

    test('closeAccount updates account status to CLOSED', () async {
      await controller.fetchAccounts();
      final activeAccount = controller.accounts.firstWhere((a) => a.isActive);

      final success = await controller.closeAccount(activeAccount.id);

      expect(success, isTrue);
      final updated =
          controller.accounts.firstWhere((a) => a.id == activeAccount.id);
      expect(updated.isClosed, isTrue);
    });

    test('createApplication and deleteApplication operate correctly', () async {
      await controller.fetchApplications();
      final initialCount = controller.applications.length;

      final created = await controller.createApplication(
        name: 'Đăng ký thẻ mới',
        creditType: 'CREDIT_CARD',
      );

      expect(created, isTrue);
      expect(controller.applications.length, initialCount + 1);

      final newApp = controller.applications.firstWhere(
        (a) => a.name == 'Đăng ký thẻ mới',
      );
      final deleted = await controller.deleteApplication(newApp.id);
      expect(deleted, isTrue);
      expect(controller.applications.length, initialCount);
    });

    test('validation rules match API specifications', () {
      expect(CreditAccountController.validateBankName(''), isNotNull);
      expect(
        CreditAccountController.validateBankName('Ngân hàng ABC'),
        isNull,
      );

      expect(CreditAccountController.validateCreditLimit('-100'), isNotNull);
      expect(CreditAccountController.validateCreditLimit('abc'), isNotNull);
      expect(CreditAccountController.validateCreditLimit('5000000'), isNull);

      expect(
        CreditAccountController.validateAccountType('INVALID_TYPE'),
        isNotNull,
      );
      expect(
        CreditAccountController.validateAccountType('CREDIT_CARD'),
        isNull,
      );
      expect(CreditAccountController.validateAccountType('OVERDRAFT'), isNull);
    });
  });
}
