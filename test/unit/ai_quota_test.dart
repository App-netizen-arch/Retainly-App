import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:retainly/services/ai_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('AIService - Quota and Cost', () {
    test('estimateCostFromOutput handles empty string without error', () async {
      final service = AIService();
      await service.estimateCostFromOutput('');
      final cost = await service.getEstimatedCost('user1');
      expect(cost, 0.0);
    });

    test('estimateCost sanitizes raw output before costing', () async {
      final service = AIService();
      await service.estimateCost(
        'user1',
        {'output': '   hello   world   '},
      );
      final cost = await service.getEstimatedCost('user1');
      expect(cost, greaterThan(0));
    });

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
