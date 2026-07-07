import '../../../core/network/token_storage.dart';
import '../domain/entities/auth_user.dart';
import '../domain/failures/auth_failure.dart';
import '../domain/repositories/auth_repository.dart';
import 'auth_remote_data_source.dart';

/// API-backed authentication repository.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthUser> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final email = _emailFromIdentifier(identifier);
      final result = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      await _tokenStorage.saveAccessToken(result.token);

      final user = await _remoteDataSource.getCurrentUser();
      return user;
    } catch (error) {
      await _tokenStorage.clearAccessToken();
      throw AuthRemoteDataSource.mapException(error);
    }
  }

  @override
  Future<AuthUser> register(RegisterRequest request) async {
    try {
      await _remoteDataSource.register(
        fullName: request.fullName.trim(),
        email: request.email.trim(),
        phoneNumber: request.phone.trim(),
        password: request.password,
      );

      final loginResult = await _remoteDataSource.login(
        email: request.email.trim(),
        password: request.password,
      );
      await _tokenStorage.saveAccessToken(loginResult.token);

      return loginResult.user;
    } catch (error) {
      throw AuthRemoteDataSource.mapException(error);
    }
  }

  @override
  Future<AuthUser> getCurrentUser() async {
    try {
      return await _remoteDataSource.getCurrentUser();
    } catch (error) {
      throw AuthRemoteDataSource.mapException(error);
    }
  }

  @override
  Future<AuthUser?> restoreSession() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      return await _remoteDataSource.getCurrentUser();
    } catch (_) {
      await _tokenStorage.clearAccessToken();
      return null;
    }
  }

  @override
  Future<void> clearSession() => _tokenStorage.clearAccessToken();

  @override
  Future<void> requestPasswordReset({required String identifier}) async {
    if (identifier.trim().isEmpty) {
      throw const AuthFailure('Email or CNIC is required.');
    }

    throw const AuthFailure(
      'Password reset is not available yet. Please contact support.',
    );
  }

  String _emailFromIdentifier(String identifier) {
    final trimmed = identifier.trim();

    if (!trimmed.contains('@')) {
      throw const AuthFailure('Please sign in with your registered email address.');
    }

    return trimmed;
  }
}
