class RemoteConfigService {
  static RemoteConfigService? _instance;
  static RemoteConfigService get instance =>
      _instance ?? RemoteConfigService._();
  RemoteConfigService._();

  bool get isAvailable => false;

  Future<void> initialize() async {
    return;
  }

  bool getBoolean(String key, bool defaultValue) {
    return defaultValue;
  }

  int getInt(String key, int defaultValue) {
    return defaultValue;
  }

  String getString(String key, String defaultValue) {
    return defaultValue;
  }
}
