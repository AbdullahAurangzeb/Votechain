import 'package:go_router/go_router.dart';

import '../../dashboard/presentation/dashboard_routes.dart';
import '../../face_registration/presentation/face_registration_routes.dart';
import '../../verification/data/verification_progress_storage.dart';
import '../../verification/domain/entities/verification_local_step.dart';
import '../../verification/presentation/verification_routes.dart';
import '../domain/entities/auth_user.dart';

/// Routes the user after authentication based on verification and approval status.
void navigateAfterAuthentication(
  GoRouter router,
  AuthUser user, {
  VerificationSavedProgress? savedProgress,
}) {
  router.go(resolvePostAuthRoute(user, savedProgress: savedProgress));
}

/// Resolves the post-authentication destination for [user].
String resolvePostAuthRoute(
  AuthUser user, {
  VerificationSavedProgress? savedProgress,
}) {
  if (user.approvalStatus == ApprovalStatus.approved &&
      user.verificationStatus == VerificationStatus.verified) {
    return DashboardRoutes.home;
  }

  switch (user.verificationStatus) {
    case VerificationStatus.rejected:
      return VerificationRoutes.failed;
    case VerificationStatus.pending:
      return VerificationRoutes.pending;
    case VerificationStatus.verified:
      return VerificationRoutes.pending;
    case VerificationStatus.notStarted:
      return _resolveLocalProgressRoute(savedProgress);
  }
}

String _resolveLocalProgressRoute(VerificationSavedProgress? savedProgress) {
  if (savedProgress == null) {
    return VerificationRoutes.uploadCnic;
  }

  switch (savedProgress.step) {
    case VerificationLocalStep.facePending:
      return FaceRegistrationRoutes.register;
    case VerificationLocalStep.ocrCompleted:
      return VerificationRoutes.review;
    case VerificationLocalStep.upload:
      return VerificationRoutes.uploadCnic;
  }
}
