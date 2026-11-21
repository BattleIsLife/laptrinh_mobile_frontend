import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// Base exception for API errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseData;

  ApiException(this.message, {this.statusCode, this.responseData});

  @override
  String toString() => 'ApiException: $message (statusCode: $statusCode)';
}

/// Thrown when there is no internet connection or network failure.
class NetworkException extends ApiException {
  NetworkException([
    super.message =
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
  ]);
}

/// Thrown when a network request times out.
class RequestTimeoutException extends ApiException {
  RequestTimeoutException([
    super.message =
        'Yêu cầu hết thời gian chờ (Timeout). Vui lòng thử lại sau.',
  ]);
}

/// Thrown on HTTP 401 Unauthorized errors.
class UnauthorizedException extends ApiException {
  UnauthorizedException([
    super.message = 'Phiên đăng nhập hết hạn hoặc không có quyền truy cập.',
  ]) : super(statusCode: 401);
}

/// Thrown on HTTP 500+ Server errors.
class ServerException extends ApiException {
  ServerException([
    super.message = 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau.',
    int statusCode = 500,
  ]) : super(statusCode: statusCode);
}

/// Generic HTTP API Client with centralized timeout, error handling,
/// and header management. Supports GET, POST, PATCH, and DELETE.
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Default headers sent with requests.
  Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Builds request headers including Bearer token if provided.
  Map<String, String> _buildHeaders(
    Map<String, String>? headers,
    String? token,
  ) {
    final merged = {...defaultHeaders, ...?headers};
    if (token != null && token.isNotEmpty) {
      merged['authorization'] = 'Bearer $token';
    }
    return merged;
  }

  /// Sends a GET request to the specified [endpoint].
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    String? token,
  }) async {
    final uri = ApiConfig.getUri(endpoint, queryParams);
    final mergedHeaders = _buildHeaders(headers, token);

    try {
      final response = await _client
          .get(uri, headers: mergedHeaders)
          .timeout(ApiConfig.connectTimeout);

      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw RequestTimeoutException();
    } on FormatException {
      throw ApiException('Phản hồi từ máy chủ không đúng định dạng JSON.');
    }
  }

  /// Sends a POST request to the specified [endpoint].
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? token,
  }) async {
    final uri = ApiConfig.getUri(endpoint);
    final mergedHeaders = _buildHeaders(headers, token);

    try {
      final response = await _client
          .post(
            uri,
            headers: mergedHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectTimeout);

      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw RequestTimeoutException();
    } on FormatException {
      throw ApiException('Phản hồi từ máy chủ không đúng định dạng JSON.');
    }
  }

  /// Sends a PATCH request to the specified [endpoint].
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? token,
  }) async {
    final uri = ApiConfig.getUri(endpoint);
    final mergedHeaders = _buildHeaders(headers, token);

    try {
      final response = await _client
          .patch(
            uri,
            headers: mergedHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectTimeout);

      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw RequestTimeoutException();
    } on FormatException {
      throw ApiException('Phản hồi từ máy chủ không đúng định dạng JSON.');
    }
  }

  /// Sends a DELETE request to the specified [endpoint].
  /// Supports optional body and queryParams.
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    String? token,
  }) async {
    final uri = ApiConfig.getUri(endpoint, queryParams);
    final mergedHeaders = _buildHeaders(headers, token);

    try {
      final request = http.Request('DELETE', uri);
      request.headers.addAll(mergedHeaders);
      if (body != null) {
        request.body = jsonEncode(body);
      }

      final streamedResponse = await _client
          .send(request)
          .timeout(ApiConfig.connectTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw RequestTimeoutException();
    } on FormatException {
      throw ApiException('Phản hồi từ máy chủ không đúng định dạng JSON.');
    }
  }

  /// Processes HTTP responses and converts status codes into results or custom exceptions.
  Map<String, dynamic> _processResponse(http.Response response) {
    dynamic responseData;
    if (response.body.isNotEmpty) {
      try {
        responseData = jsonDecode(response.body);
      } catch (_) {
        responseData = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseData is Map<String, dynamic>) {
        final status = responseData['status'];
        // Backend doc states: "status": "false" on error
        if (status == 'false' || status == false) {
          final message =
              _extractErrorMessage(responseData) ??
              'Yêu cầu xử lý không thành công.';
          throw ApiException(
            message,
            statusCode: response.statusCode,
            responseData: responseData,
          );
        }
        return responseData;
      }
      return {'data': responseData};
    }

    final message =
        _extractErrorMessage(responseData) ??
        'Yêu cầu thất bại với mã trạng thái ${response.statusCode}.';

    if (response.statusCode == 401) {
      throw UnauthorizedException(message);
    } else if (response.statusCode >= 500) {
      throw ServerException(message, response.statusCode);
    } else {
      throw ApiException(
        message,
        statusCode: response.statusCode,
        responseData: responseData,
      );
    }
  }

  /// Extracts error message from standard backend error JSON responses if available.
  String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] is String) {
        return responseData['message'] as String;
      }
      if (responseData['error'] is String) {
        return responseData['error'] as String;
      }
    }
    return null;
  }

  /// Closes the client when no longer needed.
  void close() {
    _client.close();
  }
}
