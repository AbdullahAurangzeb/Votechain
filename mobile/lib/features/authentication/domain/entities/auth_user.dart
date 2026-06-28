/// Registered voter identity returned by mock auth flows.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.isVerified,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final bool isVerified;
}
