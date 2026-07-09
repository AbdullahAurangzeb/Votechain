import 'env_config.dart';

/// Centralized API endpoint paths for the VoteChain backend.
abstract final class ApiEndpoints {
  static String get baseUrl => EnvConfig.apiBaseUrl;

  static const String authRegister = '/api/v1/auth/register';
  static const String authLogin = '/api/v1/auth/login';
  static const String authMe = '/api/v1/auth/me';
  static const String verificationSubmit = '/api/v1/verification/submit';
  static const String verificationStatus = '/api/v1/verification/status';
  static const String elections = '/api/elections';
  static const String votes = '/api/votes';
}
