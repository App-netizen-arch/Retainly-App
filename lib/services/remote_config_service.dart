import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static RemoteConfigService? _instance;
  static RemoteConfigService get instance =>
      _instance ?? RemoteConfigService._();
  RemoteConfigService._();

  FirebaseRemoteConfig? _remoteConfig;
  bool _initialized = false;

  bool get isAvailable => _remoteConfig != null && _initialized;

  static const Map<String, dynamic> _defaults = {
    'enable_analytics': true,
    'enable_crashlytics': true,
    'enable_performance_monitoring': true,
    'sync_interval_minutes': 15,
    'max_retry_attempts': 3,
    'ai_quota_daily': 50,
    'offline_queue_max_size': 100,
  };

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      await _remoteConfig!.setDefaults(_defaults);
      await _remoteConfig!.fetchAndActivate();
      _initialized = true;
    } catch (_) {
      _remoteConfig = null;
      _initialized = false;
    }
  }

  bool getBoolean(String key, bool defaultValue) {
    if (_remoteConfig == null) return defaultValue;
    try {
      return _remoteConfig!.getBool(key);
    } catch (_) {
      return defaultValue;
    }
  }

  int getInt(String key, int defaultValue) {
    if (_remoteConfig == null) return defaultValue;
    try {
      return _remoteConfig!.getInt(key);
    } catch (_) {
      return defaultValue;
    }
  }

  String getString(String key, String defaultValue) {
    if (_remoteConfig == null) return defaultValue;
    try {
      return _remoteConfig!.getString(key);
    } catch (_) {
      return defaultValue;
    }
  }
}
