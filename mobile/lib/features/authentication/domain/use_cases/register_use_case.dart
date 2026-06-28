import '../entities/auth_user.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

/// Validates registration fields and delegates to [AuthRepository].
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call(RegisterRequest request) {
    if (request.fullName.trim().isEmpty) {
      throw const AuthFailure('Full name is required.');
    }
    if (request.email.trim().isEmpty) {
      throw const AuthFailure('Email address is required.');
    }
    if (!request.email.contains('@')) {
      throw const AuthFailure('Enter a valid email address.');
    }
    if (request.phone.trim().isEmpty) {
      throw const AuthFailure('Phone number is required.');
    }
    if (request.password.length < 8) {
      throw const AuthFailure('Password must be at least 8 characters.');
    }
    if (request.password != request.confirmPassword) {
      throw const AuthFailure('Passwords do not match.');
    }

    return _repository.register(request);
  }
}
