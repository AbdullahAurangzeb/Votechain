import 'package:flutter/foundation.dart';

/// Environment configuration — never hardcode secrets in code.
///
/// Override at build/run time:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.x.x:5000`
abstract final class EnvConfig {
  /// Full API base URL override (highest priority).
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// PC LAN IPv4 used for physical Android when [API_BASE_URL] is not set.
  static const String apiLanHost = String.fromEnvironment(
    'API_LAN_HOST',
    defaultValue: '10.172.223.57',
  );

  /// Backend port shared by platform defaults.
  static const String apiPort = String.fromEnvironment(
    'API_PORT',
    defaultValue: '5000',
  );

  /// Resolved API base URL for the active platform/run target.
  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _normalizeUrl(_apiBaseUrlOverride);
    }
    return _normalizeUrl(_defaultForPlatform());
  }

  /// Raw compile-time [API_BASE_URL] value (empty when not set).
  static String get apiBaseUrlOverride => _apiBaseUrlOverride;

  /// Whether [API_BASE_URL] was provided via `--dart-define`.
  static bool get hasUrlOverride => _apiBaseUrlOverride.isNotEmpty;

  static String _defaultForPlatform() {
    if (kIsWeb) {
      return 'http://localhost:$apiPort';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Physical device: host machine LAN IP.
      // Android emulator: use --dart-define=API_BASE_URL=http://10.0.2.2:5000
      return 'http://$apiLanHost:$apiPort';
    }

    return 'http://localhost:$apiPort';
  }

  static String _normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
