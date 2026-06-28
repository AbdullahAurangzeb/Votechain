import '../entities/auth_user.dart';

/// Registration payload for step 1 (personal information).
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

/// Contract for authentication data access — implemented by mock/API layer.
abstract interface class AuthRepository {
  Future<AuthUser> login({
    required String identifier,
    required String password,
  });

  Future<AuthUser> register(RegisterRequest request);

  Future<void> requestPasswordReset({required String identifier});

  Future<bool> hasActiveSession();
}
