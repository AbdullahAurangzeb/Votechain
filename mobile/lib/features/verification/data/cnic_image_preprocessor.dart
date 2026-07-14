import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../domain/failures/verification_failure.dart';
import 'ocr_debug_logger.dart';

/// Result of CNIC image preprocessing prior to ML Kit OCR.
class PreprocessedCnicImage {
  const PreprocessedCnicImage({
    required this.file,
    required this.originalWidth,
    required this.originalHeight,
    required this.processedWidth,
    required this.processedHeight,
  });

  final XFile file;
  final int originalWidth;
  final int originalHeight;
  final int processedWidth;
  final int processedHeight;
}

/// Improves CNIC photo quality for Google ML Kit text recognition.
class CnicImagePreprocessor {
  const CnicImagePreprocessor();

  static const int _minUsefulWidth = 720;
  static const int _maxUsefulWidth = 2400;
  static const double _minBlurVariance = 14;
  static const double _minMeanLuminance = 32;
  static const double _maxMeanLuminance = 248;

  /// Corrects EXIF orientation, contrast, sharpness, and size; rejects unusable images.
  Future<PreprocessedCnicImage> preprocess(XFile source) async {
    final bytes = await File(source.path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const VerificationFailure(
        'Unable to read the CNIC image. Please try another photo.',
      );
    }

    final originalWidth = decoded.width;
    final originalHeight = decoded.height;

    // bakeOrientation applies EXIF rotation so landscape/portrait scans align.
    var image = img.bakeOrientation(decoded);
    image = _trimBorders(image);
    image = _normalizeSize(image);
    image = _normalizeExposure(image);
    image = img.adjustColor(
      image,
      contrast: 1.22,
      brightness: 1.02,
      saturation: 0.88,
    );
    image = img.convolution(
      image,
      filter: const [0, -1, 0, -1, 5, -1, 0, -1, 0],
    );

    final quality = _assessQuality(image);
    if (quality.isTooDark || quality.isTooBright) {
      throw const VerificationFailure(
        'CNIC image is too dark or washed out. Retake in better lighting.',
      );
    }
    if (quality.isTooBlurry) {
      throw const VerificationFailure(
        'CNIC image is too blurry. Hold steady and retake the photo.',
      );
    }

    final outPath =
        '${Directory.systemTemp.path}${Platform.pathSeparator}'
        'cnic_ocr_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final encoded = img.encodeJpg(image, quality: 94);
    await File(outPath).writeAsBytes(encoded, flush: true);

    OcrDebugLogger.logPreprocess(
      originalWidth: originalWidth,
      originalHeight: originalHeight,
      processedWidth: image.width,
      processedHeight: image.height,
    );

    return PreprocessedCnicImage(
      file: XFile(outPath),
      originalWidth: originalWidth,
      originalHeight: originalHeight,
      processedWidth: image.width,
      processedHeight: image.height,
    );
  }

  /// Pulls darkish photos toward mid-tones without clipping highlights.
  img.Image _normalizeExposure(img.Image image) {
    final sample = _sampleMeanLuminance(image);
    if (sample >= 55 && sample <= 200) return image;

    if (sample < 55) {
      final boost = ((55 - sample) / 55).clamp(0.0, 0.45);
      return img.adjustColor(
        image,
        brightness: 1.0 + (boost * 0.55),
        contrast: 1.0 + (boost * 0.25),
      );
    }

    final pull = ((sample - 200) / 55).clamp(0.0, 0.35);
    return img.adjustColor(
      image,
      brightness: 1.0 - (pull * 0.2),
      contrast: 1.0 + (pull * 0.15),
    );
  }

  img.Image _normalizeSize(img.Image image) {
    if (image.width < _minUsefulWidth) {
      return img.copyResize(
        image,
        width: _minUsefulWidth,
        interpolation: img.Interpolation.cubic,
      );
    }

    if (image.width > _maxUsefulWidth) {
      return img.copyResize(
        image,
        width: _maxUsefulWidth,
        interpolation: img.Interpolation.average,
      );
    }

    return image;
  }

