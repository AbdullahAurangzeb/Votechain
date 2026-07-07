import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure persistence for JWT access tokens.
///
/// Keeps an in-memory copy so authenticated requests work reliably on web
/// within the same app session even if secure storage reads are delayed.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              webOptions: WebOptions(
                dbName: 'VoteChainSecureStorage',
                publicKey: 'VoteChainSecureStorage',
              ),
            );

  static const _accessTokenKey = 'votechain_access_token';

  final FlutterSecureStorage _storage;
  String? _memoryToken;

  /// Reads the stored access token, if any.
  Future<String?> readAccessToken() async {
    if (_memoryToken != null && _memoryToken!.isNotEmpty) {
      return _memoryToken;
    }

    final storedToken = await _storage.read(key: _accessTokenKey);
    if (storedToken != null && storedToken.isNotEmpty) {
      _memoryToken = storedToken;
    }

    return storedToken;
  }

  /// Persists the access token from a successful login.
  Future<void> saveAccessToken(String token) async {
    _memoryToken = token;
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Clears the stored access token on logout or invalid session.
  Future<void> clearAccessToken() async {
    _memoryToken = null;
    await _storage.delete(key: _accessTokenKey);
  }
}
