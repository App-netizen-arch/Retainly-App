import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:retainly/services/ai_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('AIService - OCR Operations', () {
    test('startOcrJob returns consent error without OCR consent', () async {
      final service = AIService();
      final result = await service.startOcrJob('user1', 'gs://bucket/file.pdf');
      expect(result, contains('OCR requires explicit consent'));
    });

    test('startOcrJob returns consent error even with AI consent', () async {
      final service = AIService();
      await service.setAiConsent(true);
      final result = await service.startOcrJob('user1', 'gs://bucket/file.pdf');
      expect(result, contains('OCR requires explicit consent'));
    });

    test('startOcrJob returns connectivity error with OCR consent but offline',
        () async {
      final service = AIService();
      await service.setOcrConsent(true);
      final result = await service.startOcrJob('user1', 'gs://bucket/file.pdf');
      expect(result, contains('No internet connection'));
    });

    test('startOcrJob passes effective path when storagePath is provided',
        () async {
      final service = AIService();
      await service.setOcrConsent(true);
      final result = await service.startOcrJob(
        'user1',
        'local/path.pdf',
        storagePath: 'gs://bucket/remote.pdf',
      );
      expect(result, contains('No internet connection'));
    });

    test('startOcrJob accepts custom language', () async {
      final service = AIService();
      await service.setOcrConsent(true);
      final result = await service.startOcrJob(
        'user1',
        'gs://bucket/file.pdf',
        language: 'ur',
      );
      expect(result, contains('No internet connection'));
    });
  });

  group('AIService - OCR Result Retrieval', () {
    test('getOcrResult returns null when Firebase unavailable', () async {
      final service = AIService();
      final result = await service.getOcrResult('user1', 'job123');
      expect(result, isNull);
    });
  });

  group('AIService - PDF Upload', () {
    test('uploadPdfToStorage returns null when Firebase unavailable', () async {
      final service = AIService();
      final result = await service.uploadPdfToStorage('user1', '/nonexistent/file.pdf');
      expect(result, isNull);
    });
  });

  group('AIService - Consent Record', () {
    test('ensureConsentRecord is a no-op when Firebase unavailable', () async {
      final service = AIService();
      await service.setAiConsent(true);
      await service.setOcrConsent(true);
      await expectLater(
        service.ensureConsentRecord('user1'),
        completes,
      );
    });
  });
}
