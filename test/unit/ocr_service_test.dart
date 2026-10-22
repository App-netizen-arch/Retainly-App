import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:retainly/services/local_ocr_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalOcrService language configuration', () {
    test('offers English, Urdu/English, Arabic/English and Punjabi/Gurmukhi', () {
      expect(LocalOcrService.languageOptions['English'], 'eng');
      expect(
        LocalOcrService.languageOptions['Urdu + Punjabi Shahmukhi (experimental) + English'],
        'eng+urd',
      );
      expect(LocalOcrService.languageOptions['Arabic + English'], 'eng+ara');
      expect(
        LocalOcrService.languageOptions['Punjabi Gurmukhi + English'],
        'eng+pan',
      );
    });

    test('does not label the Gurmukhi model as Shahmukhi support', () {
      expect(
        LocalOcrService.languageOptions.keys.any(
          (label) => label.toLowerCase().contains('shahmukhi') &&
              !label.toLowerCase().contains('fallback'),
        ),
        isFalse,
      );
    });
  });

  group('LocalOcrService input validation', () {
    test('missing image fails locally with FileSystemException', () async {
      final service = LocalOcrService();
      await expectLater(
        service.extractImageText('/this/file/does/not/exist.png'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('missing PDF fails locally with FileSystemException', () async {
      final service = LocalOcrService();
      await expectLater(
        service.extractPdfText('/this/file/does/not/exist.pdf'),
        throwsA(isA<FileSystemException>()),
      );
    });
  });
}
