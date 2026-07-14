import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../authentication/domain/entities/auth_user.dart';
import '../../authentication/presentation/auth_navigation.dart';
import 'providers/verification_providers.dart';

/// Restores verification progress for [user] only, then routes accordingly.
///
/// Progress left by a previous account is cleared so a newly registered user
/// with [VerificationStatus.notStarted] always begins at Upload CNIC.
Future<void> navigateWithVerificationRestore(
  WidgetRef ref,
  GoRouter router,
  AuthUser user,
) async {
  final storage = ref.read(verificationProgressStorageProvider);
  final flow = ref.read(verificationFlowControllerProvider.notifier);

  final savedProgress = await storage.loadForUser(user.id);
  flow.bindUser(user.id);

  if (savedProgress == null) {
    // Fresh user or mismatched prior session — start clean at Upload CNIC.
    flow.resetSessionState();
  } else {
    await flow.restoreSavedProgress(savedProgress);
  }

  navigateAfterAuthentication(
    router,
    user,
    savedProgress: savedProgress,
  );
}
