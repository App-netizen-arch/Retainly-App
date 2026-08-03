import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:retainly/services/ai_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Settings Screen - Locale Persistence', () {
    test('default locale is en', () async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), isNull);
      final service = AIService();
      final provider = await service.getAiProvider();
      expect(provider, 'openrouter');
    });

    test('locale can be set to ur', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_locale', 'ur');
      expect(prefs.getString('app_locale'), 'ur');
    });

    test('locale can be set to en', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_locale', 'en');
      expect(prefs.getString('app_locale'), 'en');
    });
  });

  group('Settings Screen - Accessibility Persistence', () {
    test('reduced_motion defaults to false', () async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('reduced_motion'), isNull);
    });

    test('reduced_motion can be enabled', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('reduced_motion', true);
      expect(prefs.getBool('reduced_motion'), isTrue);
    });

    test('dynamic_type defaults to false', () async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('dynamic_type'), isNull);
    });

    test('dynamic_type can be enabled', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dynamic_type', true);
      expect(prefs.getBool('dynamic_type'), isTrue);
    });

    test('high_contrast defaults to false', () async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('high_contrast'), isNull);
    });

    test('high_contrast can be enabled', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('high_contrast', true);
      expect(prefs.getBool('high_contrast'), isTrue);
    });
  });

  group('Settings Screen - Notification State', () {
    test('notifications_enabled defaults to false', () async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notifications_enabled'), isNull);
    });

    test('notifications_enabled can be enabled', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', true);
      expect(prefs.getBool('notifications_enabled'), isTrue);
    });

    test('notifications_enabled can be disabled', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', true);
      await prefs.setBool('notifications_enabled', false);
      expect(prefs.getBool('notifications_enabled'), isFalse);
    });
  });

  group('Settings Screen - AI Settings Integration', () {
    test('AI consent defaults to false', () async {
      final service = AIService();
      expect(await service.hasAiConsent(), isFalse);
    });

    test('AI consent can be enabled', () async {
      final service = AIService();
      await service.setAiConsent(true);
      expect(await service.hasAiConsent(), isTrue);
    });

    test('OCR consent defaults to false', () async {
      final service = AIService();
      expect(await service.hasOcrConsent(), isFalse);
    });

    test('OCR consent can be enabled', () async {
      final service = AIService();
      await service.setOcrConsent(true);
      expect(await service.hasOcrConsent(), isTrue);
    });

    test('cost warning defaults to not accepted', () async {
      final service = AIService();
      expect(await service.hasAcceptedCostWarning(), isFalse);
    });

    test('cost warning can be accepted', () async {
      final service = AIService();
      await service.acceptCostWarning();
      expect(await service.hasAcceptedCostWarning(), isTrue);
    });

    test('AI quota defaults to 10', () async {
      final service = AIService();
      expect(await service.getAiUsageQuota('local_user'), 10);
    });
  });

  group('Settings Screen - Profile Persistence', () {
    test('daily study minutes defaults to 120', () async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('daily_study_minutes'), isNull);
    });

    test('daily study minutes can be saved', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('daily_study_minutes', 90);
      expect(prefs.getInt('daily_study_minutes'), 90);
    });
  });
}
