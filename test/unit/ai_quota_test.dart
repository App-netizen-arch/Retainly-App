import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:retainly/services/ai_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('AIService - Quota', () {
    test('concurrent recordAiUsage calls do not overrun quota', () async {
      final service = AIService();
      await service.setAiConsent(true);
      await service.acceptCostWarning();
      await service.acceptAiPolicy();

      await Future.wait([
        for (var i = 0; i < 10; i++) service.recordAiUsage('user1'),
      ]);

      final remaining = await service.getAiUsageQuota('user1');
      expect(remaining, 0);
    });

    test('checkAiGate blocks when quota is exhausted', () async {
      final service = AIService();
      await service.setAiConsent(true);
      await service.acceptCostWarning();
      await service.acceptAiPolicy();
      for (var i = 0; i < 10; i++) {
        await service.recordAiUsage('user1');
      }
      final gate = await service.checkAiGate('user1');
      expect(gate, contains('quota reached'));
    });
  });
}
