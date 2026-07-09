import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/env_config.dart';
import 'auth_interceptor.dart';
import 'network_logging_interceptor.dart';
import 'token_storage.dart';

/// Shared Dio instance for VoteChain API calls.
class DioClient {
  DioClient({
    required TokenStorage tokenStorage,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: EnvConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    if (kDebugMode) {
      debugPrint(
        '[VoteChain][Network][DioClient] '
        'Initialized with baseUrl: ${EnvConfig.apiBaseUrl}',
      );
    }
    _dio.interceptors.add(AuthInterceptor(tokenStorage));
    _dio.interceptors.add(NetworkLoggingInterceptor());
  }

  final Dio _dio;

  Dio get instance => _dio;
}

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(tokenStorage: ref.watch(tokenStorageProvider));
});

final dioProvider = Provider<Dio>((ref) => ref.watch(dioClientProvider).instance);
