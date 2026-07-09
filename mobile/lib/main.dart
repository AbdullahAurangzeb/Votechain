import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/constants/env_config.dart';
import 'core/network/network_logging_interceptor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NetworkDebugLogger.logStartupConfig();
  debugPrint('[VoteChain] API base URL: ${EnvConfig.apiBaseUrl}');
  runApp(const ProviderScope(child: VoteChainApp()));
}
