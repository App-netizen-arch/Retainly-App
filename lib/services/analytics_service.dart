class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance =>
      _instance ?? AnalyticsService._();
  AnalyticsService._();

  bool get isAvailable => false;

  Future<void> initialize() async {
    return;
  }

  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    return;
  }

  Future<void> setUserProperty(String name, String value) async {
    return;
  }

  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    return;
  }
}
