/// Result model returned by on-device OCR parsing.
class OcrResult {
  const OcrResult({
    required this.name,
    required this.fatherName,
    required this.husbandName,
    required this.cnic,
    required this.dateOfBirth,
    required this.gender,
    required this.issueDate,
    required this.expiryDate,
    required this.rawText,
    required this.normalizedText,
  });

  final String? name;
  final String? fatherName;
  final String? husbandName;
  final String? cnic;
  final String? dateOfBirth;
  final String? gender;
  final String? issueDate;
  final String? expiryDate;
  final List<String> rawText;
  final List<String> normalizedText;
}
