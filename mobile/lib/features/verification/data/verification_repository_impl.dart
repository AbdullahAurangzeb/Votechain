import '../domain/entities/cnic_extraction.dart';
import '../domain/entities/verification_status_result.dart';
import '../domain/repositories/verification_repository.dart';
import 'verification_remote_data_source.dart';

/// Verification repository for submit/status backend APIs only.
class VerificationRepositoryImpl implements VerificationRepository {
  VerificationRepositoryImpl({
    required VerificationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final VerificationRemoteDataSource _remoteDataSource;

  @override
  Future<void> submitForAdminReview(CnicExtraction extraction) async {}

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
