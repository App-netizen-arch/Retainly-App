import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance =>
      _instance ?? AnalyticsService._();
  AnalyticsService._();

  FirebaseAnalytics? _analytics;
  bool _initialized = false;

  bool get isAvailable => _analytics != null;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _analytics = FirebaseAnalytics.instance;
      await _analytics!.setAnalyticsCollectionEnabled(true);
      _initialized = true;
    } catch (_) {
      _analytics = null;
      _initialized = false;
    }
  }

  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: name,
        parameters: parameters?.cast<String, Object>(),
      );
    } catch (_) {}
  }

  Future<void> setUserProperty(String name, String value) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.setUserProperty(name: name, value: value);
    } catch (_) {}
  }

  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.setAnalyticsCollectionEnabled(enabled);
    } catch (_) {}
  }
}
