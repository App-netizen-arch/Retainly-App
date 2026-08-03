// Copyright 2026 CodeSym
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retainly/l10n/app_localizations.dart';
import 'package:retainly/navigation/app_router.dart';
import 'package:retainly/core/theme/app_theme.dart';
import 'package:retainly/providers/database_provider.dart';
import 'package:retainly/services/shortcut_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs;
  try {
    prefs = await SharedPreferences.getInstance().timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('SharedPreferences initialization timed out'),
    );
  } on Exception {
    prefs = await SharedPreferences.getInstance();
  }

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    try {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } on Exception catch (_) {
      // Continue without FFI if native library is unavailable
    }
  }

  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWith((_) => prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  Brightness _platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      _platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final bool reducedMotion = ref.watch(reducedMotionProvider);
    final bool dynamicType = ref.watch(dynamicTypeProvider);
    final bool highContrast = ref.watch(highContrastProvider);
    final systemTextScaler = MediaQuery.textScalerOf(context);
    final TextScaler textScaler =
        dynamicType ? _SystemCompoundedTextScaler(systemTextScaler, 1.3) : systemTextScaler;

    final targetTheme = computeTargetTheme(highContrast, themeMode, _platformBrightness);

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(disableAnimations: reducedMotion, textScaler: textScaler),
      child: MaterialApp.router(
        title: 'Retainly',
        theme: targetTheme,
        darkTheme: targetTheme,
        themeMode: ThemeMode.system,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
        builder: (context, child) {
          return _FocusShortcutHandler(child: child!);
        },
      ),
    );
  }
}

class _SystemCompoundedTextScaler extends TextScaler {
  final TextScaler _base;
  final double _factor;
  const _SystemCompoundedTextScaler(this._base, this._factor);

  @override
  double scale(double fontSize) => _base.scale(fontSize * _factor);

  @override
  double get textScaleFactor => _base.scale(1.0) * _factor;
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

ThemeData computeTargetTheme(
  bool highContrast,
  ThemeMode themeMode,
  Brightness platformBrightness,
) {
  final brightness =
      themeMode == ThemeMode.dark
          ? Brightness.dark
          : themeMode == ThemeMode.light
          ? Brightness.light
          : platformBrightness;
  if (highContrast) {
    return brightness == Brightness.dark
        ? AppTheme.highContrastDarkTheme()
        : AppTheme.highContrastLightTheme();
  }
  return brightness == Brightness.dark
      ? AppTheme.darkTheme()
      : AppTheme.lightTheme();
}
