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
    super.message = 'Email hoặc mật khẩu không chính xác.',
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
/// and header management.
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Default headers sent with requests.
  Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Sends a POST request to the specified [endpoint].
  ///
  /// Sensitive data (passwords, tokens) is never written to logs.
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = ApiConfig.getUri(endpoint);
    final mergedHeaders = {...defaultHeaders, ...?headers};

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
