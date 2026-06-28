import '../../domain/entities/cnic_extraction.dart';
import '../../domain/repositories/verification_repository.dart';

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
}
