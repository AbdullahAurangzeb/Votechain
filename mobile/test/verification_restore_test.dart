import 'package:flutter_test/flutter_test.dart';
import 'package:votechain_mobile/features/authentication/domain/entities/auth_user.dart';
import 'package:votechain_mobile/features/authentication/presentation/auth_navigation.dart';
import 'package:votechain_mobile/features/dashboard/presentation/dashboard_routes.dart';
import 'package:votechain_mobile/features/face_registration/presentation/face_registration_routes.dart';
import 'package:votechain_mobile/features/verification/data/verification_progress_storage.dart';
import 'package:votechain_mobile/features/verification/domain/entities/verification_local_step.dart';
import 'package:votechain_mobile/features/verification/presentation/verification_routes.dart';

void main() {
  const user = AuthUser(
    id: '1',
    fullName: 'Test User',
    email: 'test@example.com',
    phone: '03001234567',
    role: UserRole.voter,
    approvalStatus: ApprovalStatus.pending,
    verificationStatus: VerificationStatus.notStarted,
    faceRegistered: false,
  );

  test('routes ocr completed local progress to review', () {
    final route = resolvePostAuthRoute(
      user,
      savedProgress: const VerificationSavedProgress(
        step: VerificationLocalStep.ocrCompleted,
      ),
    );

    expect(route, VerificationRoutes.review);
  });

  test('routes face pending local progress to face registration', () {
    final route = resolvePostAuthRoute(
      user,
      savedProgress: const VerificationSavedProgress(
        step: VerificationLocalStep.facePending,
      ),
    );

    expect(route, FaceRegistrationRoutes.register);
  });

  test('routes approved verified users to dashboard', () {
    final route = resolvePostAuthRoute(
      const AuthUser(
        id: '1',
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '03001234567',
        role: UserRole.voter,
        approvalStatus: ApprovalStatus.approved,
        verificationStatus: VerificationStatus.verified,
        faceRegistered: true,
      ),
    );

    expect(route, DashboardRoutes.home);
  });
}
