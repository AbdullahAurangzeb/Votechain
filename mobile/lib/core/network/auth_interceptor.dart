import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'token_storage.dart';

/// Attaches the JWT bearer token to authenticated API requests.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final uriBefore = options.uri.toString();
    final token = await _tokenStorage.readAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    if (kDebugMode && uriBefore != options.uri.toString()) {
      debugPrint(
        '[VoteChain][Network][AuthInterceptor][WARNING] '
        'URL changed: $uriBefore -> ${options.uri}',
      );
    }

    handler.next(options);
  }
}
