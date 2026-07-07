import '../entities/cnic_extraction.dart';
import '../entities/verification_status_result.dart';

/// Contract for identity verification data access.
abstract interface class VerificationRepository {
  Future<CnicExtraction> simulateOcrExtraction();

  /// Local transition from review to face registration (no API call).
  Future<void> submitForAdminReview(CnicExtraction extraction);

  /// Submits the completed verification package after face registration.
  Future<VerificationStatusResult> submitVerification(
    VerificationSubmission submission,
  );

  /// Fetches the authenticated user's verification status.
  Future<VerificationStatusResult> getVerificationStatus();
}
