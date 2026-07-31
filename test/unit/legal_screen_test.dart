import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:retainly/features/legal/legal_screen.dart';
import 'package:retainly/l10n/app_localizations.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LegalScreen shows Privacy Policy title and content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const LegalScreen(documentKey: 'privacy_policy'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(
      find.textContaining('Retainly'),
      findsWidgets,
    );
    expect(
      find.textContaining('Data We Collect'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Your Rights'),
      findsOneWidget,
    );
  });

  testWidgets('LegalScreen shows Terms of Service title and content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const LegalScreen(documentKey: 'terms_of_service'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.textContaining('Acceptance of Terms'), findsOneWidget);
    expect(find.textContaining('Prohibited Uses'), findsOneWidget);
  });

  testWidgets('LegalScreen shows Data Retention Policy title and content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const LegalScreen(documentKey: 'data_retention_policy'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Data Retention Policy'), findsOneWidget);
    expect(find.textContaining('Local Data'), findsOneWidget);
    expect(find.textContaining('Tombstone'), findsOneWidget);
  });

  testWidgets('LegalScreen shows Age & Minor Policy title and content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const LegalScreen(documentKey: 'age_minor_policy'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Age & Minor Policy'), findsOneWidget);
    expect(find.textContaining('Target Audience'), findsOneWidget);
    expect(find.textContaining('Minimum Age'), findsOneWidget);
  });

  testWidgets('LegalScreen shows Threat Model title and content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const LegalScreen(documentKey: 'threat_model'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Threat Model'), findsOneWidget);
    expect(find.textContaining('Assets'), findsOneWidget);
    expect(find.textContaining('Mitigations'), findsOneWidget);
    expect(find.textContaining('Firestore rules'), findsOneWidget);
  });

  testWidgets('LegalScreen shows Document not found for unknown key',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const LegalScreen(documentKey: 'unknown_document'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('unknown_document'), findsOneWidget);
    expect(find.text('Document not found.'), findsOneWidget);
  });

  testWidgets('LegalScreen shows Loading when localizations unavailable',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LegalScreen(documentKey: 'privacy_policy'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Loading...'), findsOneWidget);
  });

  testWidgets('LegalScreen shows Urdu content when locale is ur',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ur'),
          home: const LegalScreen(documentKey: 'privacy_policy'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('رازداری کی پالیسی'), findsOneWidget);
    expect(find.textContaining('جائزہ'), findsOneWidget);
  });
}
