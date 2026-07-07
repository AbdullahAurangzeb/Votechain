import 'mock/mock_verification_repository.dart';
import '../domain/entities/cnic_extraction.dart';
import '../domain/entities/verification_status_result.dart';
import '../domain/failures/verification_failure.dart';
import '../domain/repositories/verification_repository.dart';
import 'verification_remote_data_source.dart';

/// API-backed verification repository with mock OCR for local UI flow.
class VerificationRepositoryImpl implements VerificationRepository {
  VerificationRepositoryImpl({
    required VerificationRemoteDataSource remoteDataSource,
    MockVerificationRepository? mockRepository,
  })  : _remoteDataSource = remoteDataSource,
        _mockRepository = mockRepository ?? MockVerificationRepository();

  final VerificationRemoteDataSource _remoteDataSource;
  final MockVerificationRepository _mockRepository;

  @override
  Future<CnicExtraction> simulateOcrExtraction() =>
      _mockRepository.simulateOcrExtraction();

  @override
  Future<void> submitForAdminReview(CnicExtraction extraction) =>
      _mockRepository.submitForAdminReview(extraction);

  @override
  Future<VerificationStatusResult> submitVerification(
    VerificationSubmission submission,
  ) async {
    try {
      return await _remoteDataSource.submitVerification(submission);
    } catch (error) {
      throw VerificationRemoteDataSource.mapException(error);
    }
  }

  @override
  Future<VerificationStatusResult> getVerificationStatus() async {
    try {
      return await _remoteDataSource.getVerificationStatus();
    } catch (error) {
      throw VerificationRemoteDataSource.mapException(error);
    }
  }
}
