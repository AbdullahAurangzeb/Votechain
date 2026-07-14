import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cnic_image_preprocessor.dart';
import '../../data/cnic_parser.dart';
import '../../data/local_ocr_repository_impl.dart';
import '../../data/mlkit_ocr_service.dart';
import '../../data/ocr_result_mapper.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../controllers/ocr_controller.dart';

final cnicParserProvider = Provider<CnicParser>((_) => const CnicParser());

final ocrResultMapperProvider =
    Provider<OcrResultMapper>((_) => const OcrResultMapper());

final cnicImagePreprocessorProvider =
    Provider<CnicImagePreprocessor>((_) => const CnicImagePreprocessor());

final mlKitOcrServiceProvider = Provider<MlKitOcrService>((ref) {
  return MlKitOcrService(
    preprocessor: ref.watch(cnicImagePreprocessorProvider),
  );
});

final ocrRepositoryProvider = Provider<OcrRepository>((ref) {
  return LocalOcrRepositoryImpl(
    ocrService: ref.watch(mlKitOcrServiceProvider),
    parser: ref.watch(cnicParserProvider),
    mapper: ref.watch(ocrResultMapperProvider),
  );
});

final ocrControllerProvider = Provider<OcrController>((ref) {
  return OcrController(ref.watch(ocrRepositoryProvider));
});
