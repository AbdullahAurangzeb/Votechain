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

  static final RegExp _dashedCnicPattern = RegExp(r'^\d{5}-\d{7}-\d$');

  final String fullName;
  final String fatherName;
  final String cnicNumber;
  final String dateOfBirth;
  final String gender;
  final String nationality;
  final String issueDate;
  final String expiryDate;
  final double ocrConfidence;

  /// Normalizes digit CNIC values to `XXXXX-XXXXXXX-X`.
  static String normalizeCnic(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 13) {
      return value.trim();
    }

    return '${digits.substring(0, 5)}-'
        '${digits.substring(5, 12)}-'
        '${digits.substring(12)}';
  }

  /// Returns true when [value] is a valid Pakistani CNIC number.
  static bool isValidCnic(String value) {
    return _dashedCnicPattern.hasMatch(normalizeCnic(value));
  }

  /// Copy with [cnicNumber] normalized to dashed format when possible.
  CnicExtraction withNormalizedCnic() {
    return copyWith(cnicNumber: normalizeCnic(cnicNumber));
  }

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
