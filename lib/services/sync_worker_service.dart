enum SyncWorkerState { idle, syncing, error }

class SyncWorkerService {
  static final SyncWorkerService _instance = SyncWorkerService._();
  SyncWorkerService._();
  factory SyncWorkerService() => _instance;

  SyncWorkerState _state = SyncWorkerState.idle;
  int _pendingOutbox = 0;
  int _pendingConflicts = 0;
  int _prunedTombstones = 0;
  String? _lastError;

  SyncWorkerState get state => _state;
  int get pendingOutbox => _pendingOutbox;
  int get pendingConflicts => _pendingConflicts;
  int get prunedTombstones => _prunedTombstones;
  String? get lastError => _lastError;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  Future<void> initialize() async {
    return;
  }

  Future<void> processQueue() async {
    _isRunning = true;
    _state = SyncWorkerState.syncing;
    _lastError = null;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _pendingOutbox = 0;
    _pendingConflicts = 0;
    _prunedTombstones = 0;
    _state = SyncWorkerState.idle;
    _isRunning = false;
  }

  Future<void> retryPending() async {
    await processQueue();
  }

  Future<void> forceSync() async {
    await processQueue();
  }
}
