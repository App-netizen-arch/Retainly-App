import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsService {
  static CrashlyticsService? _instance;
  static CrashlyticsService get instance =>
      _instance ?? CrashlyticsService._();
  CrashlyticsService._();

  FirebaseCrashlytics? _crashlytics;
  bool _enabled = false;

  bool get isAvailable => _crashlytics != null && _enabled;

  Future<void> initialize() async {
    try {
      _crashlytics = FirebaseCrashlytics.instance;
      _enabled = true;
    } catch (_) {
      _crashlytics = null;
      _enabled = false;
    }
  }

  Future<void> logBreadcrumb(String message) async {
    if (!_enabled || _crashlytics == null) return;
    try {
      await _crashlytics!.log(message);
    } catch (_) {}
  }

  Future<void> recordError(Object error, StackTrace stack) async {
    if (!_enabled || _crashlytics == null) return;
    try {
      await _crashlytics!.recordError(error, stack);
    } catch (_) {}
  }

  Future<void> setKey(String key, String value) async {
    if (!_enabled || _crashlytics == null) return;
    try {
      await _crashlytics!.setCustomKey(key, value);
    } catch (_) {}
  }
}
