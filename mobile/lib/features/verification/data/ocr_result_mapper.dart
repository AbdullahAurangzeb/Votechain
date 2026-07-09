import '../domain/entities/cnic_extraction.dart';
import '../domain/ocr_result.dart';

/// Maps parsed OCR output into the verification domain model.
class OcrResultMapper {
  const OcrResultMapper();

  CnicExtraction toCnicExtraction(OcrResult result) {
    final name = result.name?.trim() ?? '';
    final cnic = result.cnic?.trim() ?? '';
    final dateOfBirth = result.dateOfBirth?.trim() ?? '';
    final gender = result.gender?.trim() ?? '';
    final fatherName = result.fatherName?.trim() ?? '';
    final issueDate = result.issueDate?.trim() ?? '';
    final expiryDate = result.expiryDate?.trim() ?? '';

    return CnicExtraction(
      fullName: name,
      fatherName: fatherName,
      cnicNumber: cnic,
      dateOfBirth: dateOfBirth,
      gender: gender,
      nationality: '',
      issueDate: issueDate,
      expiryDate: expiryDate,
      ocrConfidence: _calculateConfidence(
        name: name,
        cnic: cnic,
        dateOfBirth: dateOfBirth,
        gender: gender,
        fatherName: fatherName,
        issueDate: issueDate,
        expiryDate: expiryDate,
      ),
    );
  }

  double _calculateConfidence({
    required String name,
    required String cnic,
    required String dateOfBirth,
    required String gender,
    required String fatherName,
    required String issueDate,
    required String expiryDate,
  }) {
    const totalFields = 7;
    final completedFields = [
      name,
      cnic,
      dateOfBirth,
      gender,
      fatherName,
      issueDate,
      expiryDate,
    ].where((field) => field.isNotEmpty).length;
    return completedFields / totalFields;
  }
}
