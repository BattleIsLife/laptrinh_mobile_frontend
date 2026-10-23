/// Configuration for API endpoints and network settings.
class ApiConfig {
  ApiConfig._();

  /// Default Base URL for the Node.js backend.
  /// For Android emulator, use: 'http://10.0.2.2:3000'
  /// For iOS simulator, Desktop or Web, use: 'http://localhost:3000'
  static const String defaultBaseUrl = 'http://localhost:3000';

  /// Active base URL. Can be modified at runtime or injected via environment variables.
  static String baseUrl = defaultBaseUrl;

  /// Authentication endpoints
  static const String loginEndpoint = '/api/auth/login';

  /// Network timeout configurations
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  /// Toggle for Mock Service vs Real REST API.
  /// When true, [AuthService] will simulate network calls with mock data.
  /// Set to false when connecting to the actual Node.js backend.
  static bool useMockService = true;

  /// Helper to build a complete [Uri] from an endpoint path.
  static Uri getUri(String endpoint) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return Uri.parse('$baseUrl$cleanEndpoint');
  }
}
