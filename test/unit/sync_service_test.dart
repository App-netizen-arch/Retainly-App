import 'package:test/test.dart';
import 'package:retainly/services/sync_service.dart';

void main() {
  group('SyncService - Availability', () {
    test('isAvailable is false before Firebase initialization', () {
      final service = SyncService();
      expect(service.isAvailable, isFalse);
    });
  });

  group('SyncService - Local-Only Mode', () {
    test('enqueueLocalChange is a no-op when Firebase unavailable', () async {
      final service = SyncService();
      await service.enqueueLocalChange(
        userId: 'user1',
        entity: 'tasks',
        entityId: 'task1',
        operation: 'create',
        data: {'title': 'Test Task'},
      );
    });

    test('markEntityDeleted is a no-op when Firebase unavailable', () async {
      final service = SyncService();
      await service.markEntityDeleted(
        userId: 'user1',
        entity: 'tasks',
        entityId: 'task1',
      );
    });

    test('markSynced is a no-op when Firebase unavailable', () async {
      final service = SyncService();
      await service.markSynced('outbox1');
    });

    test('recordConflict is a no-op when Firebase unavailable', () async {
      final service = SyncService();
      await service.recordConflict(
        userId: 'user1',
        entity: 'tasks',
        entityId: 'task1',
        localData: {'title': 'Local'},
        remoteData: {'title': 'Remote'},
      );
    });

    test('retryPending is a no-op when Firebase unavailable', () async {
      final service = SyncService();
      await service.retryPending();
    });
  });

  group('SyncService - Query Methods (Local-Only)', () {
    test('getPendingOutbox returns empty list when Firebase unavailable',
        () async {
      final service = SyncService();
      final result = await service.getPendingOutbox('user1');
      expect(result, isEmpty);
    });

    test('getPendingConflictsCount returns 0 when Firebase unavailable',
        () async {
      final service = SyncService();
      expect(await service.getPendingConflictsCount(), 0);
    });

    test('getPendingOutboxCount returns 0 when Firebase unavailable', () async {
      final service = SyncService();
      expect(await service.getPendingOutboxCount(), 0);
    });

    test('pruneTombstones returns 0 when Firebase unavailable', () async {
      final service = SyncService();
      expect(await service.pruneTombstones(), 0);
    });
  });

  group('SyncService - Singleton Behavior', () {
    test('factory constructor returns same instance', () {
      final a = SyncService();
      final b = SyncService();
      expect(identical(a, b), isTrue);
    });
  });
}
