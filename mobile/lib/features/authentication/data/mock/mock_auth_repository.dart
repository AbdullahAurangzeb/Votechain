import '../../domain/entities/auth_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';

/// In-memory mock auth repository for tests and offline development.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository();

  static const _mockUser = AuthUser(
    id: 'voter-001',
    fullName: 'Arslan Khalid',
    email: 'arslan.khalid@votechain.pk',
    phone: '+92 300 1234567',
    role: UserRole.voter,
    approvalStatus: ApprovalStatus.pending,
    verificationStatus: VerificationStatus.notStarted,
    faceRegistered: false,
  );

  AuthUser? _sessionUser;

  @override
  Future<AuthUser?> restoreSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _sessionUser;
  }

  @override
  Future<AuthUser> getCurrentUser() async {
    if (_sessionUser == null) {
      throw const AuthFailure('Authentication required');
    }
    return _sessionUser!;
  }

  @override
  Future<void> clearSession() async {
    _sessionUser = null;
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

    _sessionUser = _mockUser.copyWithIdentifier(identifier);
    return _sessionUser!;
  }

  @override
  Future<AuthUser> register(RegisterRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    return AuthUser(
      id: 'voter-new',
      fullName: request.fullName.trim(),
      email: request.email.trim(),
      phone: request.phone.trim(),
      role: UserRole.voter,
      approvalStatus: ApprovalStatus.pending,
      verificationStatus: VerificationStatus.notStarted,
      faceRegistered: false,
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
      role: role,
      approvalStatus: approvalStatus,
      verificationStatus: verificationStatus,
      faceRegistered: faceRegistered,
      cnic: cnic,
    );
  }
}
