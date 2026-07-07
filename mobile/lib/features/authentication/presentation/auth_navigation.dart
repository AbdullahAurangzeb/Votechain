import 'package:go_router/go_router.dart';

import '../../dashboard/presentation/dashboard_routes.dart';
import '../../verification/presentation/verification_routes.dart';
import '../domain/entities/auth_user.dart';

/// Routes the user after authentication based on verification and approval status.
void navigateAfterAuthentication(GoRouter router, AuthUser user) {
  router.go(resolvePostAuthRoute(user));
}

/// Resolves the post-authentication destination for [user].
String resolvePostAuthRoute(AuthUser user) {
  switch (user.verificationStatus) {
    case VerificationStatus.rejected:
      return VerificationRoutes.failed;
    case VerificationStatus.notStarted:
      return VerificationRoutes.uploadCnic;
    case VerificationStatus.pending:
      return VerificationRoutes.pending;
    case VerificationStatus.verified:
      if (user.approvalStatus == ApprovalStatus.approved) {
        return DashboardRoutes.home;
      }
      return VerificationRoutes.pending;
  }
}
