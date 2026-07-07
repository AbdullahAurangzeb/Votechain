import '../../../authentication/domain/entities/auth_user.dart';

/// Verification status returned by the backend API.
class VerificationStatusResult {
  const VerificationStatusResult({
    required this.verificationStatus,
    required this.approvalStatus,
    required this.faceRegistered,
    this.cnic,
    this.cnicFrontImageUrl,
    this.cnicBackImageUrl,
    this.verificationSubmittedAt,
  });

  final VerificationStatus verificationStatus;
  final ApprovalStatus approvalStatus;
  final bool faceRegistered;
  final String? cnic;
  final String? cnicFrontImageUrl;
  final String? cnicBackImageUrl;
  final DateTime? verificationSubmittedAt;

  factory VerificationStatusResult.fromJson(Map<String, dynamic> json) {
    return VerificationStatusResult(
      verificationStatus:
          VerificationStatus.fromApi(json['verificationStatus'] as String?),
      approvalStatus: ApprovalStatus.fromApi(json['approvalStatus'] as String?),
      faceRegistered: json['faceRegistered'] as bool? ?? false,
      cnic: json['cnic'] as String?,
      cnicFrontImageUrl: json['cnicFrontImageUrl'] as String?,
      cnicBackImageUrl: json['cnicBackImageUrl'] as String?,
      verificationSubmittedAt: json['verificationSubmittedAt'] != null
          ? DateTime.tryParse(json['verificationSubmittedAt'].toString())
          : null,
    );
  }
}

/// Payload for submitting a completed verification package.
class VerificationSubmission {
  const VerificationSubmission({
    required this.cnicNumber,
    required this.cnicFrontImageUrl,
    required this.cnicBackImageUrl,
  });

  final String cnicNumber;
  final String cnicFrontImageUrl;
  final String cnicBackImageUrl;
}
