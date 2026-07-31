import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._();
  ConnectivityService._();
  factory ConnectivityService() => _instance;

  final Connectivity _connectivity = Connectivity();

  Future<bool> get isOnline async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.any((c) => c != ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((result) {
      return result.any((c) => c != ConnectivityResult.none);
    });
  }
}
