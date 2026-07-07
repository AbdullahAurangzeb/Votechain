import '../../domain/entities/cnic_extraction.dart';
import '../../domain/entities/verification_status_result.dart';
import '../../domain/repositories/verification_repository.dart';
import '../../../authentication/domain/entities/auth_user.dart';

/// In-memory mock verification repository — no API or real OCR.
class MockVerificationRepository implements VerificationRepository {
  static const mockExtraction = CnicExtraction(
    fullName: 'Arslan Khalid',
    cnicNumber: '35202-1234567-1',
    dateOfBirth: '15 March 1998',
    gender: 'Male',
    nationality: 'Pakistani',
    issueDate: '12 January 2020',
    expiryDate: '12 January 2030',
    ocrConfidence: 0.99,
  );

  @override
  Future<CnicExtraction> simulateOcrExtraction() async {
    await Future<void>.delayed(const Duration(milliseconds: 3500));
    return mockExtraction;
  }

  @override
  Future<void> submitForAdminReview(CnicExtraction extraction) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
  }

  @override
  Future<VerificationStatusResult> submitVerification(
    VerificationSubmission submission,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return const VerificationStatusResult(
      verificationStatus: VerificationStatus.pending,
      approvalStatus: ApprovalStatus.pending,
      faceRegistered: true,
      cnic: '35202-1234567-1',
    );
  }

  @override
  Future<VerificationStatusResult> getVerificationStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const VerificationStatusResult(
      verificationStatus: VerificationStatus.notStarted,
      approvalStatus: ApprovalStatus.pending,
      faceRegistered: false,
    );
  }
}
