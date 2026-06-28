/// Identity verification GoRouter paths.
abstract final class VerificationRoutes {
  static const String uploadCnic = '/verify/cnic';
  static const String scanning = '/verify/scanning';
  static const String review = '/verify/review';
  static const String pending = '/verify/pending';

  static const String uploadCnicName = 'verify-upload-cnic';
  static const String scanningName = 'verify-scanning';
  static const String reviewName = 'verify-review';
  static const String pendingName = 'verify-pending';
}
