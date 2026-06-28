/// Mock face registration outcome returned after AI processing.
class FaceRegistrationResult {
  const FaceRegistrationResult({
    required this.embeddingId,
    required this.matchConfidence,
    required this.isDuplicateFree,
  });

  final String embeddingId;
  final double matchConfidence;
  final bool isDuplicateFree;
}
