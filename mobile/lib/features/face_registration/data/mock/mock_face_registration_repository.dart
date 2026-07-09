import '../../domain/entities/face_registration_result.dart';
import '../../domain/repositories/face_registration_repository.dart';

/// In-memory mock face registration — no camera, DeepFace, or API.
class MockFaceRegistrationRepository implements FaceRegistrationRepository {
  static const mockResult = FaceRegistrationResult(
    embeddingId: 'emb_mock_7f3a9c2e',
    matchConfidence: 0.97,
    isDuplicateFree: true,
  );

  var _duplicateCheckFails = false;

  void setSimulateDuplicateFailure(bool value) => _duplicateCheckFails = value;

  @override
  Future<FaceRegistrationResult> processFaceEmbedding() async {
    await Future<void>.delayed(const Duration(milliseconds: 2800));
    if (_duplicateCheckFails) {
      throw const FaceRegistrationException(
        'Duplicate face detected. This profile is already registered.',
      );
    }
    return mockResult;
  }

  @override
  Future<bool> checkDuplicateRegistration() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return !_duplicateCheckFails;
  }

  @override
  Future<bool> verifyLiveFace({required bool faceAligned}) async {
    await Future<void>.delayed(const Duration(milliseconds: 3000));
    return faceAligned;
  }
}

/// Mock face pipeline failure.
class FaceRegistrationException implements Exception {
  const FaceRegistrationException(this.message);
  final String message;

  @override
  String toString() => message;
}
