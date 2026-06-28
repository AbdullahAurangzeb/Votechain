import '../../domain/entities/auth_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';

/// In-memory mock auth repository — no network calls.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository();

  static const _mockUser = AuthUser(
    id: 'voter-001',
    fullName: 'Arslan Khalid',
    email: 'arslan.khalid@votechain.pk',
    phone: '+92 300 1234567',
    isVerified: false,
  );

  bool _sessionActive = false;

  @override
  Future<bool> hasActiveSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _sessionActive;
  }

  @override
  Future<AuthUser> login({
    required String identifier,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (password == 'wrong') {
      throw const AuthFailure('Invalid credentials. Please try again.');
    }

    _sessionActive = true;
    return _mockUser.copyWithIdentifier(identifier);
  }

  @override
  Future<AuthUser> register(RegisterRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    _sessionActive = true;
    return AuthUser(
      id: 'voter-new',
      fullName: request.fullName.trim(),
      email: request.email.trim(),
      phone: request.phone.trim(),
      isVerified: false,
    );
  }

  @override
  Future<void> requestPasswordReset({required String identifier}) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (identifier.contains('invalid')) {
      throw const AuthFailure('No account found for this identifier.');
    }
  }
}

extension on AuthUser {
  AuthUser copyWithIdentifier(String identifier) {
    final looksLikeEmail = identifier.contains('@');
    return AuthUser(
      id: id,
      fullName: fullName,
      email: looksLikeEmail ? identifier : email,
      phone: phone,
      isVerified: isVerified,
    );
  }
}
