import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/controllers/auth_controller.dart';
import 'package:frontend/features/auth/services/auth_service.dart';

void main() {
  group('AuthController Validation Tests', () {
    test('validateEmail should reject null or empty strings', () {
      expect(AuthController.validateEmail(null), isNotNull);
      expect(AuthController.validateEmail(''), isNotNull);
      expect(AuthController.validateEmail('   '), isNotNull);
    });

    test('validateEmail should reject invalid email formats', () {
      expect(AuthController.validateEmail('plainaddress'), isNotNull);
      expect(AuthController.validateEmail('@missingusername.com'), isNotNull);
      expect(AuthController.validateEmail('user@.com'), isNotNull);
      expect(AuthController.validateEmail('user@domain'), isNotNull);
    });

    test('validateEmail should accept valid emails', () {
      expect(AuthController.validateEmail('student@example.com'), isNull);
      expect(
        AuthController.validateEmail('user.name+tag@domain.co.uk'),
        isNull,
      );
    });

    test('validatePassword should reject null or empty strings', () {
      expect(AuthController.validatePassword(null), isNotNull);
      expect(AuthController.validatePassword(''), isNotNull);
    });

    test('validatePassword should reject passwords with length < 6', () {
      expect(AuthController.validatePassword('12345'), isNotNull);
    });

    test('validatePassword should accept passwords with length >= 6', () {
      expect(AuthController.validatePassword('123456'), isNull);
      expect(AuthController.validatePassword('secure_password'), isNull);
    });
  });

  group('AuthController Flow Tests', () {
    late MockAuthService mockAuthService;
    late AuthController authController;

    setUp(() {
      mockAuthService = MockAuthService(simulatedDelay: Duration.zero);
      authController = AuthController(authService: mockAuthService);
    });

    tearDown(() {
      authController.dispose();
    });

    test('Initial state should have default values', () {
      expect(authController.isLoading, isFalse);
      expect(authController.errorMessage, isNull);
      expect(authController.currentUser, isNull);
      expect(authController.token, isNull);
      expect(authController.isAuthenticated, isFalse);
    });

    test(
      'Validation failure should set error message and not call service',
      () async {
        final success = await authController.login(
          email: 'invalid-email',
          password: 'password123',
        );

        expect(success, isFalse);
        expect(authController.errorMessage, isNotNull);
        expect(authController.isLoading, isFalse);
        expect(authController.isAuthenticated, isFalse);
      },
    );

    test(
      'Successful login with Mock Service updates state correctly',
      () async {
        final success = await authController.login(
          email: 'student@example.com',
          password: 'example-password',
        );

        expect(success, isTrue);
        expect(authController.isLoading, isFalse);
        expect(authController.errorMessage, isNull);
        expect(authController.isAuthenticated, isTrue);
        expect(authController.currentUser?.email, 'student@example.com');
        expect(authController.currentUser?.name, 'Nguyen Van A');
        expect(authController.token, isNotEmpty);
      },
    );

    test('Failed login with wrong password sets error message', () async {
      final success = await authController.login(
        email: 'student@example.com',
        password: 'wrong-password',
      );

      expect(success, isFalse);
      expect(authController.isLoading, isFalse);
      expect(authController.errorMessage, contains('không chính xác'));
      expect(authController.isAuthenticated, isFalse);
      expect(authController.currentUser, isNull);
    });

    test('Network error handling sets descriptive error message', () async {
      final success = await authController.login(
        email: 'network_error@example.com',
        password: 'password123',
      );

      expect(success, isFalse);
      expect(authController.isLoading, isFalse);
      expect(authController.errorMessage, contains('kết nối'));
      expect(authController.isAuthenticated, isFalse);
    });

    test('Loading state transitions during login execution', () async {
      // Use small delay to observe loading state
      final delayedService = MockAuthService(
        simulatedDelay: const Duration(milliseconds: 50),
      );
      final controllerWithDelay = AuthController(authService: delayedService);

      final states = <bool>[];
      controllerWithDelay.addListener(() {
        states.add(controllerWithDelay.isLoading);
      });

      final loginFuture = controllerWithDelay.login(
        email: 'student@example.com',
        password: 'password123',
      );

      // Immediately after triggering login, isLoading should be true
      expect(controllerWithDelay.isLoading, isTrue);

      final success = await loginFuture;
      expect(success, isTrue);
      expect(controllerWithDelay.isLoading, isFalse);

      // Verify that isLoading transitioned through true -> false
      expect(states, contains(true));
      expect(states.last, isFalse);

      controllerWithDelay.dispose();
    });

    test('Logout clears user, token, and authentication state', () async {
      await authController.login(
        email: 'student@example.com',
        password: 'example-password',
      );
      expect(authController.isAuthenticated, isTrue);

      authController.logout();

      expect(authController.isAuthenticated, isFalse);
      expect(authController.currentUser, isNull);
      expect(authController.token, isNull);
    });

    test('clearError resets error message', () async {
      await authController.login(
        email: 'student@example.com',
        password: 'wrong',
      );
      expect(authController.errorMessage, isNotNull);

      authController.clearError();
      expect(authController.errorMessage, isNull);
    });
  });
}
