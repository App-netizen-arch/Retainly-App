import 'package:flutter_riverpod/flutter_riverpod.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});

class SyncService {
  static final SyncService _instance = SyncService._();
  SyncService._();
  factory SyncService() => _instance;

  bool get isAvailable => false;

  Future<void> enqueueLocalChange({
    required String userId,
    required String entity,
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {}

  Future<void> markEntityDeleted({
    required String userId,
    required String entity,
    required String entityId,
  }) async {}

  Future<List<Map<String, dynamic>>> getPendingOutbox(String userId) async {
    return const <Map<String, dynamic>>[];
  }

  Future<void> markSynced(String outboxId) async {}

  Future<void> recordConflict({
    required String userId,
    required String entity,
    required String entityId,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
  }) async {}

  Future<void> retryPending() async {}

  Future<int> getPendingConflictsCount() async => 0;

  Future<int> pruneTombstones() async => 0;

  Future<int> getPendingOutboxCount() async => 0;
}