  /// Crops near-empty borders so ML Kit focuses on the card content.
  img.Image _trimBorders(img.Image image) {
    const threshold = 22;
    var top = 0;
    var bottom = image.height - 1;
    var left = 0;
    var right = image.width - 1;

    bool rowMostlyEmpty(int y) {
      var empty = 0;
      for (var x = 0; x < image.width; x++) {
        final luminance = img.getLuminance(image.getPixel(x, y));
        if (luminance < threshold || luminance > 255 - threshold) empty++;
      }
      return empty / image.width > 0.94;
    }

    bool columnMostlyEmpty(int x) {
      var empty = 0;
      for (var y = 0; y < image.height; y++) {
        final luminance = img.getLuminance(image.getPixel(x, y));
        if (luminance < threshold || luminance > 255 - threshold) empty++;
      }
      return empty / image.height > 0.94;
    }

    while (top < bottom && rowMostlyEmpty(top)) {
      top++;
    }
    while (bottom > top && rowMostlyEmpty(bottom)) {
      bottom--;
    }
    while (left < right && columnMostlyEmpty(left)) {
      left++;
    }
    while (right > left && columnMostlyEmpty(right)) {
      right--;
    }

    final width = right - left + 1;
    final height = bottom - top + 1;
    // Keep original when trim would remove too much (tilted card / busy bg).
    if (width < image.width * 0.6 || height < image.height * 0.6) {
      return image;
    }

    // Leave a small pad so card-edge text is not clipped.
    final padX = math.max(4, (width * 0.01).round());
    final padY = math.max(4, (height * 0.01).round());
    final cropX = math.max(0, left - padX);
    final cropY = math.max(0, top - padY);
    final cropW = math.min(image.width - cropX, width + (padX * 2));
    final cropH = math.min(image.height - cropY, height + (padY * 2));

    return img.copyCrop(
      image,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );
  }

  double _sampleMeanLuminance(img.Image image) {
    final stepX = math.max(1, image.width ~/ 100);
    final stepY = math.max(1, image.height ~/ 100);
    var sum = 0.0;
    var count = 0;
    for (var y = 0; y < image.height; y += stepY) {
      for (var x = 0; x < image.width; x += stepX) {
        sum += img.getLuminance(image.getPixel(x, y));
        count++;
      }
    }
    return count == 0 ? 0 : sum / count;
  }

  _ImageQuality _assessQuality(img.Image image) {
    final stepX = math.max(1, image.width ~/ 120);
    final stepY = math.max(1, image.height ~/ 120);

    var sum = 0.0;
    var count = 0;
    var laplacianSum = 0.0;
    var laplacianCount = 0;

    for (var y = 1; y < image.height - 1; y += stepY) {
      for (var x = 1; x < image.width - 1; x += stepX) {
        final center = img.getLuminance(image.getPixel(x, y));
        sum += center;
        count++;

        final left = img.getLuminance(image.getPixel(x - 1, y));
        final right = img.getLuminance(image.getPixel(x + 1, y));
        final up = img.getLuminance(image.getPixel(x, y - 1));
        final down = img.getLuminance(image.getPixel(x, y + 1));
        final lap = (left + right + up + down - (4 * center)).abs();
        laplacianSum += lap;
        laplacianCount++;
      }
    }

    final mean = count == 0 ? 0.0 : sum / count;
    final blurScore =
        laplacianCount == 0 ? 0.0 : laplacianSum / laplacianCount;

    if (kDebugMode) {
      debugPrint(
        '[VoteChain][OCR][Quality] meanLuminance=${mean.toStringAsFixed(1)} '
        'blurScore=${blurScore.toStringAsFixed(1)}',
      );
    }

    return _ImageQuality(
      isTooDark: mean < _minMeanLuminance,
      isTooBright: mean > _maxMeanLuminance,
      isTooBlurry: blurScore < _minBlurVariance,
    );
  }
}

class _ImageQuality {
  const _ImageQuality({
    required this.isTooDark,
    required this.isTooBright,
    required this.isTooBlurry,
  });

  final bool isTooDark;
  final bool isTooBright;
  final bool isTooBlurry;
}
