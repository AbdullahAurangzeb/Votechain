import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/entities/cnic_extraction.dart';
import '../domain/entities/verification_local_step.dart';

/// Persists in-progress verification state across app restarts, scoped per user.
class VerificationProgressStorage {
  VerificationProgressStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _userIdKey = 'verification_user_id';
  static const _stepKey = 'verification_local_step';
  static const _extractionKey = 'verification_extraction_json';
  static const _frontUploadedKey = 'verification_front_uploaded';
  static const _backUploadedKey = 'verification_back_uploaded';
  static const _frontUrlKey = 'verification_front_url';
  static const _backUrlKey = 'verification_back_url';

  final FlutterSecureStorage _storage;

  Future<void> save({
    required String userId,
    required VerificationLocalStep step,
    CnicExtraction? extraction,
    bool frontUploaded = false,
    bool backUploaded = false,
    String? cnicFrontImageUrl,
    String? cnicBackImageUrl,
  }) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _stepKey, value: step.storageValue);
    await _storage.write(
      key: _frontUploadedKey,
      value: frontUploaded.toString(),
    );
    await _storage.write(
      key: _backUploadedKey,
      value: backUploaded.toString(),
    );

    if (extraction != null) {
      await _storage.write(
        key: _extractionKey,
        value: CnicExtractionCodec.encode(extraction),
      );
    }

    if (cnicFrontImageUrl != null) {
      await _storage.write(key: _frontUrlKey, value: cnicFrontImageUrl);
    }
    if (cnicBackImageUrl != null) {
      await _storage.write(key: _backUrlKey, value: cnicBackImageUrl);
    }
  }

  Future<VerificationSavedProgress?> load() async {
    final stepValue = await _storage.read(key: _stepKey);
    if (stepValue == null) return null;

    final extractionJson = await _storage.read(key: _extractionKey);
    final frontUploaded =
        (await _storage.read(key: _frontUploadedKey)) == 'true';
    final backUploaded = (await _storage.read(key: _backUploadedKey)) == 'true';

    return VerificationSavedProgress(
      userId: await _storage.read(key: _userIdKey),
      step: VerificationLocalStep.fromStorage(stepValue),
      extraction: extractionJson == null
          ? null
          : CnicExtractionCodec.tryDecode(extractionJson),
      frontUploaded: frontUploaded,
      backUploaded: backUploaded,
      cnicFrontImageUrl: await _storage.read(key: _frontUrlKey),
      cnicBackImageUrl: await _storage.read(key: _backUrlKey),
    );
  }

  /// Returns saved progress only when it belongs to [userId]; otherwise clears it.
  Future<VerificationSavedProgress?> loadForUser(String userId) async {
    final saved = await load();
    if (saved == null) return null;

    if (saved.userId == null || saved.userId != userId) {
      await clear();
      return null;
    }

    return saved;
  }

  Future<void> clear() async {
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _stepKey);
    await _storage.delete(key: _extractionKey);
    await _storage.delete(key: _frontUploadedKey);
    await _storage.delete(key: _backUploadedKey);
    await _storage.delete(key: _frontUrlKey);
    await _storage.delete(key: _backUrlKey);
  }
}

/// Restored local verification progress snapshot.
class VerificationSavedProgress {
  const VerificationSavedProgress({
    required this.step,
    this.userId,
    this.extraction,
    this.frontUploaded = false,
    this.backUploaded = false,
    this.cnicFrontImageUrl,
    this.cnicBackImageUrl,
  });

  /// Owner of this progress. Null means legacy / unscoped data.
  final String? userId;
  final VerificationLocalStep step;
  final CnicExtraction? extraction;
  final bool frontUploaded;
  final bool backUploaded;
  final String? cnicFrontImageUrl;
  final String? cnicBackImageUrl;
}

/// JSON codec for [CnicExtraction] persistence.
abstract final class CnicExtractionCodec {
  static String encode(CnicExtraction extraction) {
    return [
      extraction.fullName,
      extraction.fatherName,
      extraction.cnicNumber,
      extraction.dateOfBirth,
      extraction.gender,
      extraction.nationality,
      extraction.issueDate,
      extraction.expiryDate,
      extraction.ocrConfidence.toString(),
    ].join('\u001f');
  }

  static CnicExtraction? tryDecode(String value) {
    final parts = value.split('\u001f');
    if (parts.length < 9) return null;

    return CnicExtraction(
      fullName: parts[0],
      fatherName: parts[1],
      cnicNumber: parts[2],
      dateOfBirth: parts[3],
      gender: parts[4],
      nationality: parts[5],
      issueDate: parts[6],
      expiryDate: parts[7],
      ocrConfidence: double.tryParse(parts[8]) ?? 0,
    );
  }
}
