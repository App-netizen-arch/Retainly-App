import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retainly/l10n/app_localizations.dart';
import 'package:retainly/navigation/app_router.dart';
import 'package:retainly/core/theme/app_theme.dart';
import 'package:retainly/providers/database_provider.dart';
import 'package:retainly/services/analytics_service.dart';
import 'package:retainly/services/crashlytics_service.dart';
import 'package:retainly/services/remote_config_service.dart';
import 'package:retainly/services/sync_worker_service.dart';
import 'package:retainly/services/shortcut_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    await Firebase.initializeApp();
    await AnalyticsService.instance.initialize();
    await CrashlyticsService.instance.initialize();
    await RemoteConfigService.instance.initialize();
    await SyncWorkerService().initialize();
  } catch (_) {
    // Firebase not available; services degrade to local-only mode
  }

  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    CrashlyticsService.instance.recordError(
      details.exception,
      details.stack ?? StackTrace.current,
    );
  };

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWith((_) => prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    return FutureBuilder<SharedPreferences>(
      future: Future.value(prefs),
      builder: (context, snapshot) {
        final bool reducedMotion =
            snapshot.data?.getBool('reduced_motion') ?? false;
        final bool dynamicType =
            snapshot.data?.getBool('dynamic_type') ?? false;
        final bool highContrast =
            snapshot.data?.getBool('high_contrast') ?? false;
        final TextScaler textScaler =
            dynamicType ? TextScaler.linear(1.3) : TextScaler.noScaling;
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reducedMotion, textScaler: textScaler),
          child: MaterialApp.router(
            title: 'Retainly',
            theme:
                highContrast
                    ? AppTheme.highContrastLightTheme()
                    : AppTheme.lightTheme(),
            darkTheme:
                highContrast
                    ? AppTheme.highContrastDarkTheme()
                    : AppTheme.darkTheme(),
            themeMode: ref.watch(themeModeProvider),
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: router,
            builder: (context, child) {
              return _FocusShortcutHandler(child: child!);
            },
          ),
        );
      },
    );
  }
}

class _FocusShortcutHandler extends StatefulWidget {
  final Widget child;

  const _FocusShortcutHandler({required this.child});

  @override
  State<_FocusShortcutHandler> createState() => _FocusShortcutHandlerState();
}

class _FocusShortcutHandlerState extends State<_FocusShortcutHandler> {
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkShortcut());
  }

  Future<void> _checkShortcut() async {
    if (_handled) return;
    try {
      final tapped = await ShortcutService.checkFocusShortcut();
      if (tapped == true && !_handled) {
        _handled = true;
        if (mounted) {
          GoRouter.of(context).go('/focus');
        }
      }
    } catch (_) {
      // Ignore platform-specific shortcuts on unsupported platforms
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
