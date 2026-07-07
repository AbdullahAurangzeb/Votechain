/// Account approval state returned by the backend.
enum ApprovalStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  const ApprovalStatus(this.apiValue);

  final String apiValue;

  static ApprovalStatus fromApi(String? value) {
    return ApprovalStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => ApprovalStatus.pending,
    );
  }
}

/// Identity verification state returned by the backend.
enum VerificationStatus {
  notStarted('not_started'),
  pending('pending'),
  verified('verified'),
  rejected('rejected');

  const VerificationStatus(this.apiValue);

  final String apiValue;

  static VerificationStatus fromApi(String? value) {
    return VerificationStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => VerificationStatus.notStarted,
    );
  }
}

/// User role returned by the backend.
enum UserRole {
  voter('voter'),
  admin('admin'),
  superAdmin('super_admin');

  const UserRole(this.apiValue);

  final String apiValue;

  static UserRole fromApi(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.apiValue == value,
      orElse: () => UserRole.voter,
    );
  }
}

/// Authenticated voter identity from the VoteChain API.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.approvalStatus,
    required this.verificationStatus,
    required this.faceRegistered,
    this.cnic,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;
  final ApprovalStatus approvalStatus;
  final VerificationStatus verificationStatus;
  final bool faceRegistered;
  final String? cnic;

  bool get isApproved => approvalStatus == ApprovalStatus.approved;

  /// Parses a user object from the API `data.user` payload.
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phoneNumber'] as String? ?? '',
      role: UserRole.fromApi(json['role'] as String?),
      approvalStatus: ApprovalStatus.fromApi(json['approvalStatus'] as String?),
      verificationStatus:
          VerificationStatus.fromApi(json['verificationStatus'] as String?),
      faceRegistered: json['faceRegistered'] as bool? ?? false,
      cnic: json['cnic'] as String?,
    );
  }
}
