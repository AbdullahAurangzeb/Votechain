import '../entities/auth_user.dart';

/// Registration payload for voter sign-up.
class RegisterRequest {
  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
  });

  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
}

/// Contract for authentication data access.
abstract interface class AuthRepository {
  Future<AuthUser> login({
    required String identifier,
    required String password,
  });

  Future<AuthUser> register(RegisterRequest request);

  Future<AuthUser> getCurrentUser();

  /// Restores a session from secure storage when a valid token exists.
  Future<AuthUser?> restoreSession();

  Future<void> clearSession();

  Future<void> requestPasswordReset({required String identifier});
}
