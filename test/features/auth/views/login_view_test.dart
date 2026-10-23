import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/features/auth/controllers/auth_controller.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/auth/views/login_view.dart';
import 'package:frontend/features/auth/views/welcome_view.dart';

void main() {
  group('LoginView & LoginForm Widget Tests', () {
    testWidgets('Renders all required elements (title, fields, button)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const App());

      // Check titles & descriptions
      expect(find.text('Đăng nhập tài khoản'), findsOneWidget);
      expect(find.text('Địa chỉ Email'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('Toggling password visibility icon changes obscureText', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const App());

      // Find password text field via its label inside TextField
      final passwordTextFieldFinder = find.descendant(
        of: find.widgetWithText(TextFormField, 'Mật khẩu'),
        matching: find.byType(TextField),
      );
      expect(passwordTextFieldFinder, findsOneWidget);

      final passwordWidgetBefore = tester.widget<TextField>(
        passwordTextFieldFinder,
      );
      expect(passwordWidgetBefore.obscureText, isTrue);

      // Tap visibility toggle icon
      final toggleFinder = find.byTooltip('Hiện mật khẩu');
      expect(toggleFinder, findsOneWidget);
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      final passwordWidgetAfter = tester.widget<TextField>(
        passwordTextFieldFinder,
      );
      expect(passwordWidgetAfter.obscureText, isFalse);
    });

    testWidgets('Shows validation errors on empty submission', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const App());

      // Tap login without entering anything
      final submitButton = find.byType(AppButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Check validation error messages
      expect(find.text('Vui lòng nhập địa chỉ email.'), findsOneWidget);
      expect(find.text('Vui lòng nhập mật khẩu.'), findsOneWidget);
    });

    testWidgets(
      'Retains user input when login fails (network error or wrong credentials)',
      (WidgetTester tester) async {
        final mockService = MockAuthService(simulatedDelay: Duration.zero);
        final controller = AuthController(authService: mockService);

        await tester.pumpWidget(
          MaterialApp(home: LoginView(controller: controller)),
        );

        // Enter credentials with wrong password
        final emailFields = find.byType(TextFormField);
        await tester.enterText(emailFields.first, 'preserve_user@example.com');
        await tester.enterText(emailFields.last, 'wrong-password');

        // Tap submit
        await tester.tap(find.byType(AppButton));
        await tester.pumpAndSettle();

        // Verify error message is shown
        expect(find.textContaining('không chính xác'), findsOneWidget);

        // Crucial requirement: Entered text should NOT be cleared!
        expect(find.text('preserve_user@example.com'), findsOneWidget);
        expect(find.text('wrong-password'), findsOneWidget);
      },
    );

    testWidgets('Successful login navigates to WelcomeView', (
      WidgetTester tester,
    ) async {
      final mockService = MockAuthService(simulatedDelay: Duration.zero);
      final controller = AuthController(authService: mockService);

      await tester.pumpWidget(
        MaterialApp(home: LoginView(controller: controller)),
      );

      final emailFields = find.byType(TextFormField);
      await tester.enterText(emailFields.first, 'student@example.com');
      await tester.enterText(emailFields.last, 'example-password');

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      // Verify navigation to WelcomeView
      expect(find.byType(WelcomeView), findsOneWidget);
      expect(find.text('Đăng nhập thành công!'), findsOneWidget);
      expect(find.text('Nguyen Van A'), findsOneWidget);
    });
  });
}
