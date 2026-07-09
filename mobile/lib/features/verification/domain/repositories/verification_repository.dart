import '../entities/cnic_extraction.dart';
import '../entities/verification_status_result.dart';

/// Contract for verification submit/status API access.
abstract interface class VerificationRepository {
  /// Local transition from review to face registration (no API call).
  Future<void> submitForAdminReview(CnicExtraction extraction);

  /// Submits the completed verification package after face registration.
  Future<VerificationStatusResult> submitVerification(
    VerificationSubmission submission,
  );

  /// Fetches the authenticated user's verification status.
  Future<VerificationStatusResult> getVerificationStatus();
}
