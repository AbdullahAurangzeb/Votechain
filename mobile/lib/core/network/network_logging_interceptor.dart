import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/env_config.dart';

/// Logs Dio request/response details for local debugging.
class NetworkLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logBlock('REQUEST', [
      'method: ${options.method}',
      'baseUrl (Dio): ${options.baseUrl}',
      'path: ${options.path}',
      'full URL: ${options.uri}',
      'EnvConfig.apiBaseUrl: ${EnvConfig.apiBaseUrl}',
      'headers: ${_formatJson(options.headers)}',
      'body: ${_formatBody(options.data)}',
    ]);
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logBlock('RESPONSE', [
      'status: ${response.statusCode}',
      'full URL: ${response.requestOptions.uri}',
      'headers: ${_formatJson(response.headers.map)}',
      'body: ${_formatBody(response.data)}',
    ]);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logBlock('DIO ERROR', [
      'type: ${err.type}',
      'message: ${err.message}',
      'full URL: ${err.requestOptions.uri}',
      'baseUrl (Dio): ${err.requestOptions.baseUrl}',
      'path: ${err.requestOptions.path}',
      'request headers: ${_formatJson(err.requestOptions.headers)}',
      'request body: ${_formatBody(err.requestOptions.data)}',
      'response status: ${err.response?.statusCode}',
      'response body: ${_formatBody(err.response?.data)}',
      'inner error: ${err.error}',
      'stackTrace: ${err.stackTrace}',
    ]);
    handler.next(err);
  }

  void _logBlock(String title, List<String> lines) {
    if (!kDebugMode) return;

    final buffer = StringBuffer('[VoteChain][Network][$title]\n');
    for (final line in lines) {
      buffer.writeln('  $line');
    }
    debugPrint(buffer.toString());
  }

  String _formatBody(dynamic data) {
    if (data == null) return 'null';

    if (data is Map) {
      return _formatJson(_sanitizeMap(Map<String, dynamic>.from(data)));
    }

    if (data is FormData) {
      return 'FormData(fields: ${data.fields.length}, files: ${data.files.length})';
    }

    return data.toString();
  }

  Map<String, dynamic> _sanitizeMap(Map<String, dynamic> data) {
    return data.map((key, value) {
      final lowerKey = key.toLowerCase();
      if (lowerKey.contains('password') || lowerKey.contains('token')) {
        return MapEntry(key, '***');
      }
      return MapEntry(key, value);
    });
  }

  String _formatJson(Map<String, dynamic> data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}

/// Startup diagnostics for API URL resolution.
abstract final class NetworkDebugLogger {
  static void logStartupConfig() {
    if (!kDebugMode) return;

    debugPrint(
      '[VoteChain][Network][Startup]\n'
      '  API_BASE_URL dart-define: "${EnvConfig.apiBaseUrlOverride.isEmpty ? 'EMPTY' : EnvConfig.apiBaseUrlOverride}"\n'
      '  API_LAN_HOST dart-define: ${EnvConfig.apiLanHost}\n'
      '  API_PORT dart-define: ${EnvConfig.apiPort}\n'
      '  EnvConfig.apiBaseUrl: ${EnvConfig.apiBaseUrl}\n'
      '  Expected physical Android: http://10.172.223.57:5000\n'
      '  URL override active: ${EnvConfig.hasUrlOverride}',
    );

    if (defaultTargetPlatform == TargetPlatform.android &&
        EnvConfig.apiBaseUrl.contains('localhost')) {
      debugPrint(
        '[VoteChain][Network][Startup][WARNING] '
        'Android is using localhost — requests will not reach your PC. '
        'Rebuild with --dart-define=API_BASE_URL=http://10.172.223.57:5000 '
        'or remove the localhost override.',
      );
    }
  }
}
