import 'env_config.dart';

/// Centralized API endpoint paths for the VoteChain backend.
abstract final class ApiEndpoints {
  static const String baseUrl = EnvConfig.apiBaseUrl;

  static const String authLogin = '/api/auth/login';
  static const String authRegister = '/api/auth/register';
  static const String elections = '/api/elections';
  static const String votes = '/api/votes';
}
