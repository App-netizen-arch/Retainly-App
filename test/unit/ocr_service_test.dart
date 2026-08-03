import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:retainly/services/ai_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('AIService - OCR Operations', () {
    test(
      'startOcrJob returns disabled message in the current release build',
      () async {
        final service = AIService();
        final result = await service.startOcrJob(
          'user1',
          'gs://bucket/file.pdf',
        );
        expect(result, contains('OCR is disabled in this release build'));
      },
    );

    test(
      'startOcrJob stays disabled even when AI consent is enabled',
      () async {
        final service = AIService();
        await service.setAiConsent(true);
        final result = await service.startOcrJob(
          'user1',
          'gs://bucket/file.pdf',
        );
        expect(result, contains('OCR is disabled in this release build'));
      },
    );

    test('startOcrJob stays disabled with OCR consent enabled', () async {
      final service = AIService();
      await service.setOcrConsent(true);
      final result = await service.startOcrJob('user1', 'gs://bucket/file.pdf');
      expect(result, contains('OCR is disabled in this release build'));
    });

    test(
      'startOcrJob ignores the provided storagePath in the release build',
      () async {
        final service = AIService();
        await service.setOcrConsent(true);
        final result = await service.startOcrJob(
          'user1',
          'local/path.pdf',
          storagePath: 'gs://bucket/remote.pdf',
        );
        expect(result, contains('OCR is disabled in this release build'));
      },
    );

    test('startOcrJob ignores custom language in the release build', () async {
      final service = AIService();
      await service.setOcrConsent(true);
      final result = await service.startOcrJob(
        'user1',
        'gs://bucket/file.pdf',
        language: 'ur',
      );
      expect(result, contains('OCR is disabled in this release build'));
    });
  });

  group('AIService - OCR Result Retrieval', () {
    test(
      'getOcrResult returns a disabled-state response in the release build',
      () async {
        final service = AIService();
        final result = await service.getOcrResult('user1', 'job123');
        expect(result, isNotNull);
        final payload = result!;
        expect(payload, isA<Map>());
        expect(payload['status'], 'disabled');
        expect(payload['extractedText'], contains('OCR is disabled'));
      },
    );
  });

  group('AIService - PDF Upload', () {
    test(
      'uploadPdfToStorage returns a disabled-state message in the current release build',
      () async {
        final service = AIService();
        final result = await service.uploadPdfToStorage(
          'user1',
          '/nonexistent/file.pdf',
        );
        expect(result, contains('offline-first release build'));
      },
    );
  });

  group('AIService - Consent Record', () {
    test('ensureConsentRecord completes', () async {
      final service = AIService();
      await service.setAiConsent(true);
      await service.setOcrConsent(true);
      await expectLater(service.ensureConsentRecord('user1'), completes);
    });
  });
}
