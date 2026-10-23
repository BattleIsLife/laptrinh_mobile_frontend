import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:frontend/core/config/api_config.dart';
import 'package:frontend/core/network/api_client.dart';

void main() {
  group('ApiClient Tests', () {
    test('Successful 200 response returns decoded Map', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.headers['Content-Type'], contains('application/json'));

        return http.Response(
          jsonEncode({
            'user': {
              'id': 1,
              'email': 'student@example.com',
              'name': 'Nguyen Van A',
            },
            'token': 'mock-token',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final response = await apiClient.post(
        ApiConfig.loginEndpoint,
        body: {'email': 'student@example.com', 'password': 'password123'},
      );

      expect(response['token'], 'mock-token');
      expect(response['user']['name'], 'Nguyen Van A');
    });

    test('401 Unauthorized throws UnauthorizedException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Email hoặc mật khẩu không chính xác'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () => apiClient.post(
          ApiConfig.loginEndpoint,
          body: {'email': 'test@example.com', 'password': 'wrong'},
        ),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('500 Internal Server Error throws ServerException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Database connection failed'}),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () => apiClient.post(
          ApiConfig.loginEndpoint,
          body: {'email': 'test@example.com', 'password': 'password123'},
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
