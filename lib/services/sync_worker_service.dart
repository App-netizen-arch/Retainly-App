// Copyright 2026 CodeSym
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'offline_queue_service.dart';
import 'sync_service.dart';
import 'connectivity_service.dart';

enum SyncWorkerState { idle, syncing, error }

const String _taskProcessQueue = 'sync_worker_process_queue';
const String _taskRetryPending = 'sync_worker_retry_pending';
const String _taskForceSync = 'sync_worker_force_sync';

@pragma('vm:entry-point')
void syncWorkerDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      await Firebase.initializeApp();
      final worker = SyncWorkerService();
      switch (taskName) {
        case _taskProcessQueue:
          await worker.processQueue();
          break;
        case _taskRetryPending:
          await worker.retryPending();
          break;
        case _taskForceSync:
          await worker.forceSync();
          break;
      }
    } catch (_) {}
    return Future.value(true);
  });
}

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
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await Workmanager().initialize(syncWorkerDispatcher);
      await Workmanager().registerPeriodicTask(
        'sync_worker_periodic',
        _taskProcessQueue,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(networkType: NetworkType.connected),
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 5),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      );
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  Future<void> processQueue() async {
    if (_isRunning) return;
    _isRunning = true;
    _state = SyncWorkerState.syncing;
    _lastError = null;

    try {
      final connectivity = ConnectivityService();
      if (!await connectivity.isOnline) {
        _lastError = 'No internet connection';
        _state = SyncWorkerState.idle;
        _isRunning = false;
        return;
      }

      final queue = OfflineQueueService();
      await queue.processQueue();
      _pendingOutbox = await queue.pendingCount;

      final sync = SyncService();
      _pendingConflicts = await sync.getPendingConflictsCount();

      _state = SyncWorkerState.idle;
    } catch (e) {
      _lastError = e.toString();
      _state = SyncWorkerState.error;
    } finally {
      _isRunning = false;
    }
  }

  Future<void> retryPending() async {
    if (_isRunning) return;
    _isRunning = true;
    _state = SyncWorkerState.syncing;
    _lastError = null;

    try {
      final connectivity = ConnectivityService();
      if (!await connectivity.isOnline) {
        _lastError = 'No internet connection';
        _state = SyncWorkerState.idle;
        _isRunning = false;
        return;
      }

      final sync = SyncService();
      await sync.retryPending();
      _pendingConflicts = await sync.getPendingConflictsCount();
      _pendingOutbox = await sync.getPendingOutboxCount();

      _state = SyncWorkerState.idle;
    } catch (e) {
      _lastError = e.toString();
      _state = SyncWorkerState.error;
    } finally {
      _isRunning = false;
    }
  }

  Future<void> forceSync() async {
    if (_isRunning) return;
    _isRunning = true;
    _state = SyncWorkerState.syncing;
    _lastError = null;

    try {
      final connectivity = ConnectivityService();
      if (!await connectivity.isOnline) {
        _lastError = 'No internet connection';
        _state = SyncWorkerState.error;
        _isRunning = false;
        return;
      }

      final queue = OfflineQueueService();
      await queue.processQueue();
      _pendingOutbox = await queue.pendingCount;

      final sync = SyncService();
      await sync.retryPending();
      _pendingConflicts = await sync.getPendingConflictsCount();
      _prunedTombstones = await sync.pruneTombstones();

      _state = SyncWorkerState.idle;
    } catch (e) {
      _lastError = e.toString();
      _state = SyncWorkerState.error;
    } finally {
      _isRunning = false;
    }
  }
}
