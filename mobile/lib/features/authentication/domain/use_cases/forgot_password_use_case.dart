import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

/// Validates identifier and delegates password reset to [AuthRepository].
class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String identifier}) {
    final trimmed = identifier.trim();
    if (trimmed.isEmpty) {
      throw const AuthFailure('Email or CNIC is required.');
    }
    return _repository.requestPasswordReset(identifier: trimmed);
  }
}
