/// Configuration for API endpoints and network settings.
class ApiConfig {
  ApiConfig._();

  /// Default Base URL for the Node.js backend.
  /// For Android emulator, use: 'http://10.0.2.2:5001'
  /// For iOS simulator, Desktop or Web, use: 'http://localhost:5001'
  static const String defaultBaseUrl = 'http://localhost:5001';

  /// Active base URL. Can be modified at runtime or injected via environment variables.
  static String baseUrl = defaultBaseUrl;

  /// Authentication endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String profileEndpoint = '/api/users/me/profile';

  /// Credit account endpoints (theo tài liệu API)
  static const String creditAccountsEndpoint = '/api/credit_accounts';
  static const String creditApplicationsEndpoint = '/api/credit_applications';

  /// Asset endpoints (theo tài liệu API Tài sản)
  static const String assetsEndpoint = '/api/assets';

  /// Savings endpoints (theo tài liệu API Mục tiêu tiết kiệm)
  static const String savingsEndpoint = '/api/savings';

  /// Network timeout configurations
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  /// Toggle for Mock Service vs Real REST API.
  /// When true, services will simulate network calls with mock data.
  /// Set to false when connecting to the actual Node.js backend.
  static bool useMockService = false;

  /// Helper to build a complete [Uri] from an endpoint path and optional query parameters.
  static Uri getUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final baseUri = Uri.parse('$baseUrl$cleanEndpoint');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final stringParams = queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      return baseUri.replace(queryParameters: stringParams);
    }
    return baseUri;
  }
}
