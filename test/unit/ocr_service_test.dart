import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:retainly/services/local_ocr_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalOcrService language configuration', () {
    test('offers English, Urdu/English, Arabic/English and Punjabi/Gurmukhi', () {
      expect(LocalOcrService.languageOptions['English'], 'eng');
      expect(
        LocalOcrService.languageOptions['Urdu + Punjabi Shahmukhi (experimental fallback) + English'],
        'eng+urd',
      );
      expect(LocalOcrService.languageOptions['Arabic + English'], 'eng+ara');
      expect(
        LocalOcrService.languageOptions['Punjabi Gurmukhi + English'],
        'eng+pan',
      );
    });

    test('labels Shahmukhi recognition as an experimental Urdu-model fallback', () {
      final label = LocalOcrService.languageOptions.keys.firstWhere(
        (value) => value.toLowerCase().contains('shahmukhi'),
      );
      expect(label.toLowerCase(), contains('experimental'));
      expect(label.toLowerCase(), contains('urdu'));
      expect(label.toLowerCase(), isNot(contains('gurmukhi')));
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
