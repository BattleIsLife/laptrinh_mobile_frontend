import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User.fromJson should correctly deserialize valid JSON', () {
      final json = {
        'id': 1,
        'email': 'student@example.com',
        'name': 'Nguyen Van A',
      };

      final user = User.fromJson(json);

      expect(user.id, 1);
      expect(user.email, 'student@example.com');
      expect(user.name, 'Nguyen Van A');
    });

    test('User.fromJson should handle string id safely', () {
      final json = {
        'id': '42',
        'email': 'student@example.com',
        'name': 'Nguyen Van A',
      };

      final user = User.fromJson(json);
      expect(user.id, 42);
    });

    test('User.toJson should correctly serialize User to Map', () {
      const user = User(
        id: 1,
        email: 'student@example.com',
        name: 'Nguyen Van A',
      );

      final json = user.toJson();

      expect(json, {
        'id': 1,
        'email': 'student@example.com',
        'name': 'Nguyen Van A',
      });
    });

    test('User equality and hashCode should work properly', () {
      const user1 = User(id: 1, email: 'a@example.com', name: 'User A');
      const user2 = User(id: 1, email: 'a@example.com', name: 'User A');
      const user3 = User(id: 2, email: 'b@example.com', name: 'User B');

      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
      expect(user1, isNot(equals(user3)));
    });
  });

  group('AuthResult Model Tests', () {
    test('AuthResult.fromJson should correctly parse user and token', () {
      final json = {
        'user': {
          'id': 1,
          'email': 'student@example.com',
          'name': 'Nguyen Van A',
        },
        'token': 'example-token',
      };

      final authResult = AuthResult.fromJson(json);

      expect(authResult.user.id, 1);
      expect(authResult.user.email, 'student@example.com');
      expect(authResult.user.name, 'Nguyen Van A');
      expect(authResult.token, 'example-token');
    });

    test('AuthResult.toString() should not expose secret token in logs', () {
      const authResult = AuthResult(
        user: User(id: 1, email: 'test@example.com', name: 'Test'),
        token: 'super-secret-token-xyz',
      );

      expect(authResult.toString(), contains('[PROTECTED]'));
      expect(authResult.toString(), isNot(contains('super-secret-token-xyz')));
    });
  });
}
