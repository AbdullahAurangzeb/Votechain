import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Fetches the authenticated user's profile from the API.
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call() => _repository.getCurrentUser();
}

/// Restores a persisted session when a valid JWT exists.
class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser?> call() => _repository.restoreSession();
}
