import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._();
  ConnectivityService._();
  factory ConnectivityService() => _instance;

  final Connectivity _connectivity = Connectivity();
  static bool? _overrideOnline;
  DateTime? _lastReachabilityCheck;
  bool? _cachedReachable;
  static const _reachabilityCacheDuration = Duration(seconds: 5);

  Future<bool> get isOnline async {
    if (_overrideOnline != null) return _overrideOnline!;
    final now = DateTime.now();
    if (_cachedReachable != null &&
        _lastReachabilityCheck != null &&
        now.difference(_lastReachabilityCheck!) < _reachabilityCacheDuration) {
      return _cachedReachable!;
    }
    try {
      final result = await _connectivity.checkConnectivity();
      final hasInterface = result.any((c) => c != ConnectivityResult.none);
      if (!hasInterface) {
        _cachedReachable = false;
        _lastReachabilityCheck = now;
        return false;
      }
      _cachedReachable = true;
      _lastReachabilityCheck = now;
      return true;
    } catch (_) {
      return false;
    }
  }

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.asyncMap((result) async {
      final hasInterface = result.any((c) => c != ConnectivityResult.none);
      if (!hasInterface) {
        _cachedReachable = false;
        _lastReachabilityCheck = DateTime.now();
        return false;
      }
      _cachedReachable = true;
      _lastReachabilityCheck = DateTime.now();
      return true;
    });
  }

  static void setOnlineOverride(bool? value) {
    _overrideOnline = value;
  }
}
