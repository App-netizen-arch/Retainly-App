import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:retainly/services/ai_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('AIService - Provider Management', () {
    test('default provider is openrouter', () async {
      final service = AIService();
      expect(await service.getAiProvider(), 'openrouter');
    });

    test('setAiProvider updates the provider', () async {
      final service = AIService();
      await service.setAiProvider('anthropic');
      expect(await service.getAiProvider(), 'anthropic');
    });

    test('setAiProvider can switch to gemini', () async {
      final service = AIService();
      await service.setAiProvider('gemini');
      expect(await service.getAiProvider(), 'gemini');
    });
  });

  group('AIService - Consent Management', () {
    test('hasAiConsent defaults to false', () async {
      final service = AIService();
      expect(await service.hasAiConsent(), isFalse);
    });

    test('setAiConsent(true) sets consent', () async {
      final service = AIService();
      await service.setAiConsent(true);
      expect(await service.hasAiConsent(), isTrue);
    });

    test('setAiConsent(false) clears consent', () async {
      final service = AIService();
      await service.setAiConsent(true);
      await service.setAiConsent(false);
      expect(await service.hasAiConsent(), isFalse);
    });

    test('hasOcrConsent defaults to false', () async {
      final service = AIService();
      expect(await service.hasOcrConsent(), isFalse);
    });

    test('setOcrConsent(true) sets OCR consent', () async {
      final service = AIService();
      await service.setOcrConsent(true);
      expect(await service.hasOcrConsent(), isTrue);
    });

    test('setOcrConsent(false) clears OCR consent', () async {
      final service = AIService();
      await service.setOcrConsent(true);
      await service.setOcrConsent(false);
      expect(await service.hasOcrConsent(), isFalse);
    });
  });

  group('AIService - Cost Warning', () {
    test('hasAcceptedCostWarning defaults to false', () async {
      final service = AIService();
      expect(await service.hasAcceptedCostWarning(), isFalse);
    });

    test('acceptCostWarning sets flag to true', () async {
      final service = AIService();
      await service.acceptCostWarning();
      expect(await service.hasAcceptedCostWarning(), isTrue);
    });
  });

  group('AIService - Quota Management', () {
    test('getAiUsageQuota returns full quota (10) initially', () async {
      final service = AIService();
      expect(await service.getAiUsageQuota('user1'), 10);
    });

    test('recordAiUsage decrements remaining quota', () async {
      final service = AIService();
      await service.recordAiUsage('user1');
      expect(await service.getAiUsageQuota('user1'), 9);
    });

    test('recordAiUsage decrements quota multiple times', () async {
      final service = AIService();
      await service.recordAiUsage('user1');
      await service.recordAiUsage('user1');
      await service.recordAiUsage('user1');
      expect(await service.getAiUsageQuota('user1'), 7);
    });

    test('recordAiUsage exhausts quota after 10 calls', () async {
      final service = AIService();
      for (var i = 0; i < 10; i++) {
        await service.recordAiUsage('user1');
      }
      expect(await service.getAiUsageQuota('user1'), 0);
    });

    test('quota is shared across users (device-level quota)', () async {
      final service = AIService();
      await service.recordAiUsage('user1');
      await service.recordAiUsage('user1');
      expect(await service.getAiUsageQuota('user1'), 8);
      expect(await service.getAiUsageQuota('user2'), 8);
    });
  });

  group('AIService - Cost Estimation', () {
    test('getEstimatedCost defaults to 0.0', () async {
      final service = AIService();
      expect(await service.getEstimatedCost('user1'), 0.0);
    });

    test('estimateCost calculates cost based on output length', () async {
      final service = AIService();
      final output = 'a' * 400;
      await service.estimateCost('user1', {'output': output});
      final cost = await service.getEstimatedCost('user1');
      expect(cost, greaterThan(0));
    });

    test('estimateCost caps per-request cost at 0.5', () async {
      final service = AIService();
      final output = 'a' * 4000;
      await service.estimateCost('user1', {'output': output});
      final cost = await service.getEstimatedCost('user1');
      expect(cost, lessThanOrEqualTo(0.5));
    });

    test('estimateCost caps total cost at 10.0', () async {
      final service = AIService();
      final output = 'a' * 4000;
      for (var i = 0; i < 30; i++) {
        await service.estimateCost('user1', {'output': output});
      }
      final cost = await service.getEstimatedCost('user1');
      expect(cost, lessThanOrEqualTo(10.0));
    });

    test('estimateCost ignores null output', () async {
      final service = AIService();
      await service.estimateCost('user1', {'output': null});
      expect(await service.getEstimatedCost('user1'), 0.0);
    });

    test('estimateCost ignores non-map data', () async {
      final service = AIService();
      await service.estimateCost('user1', 'not a map');
      expect(await service.getEstimatedCost('user1'), 0.0);
    });

    test('resetEstimatedCost resets to 0.0', () async {
      final service = AIService();
      await service.estimateCost('user1', {'output': 'a' * 400});
      expect(await service.getEstimatedCost('user1'), greaterThan(0));
      await service.resetEstimatedCost('user1');
      expect(await service.getEstimatedCost('user1'), 0.0);
    });
  });

  group('AIService - Source Citations', () {
    test('getSourceCitations returns empty map by default', () async {
      final service = AIService();
      expect(await service.getSourceCitations('user1'), isEmpty);
    });

    test('attachSourceCitation stores citation', () async {
      final service = AIService();
      await service.attachSourceCitation('user1', 'content1', 'Textbook Ch. 5');
      final citations = await service.getSourceCitations('user1');
      expect(citations, containsPair('content1', isA<Map>()));
      final citation = citations['content1'] as Map;
      expect(citation['textbookRef'], 'Textbook Ch. 5');
      expect(citation['attachedAt'], isNotEmpty);
    });

    test('attachSourceCitation stores multiple citations', () async {
      final service = AIService();
      await service.attachSourceCitation('user1', 'content1', 'Textbook Ch. 5');
      await service.attachSourceCitation('user1', 'content2', 'Textbook Ch. 6');
      final citations = await service.getSourceCitations('user1');
      expect(citations.length, 2);
      expect(citations, containsPair('content1', isA<Map>()));
      expect(citations, containsPair('content2', isA<Map>()));
    });

    test(
      'attachSourceCitation overwrites existing citation for same id',
      () async {
        final service = AIService();
        await service.attachSourceCitation('user1', 'content1', 'Old Ref');
        await service.attachSourceCitation('user1', 'content1', 'New Ref');
        final citations = await service.getSourceCitations('user1');
        expect(citations.length, 1);
        final citation = citations['content1'] as Map;
        expect(citation['textbookRef'], 'New Ref');
      },
    );

    test('getSourceCitations handles corrupted JSON gracefully', () async {
      final service = AIService();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ai_source_citations', 'not valid json');
      expect(await service.getSourceCitations('user1'), isEmpty);
    });
  });

  group('AIService - Hallucination Reports', () {
    test('getHallucinationReports returns empty list by default', () async {
      final service = AIService();
      expect(await service.getHallucinationReports('user1'), isEmpty);
    });

    test('reportHallucination adds a report', () async {
      final service = AIService();
      await service.reportHallucination('user1', 'content1', 'This is wrong');
      final reports = await service.getHallucinationReports('user1');
      expect(reports.length, 1);
      final report = reports.first as Map;
      expect(report['contentId'], 'content1');
      expect(report['feedback'], 'This is wrong');
      expect(report['reportedAt'], isNotEmpty);
    });

    test('reportHallucination adds multiple reports', () async {
      final service = AIService();
      await service.reportHallucination('user1', 'content1', 'Wrong 1');
      await service.reportHallucination('user1', 'content2', 'Wrong 2');
      expect(await service.getHallucinationReports('user1'), hasLength(2));
    });

    test('deleteHallucinationReport removes by index', () async {
      final service = AIService();
      await service.reportHallucination('user1', 'content1', 'Wrong 1');
      await service.reportHallucination('user1', 'content2', 'Wrong 2');
      await service.reportHallucination('user1', 'content3', 'Wrong 3');
      await service.deleteHallucinationReport('user1', 1);
      final reports = await service.getHallucinationReports('user1');
      expect(reports.length, 2);
      final remaining = reports.map((r) => (r as Map)['contentId']).toList();
      expect(remaining, containsAll(['content1', 'content3']));
    });

    test('deleteHallucinationReport ignores invalid index', () async {
      final service = AIService();
      await service.reportHallucination('user1', 'content1', 'Wrong 1');
      await service.deleteHallucinationReport('user1', 5);
      expect(await service.getHallucinationReports('user1'), hasLength(1));
      await service.deleteHallucinationReport('user1', -1);
      expect(await service.getHallucinationReports('user1'), hasLength(1));
    });

    test('clearHallucinationReports removes all reports', () async {
      final service = AIService();
      await service.reportHallucination('user1', 'content1', 'Wrong 1');
      await service.reportHallucination('user1', 'content2', 'Wrong 2');
      await service.clearHallucinationReports('user1');
      expect(await service.getHallucinationReports('user1'), isEmpty);
    });

    test('getHallucinationReports handles corrupted JSON gracefully', () async {
      final service = AIService();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ai_hallucination_reports', 'not valid json');
      expect(await service.getHallucinationReports('user1'), isEmpty);
    });
  });

  group('AIService - Online Consent Gate', () {
    test(
      'generateTaskBreakdown requires explicit consent before online AI use',
      () async {
        final service = AIService();
        final result = await service.generateTaskBreakdown(
          'user1',
          'Math homework',
        );
        expect(result, contains('AI assistance requires consent in Settings.'));
      },
    );

    test(
      'generateRevisionDraft requires explicit consent before online AI use',
      () async {
        final service = AIService();
        final result = await service.generateRevisionDraft(
          'user1',
          'Chapter 1',
        );
        expect(result, contains('AI assistance requires consent in Settings.'));
      },
    );

    test(
      'generateFlashcards requires explicit consent before online AI use',
      () async {
        final service = AIService();
        final result = await service.generateFlashcards('user1', 'Some text');
        expect(result, contains('AI assistance requires consent in Settings.'));
      },
    );

    test(
      'generateQuizDraft requires explicit consent before online AI use',
      () async {
        final service = AIService();
        final result = await service.generateQuizDraft('user1', 'Chapter 1', 5);
        expect(result, contains('AI assistance requires consent in Settings.'));
      },
    );
  });
}
