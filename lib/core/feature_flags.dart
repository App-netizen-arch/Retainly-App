class FeatureFlags {
  static const bool aiAssistance = true;
  static const bool ocrScanning = true;
  static const bool thirdPartyIntegrations = false;
  static const bool spacedRepetition = true;
  static const bool firebaseAuth = false;
  static const bool googleSignIn = false;
  static const bool guestMode = false;
  static const bool encryptedStorage = true;
  static const bool performanceMonitoring = true;

  static final Map<String, bool> _runtimeOverrides = {};

  static Map<String, bool> get allFlags => {
    'ai_assistance': aiAssistance,
    'ocr_scanning': ocrScanning,
    'third_party_integrations': thirdPartyIntegrations,
    'spaced_repetition': spacedRepetition,
    'firebase_auth': firebaseAuth,
    'google_sign_in': googleSignIn,
    'guest_mode': guestMode,
    'encrypted_storage': encryptedStorage,
    'performance_monitoring': performanceMonitoring,
  };

  static bool isFeatureEnabled(String featureName) {
    if (_runtimeOverrides.containsKey(featureName)) {
      return _runtimeOverrides[featureName]!;
    }
    return allFlags[featureName] ?? false;
  }

  static void setFeatureOverride(String featureName, bool value) {
    _runtimeOverrides[featureName] = value;
  }

  static bool isFeatureEnabledForUser(String featureName, String userId) {
    final flag = _rolloutFlags[featureName];
    if (flag == null) return isFeatureEnabled(featureName);
    if (!isFeatureEnabled(featureName)) return false;
    final hash = _hashUserId(userId);
    return hash < flag.stagedRolloutPercent;
  }

  static int _hashUserId(String userId) {
    var hash = 0;
    for (var i = 0; i < userId.length; i++) {
      hash = ((hash << 5) - hash) + userId.codeUnitAt(i);
      hash = hash & 0xFFFFFFFF;
    }
    return (hash.abs() % 100);
  }
}

class FeatureFlag {
  final String name;
  final bool enabled;
  final int stagedRolloutPercent;

  const FeatureFlag({
    required this.name,
    required this.enabled,
    this.stagedRolloutPercent = 100,
  });
}

const Map<String, FeatureFlag> _rolloutFlags = {
  'ai_assistance': FeatureFlag(
    name: 'ai_assistance',
    enabled: true,
    stagedRolloutPercent: 100,
  ),
  'ocr_scanning': FeatureFlag(
    name: 'ocr_scanning',
    enabled: true,
    stagedRolloutPercent: 100,
  ),
  'performance_monitoring': FeatureFlag(
    name: 'performance_monitoring',
    enabled: true,
    stagedRolloutPercent: 100,
  ),
};
