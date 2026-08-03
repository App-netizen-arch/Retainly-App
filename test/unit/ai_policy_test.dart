import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:retainly/services/ai_service.dart';
import 'package:retainly/services/connectivity_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ConnectivityService.setOnlineOverride(true);
  });

  tearDown(() {
    ConnectivityService.setOnlineOverride(null);
  });

  group('AIService - AI Policy Consent', () {
    test('hasAcceptedAiPolicy defaults to false', () async {
      final service = AIService();
      expect(await service.hasAcceptedAiPolicy(), isFalse);
    });

    test('acceptAiPolicy sets flag to true', () async {
      final service = AIService();
      await service.acceptAiPolicy();
      expect(await service.hasAcceptedAiPolicy(), isTrue);
    });

    test('acceptAiPolicy can be reset', () async {
      final service = AIService();
      await service.acceptAiPolicy();
      expect(await service.hasAcceptedAiPolicy(), isTrue);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ai_policy_accepted', false);
      expect(await service.hasAcceptedAiPolicy(), isFalse);
    });

    test('checkAiGate blocks when policy is not accepted', () async {
      final service = AIService();
      await service.setAiConsent(true);
      await service.acceptCostWarning();
      final gate = await service.checkAiGate('user1');
      expect(gate, contains('AI policy'));
    });

    test('checkAiGate passes when all flags are accepted', () async {
      final service = AIService();
      await service.setAiConsent(true);
      await service.acceptCostWarning();
      await service.acceptAiPolicy();
      final gate = await service.checkAiGate('user1');
      expect(gate, isNull);
    });

    test('ensureConsentRecord stores a timestamp', () async {
      final service = AIService();
      await service.ensureConsentRecord('user1');
      final prefs = await SharedPreferences.getInstance();
      final record = prefs.getString('ai_consent_record_user1');
      expect(record, isNotNull);
      expect(record, isNotEmpty);
    });
  });
}
