/// OCR-extracted CNIC identity fields.
class CnicExtraction {
  const CnicExtraction({
    required this.fullName,
    required this.fatherName,
    required this.cnicNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.nationality,
    required this.issueDate,
    required this.expiryDate,
    required this.ocrConfidence,
  });

  final String fullName;
  final String fatherName;
  final String cnicNumber;
  final String dateOfBirth;
  final String gender;
  final String nationality;
  final String issueDate;
  final String expiryDate;
  final double ocrConfidence;

  CnicExtraction copyWith({
    String? fullName,
    String? fatherName,
    String? cnicNumber,
    String? dateOfBirth,
    String? gender,
    String? nationality,
    String? issueDate,
    String? expiryDate,
    double? ocrConfidence,
  }) {
    return CnicExtraction(
      fullName: fullName ?? this.fullName,
      fatherName: fatherName ?? this.fatherName,
      cnicNumber: cnicNumber ?? this.cnicNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
    );
  }
}
