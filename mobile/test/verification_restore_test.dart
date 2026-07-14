import 'package:flutter_test/flutter_test.dart';
import 'package:votechain_mobile/features/authentication/domain/entities/auth_user.dart';
import 'package:votechain_mobile/features/authentication/presentation/auth_navigation.dart';
import 'package:votechain_mobile/features/dashboard/presentation/dashboard_routes.dart';
import 'package:votechain_mobile/features/face_registration/presentation/face_registration_routes.dart';
import 'package:votechain_mobile/features/verification/data/verification_progress_storage.dart';
import 'package:votechain_mobile/features/verification/domain/entities/verification_local_step.dart';
import 'package:votechain_mobile/features/verification/presentation/verification_routes.dart';

void main() {
  const newUser = AuthUser(
    id: 'user-new',
    fullName: 'Test User',
    email: 'test@example.com',
    phone: '03001234567',
    role: UserRole.voter,
    approvalStatus: ApprovalStatus.pending,
    verificationStatus: VerificationStatus.notStarted,
    faceRegistered: false,
  );

  test('new not_started user with no progress goes to Upload CNIC', () {
    final route = resolvePostAuthRoute(newUser);
    expect(route, VerificationRoutes.uploadCnic);
  });

  test('new not_started user ignores another users facePending progress', () {
    final route = resolvePostAuthRoute(
      newUser,
      savedProgress: const VerificationSavedProgress(
        userId: 'someone-else',
        step: VerificationLocalStep.facePending,
      ),
    );

    expect(route, VerificationRoutes.uploadCnic);
  });

  test('new not_started user ignores legacy unscoped progress', () {
    final route = resolvePostAuthRoute(
      newUser,
      savedProgress: const VerificationSavedProgress(
        step: VerificationLocalStep.facePending,
      ),
    );

    expect(route, VerificationRoutes.uploadCnic);
  });

  test('routes ocr completed local progress to review for same user', () {
    final route = resolvePostAuthRoute(
      newUser,
      savedProgress: const VerificationSavedProgress(
        userId: 'user-new',
        step: VerificationLocalStep.ocrCompleted,
      ),
    );

    expect(route, VerificationRoutes.review);
  });

  test('routes face pending local progress to face registration for same user',
      () {
    final route = resolvePostAuthRoute(
      newUser,
      savedProgress: const VerificationSavedProgress(
        userId: 'user-new',
        step: VerificationLocalStep.facePending,
      ),
    );

    expect(route, FaceRegistrationRoutes.register);
  });

  test('routes upload local progress to Upload CNIC for same user', () {
    final route = resolvePostAuthRoute(
      newUser,
      savedProgress: const VerificationSavedProgress(
        userId: 'user-new',
        step: VerificationLocalStep.upload,
      ),
    );

    expect(route, VerificationRoutes.uploadCnic);
  });

  test('backend pending always goes to Verification Pending', () {
    final route = resolvePostAuthRoute(
      const AuthUser(
        id: '1',
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '03001234567',
        role: UserRole.voter,
        approvalStatus: ApprovalStatus.pending,
        verificationStatus: VerificationStatus.pending,
        faceRegistered: true,
      ),
      savedProgress: const VerificationSavedProgress(
        userId: '1',
        step: VerificationLocalStep.facePending,
      ),
    );

    expect(route, VerificationRoutes.pending);
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
