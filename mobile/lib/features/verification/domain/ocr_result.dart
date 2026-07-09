/// Result model returned by on-device OCR parsing.
class OcrResult {
  const OcrResult({
    required this.name,
    required this.cnic,
    required this.dateOfBirth,
    required this.gender,
    required this.fatherName,
    required this.issueDate,
    required this.expiryDate,
    required this.rawText,
  });

  final String? name;
  final String? cnic;
  final String? dateOfBirth;
  final String? gender;
  final String? fatherName;
  final String? issueDate;
  final String? expiryDate;
  final List<String> rawText;
}
