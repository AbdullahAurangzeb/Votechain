import '../entities/face_registration_result.dart';

/// Contract for face registration — mock implementation only.
abstract interface class FaceRegistrationRepository {
  Future<FaceRegistrationResult> processFaceEmbedding();

  Future<bool> verifyLiveFace({required bool faceAligned});

  Future<bool> checkDuplicateRegistration();
}
