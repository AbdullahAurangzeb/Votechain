/// Domain-level verification failure.
class VerificationFailure implements Exception {
  const VerificationFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
