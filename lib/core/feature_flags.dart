class FeatureFlags {
  static const bool aiAssistance = true;
  static const bool thirdPartyIntegrations = false;
  static const bool performanceMonitoring = true;

  static Map<String, bool> get allFlags => {
    'ai_assistance': aiAssistance,
    'third_party_integrations': thirdPartyIntegrations,
    'performance_monitoring': performanceMonitoring,
  };

  static bool isFeatureEnabled(String featureName) {
    return allFlags[featureName] ?? false;
  }
}
