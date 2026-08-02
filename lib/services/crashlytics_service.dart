class CrashlyticsService {
  static CrashlyticsService? _instance;
  static CrashlyticsService get instance =>
      _instance ?? CrashlyticsService._();
  CrashlyticsService._();

  bool get isAvailable => false;

  Future<void> initialize() async {
    return;
  }

  Future<void> logBreadcrumb(String message) async {
    return;
  }

  Future<void> recordError(Object error, StackTrace stack) async {
    return;
  }

  Future<void> setKey(String key, String value) async {
    return;
  }
}
