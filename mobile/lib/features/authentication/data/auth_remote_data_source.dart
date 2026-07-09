import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../domain/entities/auth_user.dart';
import '../domain/failures/auth_failure.dart';

/// Remote authentication API access via Dio.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// Registers a new voter account.
  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _post(
      ApiEndpoints.authRegister,
      data: {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
      },
    );

    return _parseUser(response.data);
  }

  /// Authenticates a user and returns the access token plus user profile.
  Future<({AuthUser user, String token})> login({
    required String email,
    required String password,
  }) async {
    final response = await _post(
      ApiEndpoints.authLogin,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = _readDataMap(response.data);
    final token = data['token'] as String?;

    if (token == null || token.isEmpty) {
      throw const AuthFailure('Login response did not include an access token.');
    }

    final userJson = data['user'];
    if (userJson is! Map<String, dynamic>) {
      throw const AuthFailure('Login response did not include user data.');
    }

    return (user: AuthUser.fromJson(userJson), token: token);
  }

  /// Fetches the authenticated user's profile.
  Future<AuthUser> getCurrentUser() async {
    final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.authMe);
    return _parseUser(response.data);
  }

  Future<Response<Map<String, dynamic>>> _post(
    String path, {
    required Map<String, dynamic> data,
  }) {
    return _dio.post<Map<String, dynamic>>(path, data: data);
  }

  AuthUser _parseUser(Map<String, dynamic>? body) {
    final data = _readDataMap(body);
    final userJson = data['user'];

    if (userJson is! Map<String, dynamic>) {
      throw const AuthFailure('Unexpected response from authentication API.');
    }

    return AuthUser.fromJson(userJson);
  }

  Map<String, dynamic> _readDataMap(Map<String, dynamic>? body) {
    if (body == null) {
      throw const AuthFailure('Empty response from authentication API.');
    }

    if (body['success'] == false) {
      throw AuthFailure(_messageFromBody(body));
    }

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const AuthFailure('Unexpected response from authentication API.');
    }

    return data;
  }

  /// Converts Dio and API envelope errors into [AuthFailure].
  static AuthFailure mapException(Object error, [StackTrace? stackTrace]) {
    if (error is AuthFailure) {
      return error;
    }

    if (error is DioException) {
      _logDioException(error, stackTrace);
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        return AuthFailure(_messageFromBody(responseData));
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return AuthFailure(_timeoutMessage(error));
        case DioExceptionType.connectionError:
          return AuthFailure(_connectionErrorMessage(error));
        case DioExceptionType.badResponse:
          return AuthFailure(_badResponseMessage(error));
        default:
          return AuthFailure(_genericDioMessage(error));
      }
    }

    debugPrint(
      '[VoteChain][Network][Auth] Non-Dio error: $error\n$stackTrace',
    );
    return AuthFailure('Unexpected error: $error');
  }

  static void _logDioException(DioException error, [StackTrace? stackTrace]) {
    if (!kDebugMode) return;

    debugPrint(
      '[VoteChain][Network][Auth][DioException]\n'
      '  type: ${error.type}\n'
      '  message: ${error.message}\n'
      '  uri: ${error.requestOptions.uri}\n'
      '  baseUrl: ${error.requestOptions.baseUrl}\n'
      '  path: ${error.requestOptions.path}\n'
      '  status: ${error.response?.statusCode}\n'
      '  response: ${error.response?.data}\n'
      '  inner: ${error.error}\n'
      '  stackTrace: ${stackTrace ?? error.stackTrace}',
    );
  }

  static String _connectionErrorMessage(DioException error) {
    final inner = error.error;
    return 'Dio connectionError: ${error.message ?? 'no message'}'
        '${inner != null ? ' | cause: $inner' : ''}'
        ' | url: ${error.requestOptions.uri}';
  }

  static String _timeoutMessage(DioException error) {
    return 'Dio ${error.type.name}: ${error.message ?? 'timed out'}'
        ' | url: ${error.requestOptions.uri}';
  }

  static String _badResponseMessage(DioException error) {
    return 'Dio badResponse: status=${error.response?.statusCode}'
        ' | url: ${error.requestOptions.uri}'
        ' | body: ${error.response?.data}';
  }

  static String _genericDioMessage(DioException error) {
    return 'Dio ${error.type.name}: ${error.message ?? 'request failed'}'
        ' | url: ${error.requestOptions.uri}';
  }

  static String _messageFromBody(Map<String, dynamic> body) {
    final message = body['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }

    final errors = body['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      if (first is Map && first['msg'] is String) {
        return first['msg'] as String;
      }
      if (first is String) {
        return first;
      }
    }

    return 'Request failed. Please try again.';
  }
}
