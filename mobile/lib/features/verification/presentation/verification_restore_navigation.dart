import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../authentication/domain/entities/auth_user.dart';
import '../../authentication/presentation/auth_navigation.dart';
import 'providers/verification_providers.dart';

/// Restores saved verification progress and routes the authenticated user.
Future<void> navigateWithVerificationRestore(
  WidgetRef ref,
  GoRouter router,
  AuthUser user,
) async {
  final savedProgress = await ref.read(verificationProgressStorageProvider).load();
  await ref
      .read(verificationFlowControllerProvider.notifier)
      .restoreSavedProgress(savedProgress);
  navigateAfterAuthentication(
    router,
    user,
    savedProgress: savedProgress,
  );
}
