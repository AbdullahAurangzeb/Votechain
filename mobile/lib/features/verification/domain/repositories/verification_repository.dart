import '../entities/cnic_extraction.dart';

/// Contract for identity verification data — mock implementation only.
abstract interface class VerificationRepository {
  Future<CnicExtraction> simulateOcrExtraction();

  Future<void> submitForAdminReview(CnicExtraction extraction);
}
