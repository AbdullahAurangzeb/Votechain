import '../entities/auth_user.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

/// Validates credentials and delegates to [AuthRepository].
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String identifier,
    required String password,
  }) {
    final trimmedId = identifier.trim();
    if (trimmedId.isEmpty) {
      throw const AuthFailure('Email or CNIC is required.');
    }
    if (password.isEmpty) {
      throw const AuthFailure('Password is required.');
    }
    return _repository.login(identifier: trimmedId, password: password);
  }
}
