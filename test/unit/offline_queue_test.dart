import 'package:test/test.dart';
import 'package:retainly/services/offline_queue_service.dart';

void main() {
  group('OfflineQueue serialization', () {
    test('QueuedOperation round-trips through Map', () {
      final op = QueuedOperation(
        id: 'sync_123',
        type: QueuedOperationType.sync,
        payload: {'userId': 'u1', 'entity': 'tasks'},
        queuedAt: DateTime.now(),
        attempts: 1,
        lastAttemptAt: DateTime.now(),
      );
      final map = op.toMap();
      final decoded = QueuedOperation.fromMap(map);
      expect(decoded.id, 'sync_123');
      expect(decoded.type, QueuedOperationType.sync);
      expect(decoded.payload['userId'], 'u1');
      expect(decoded.attempts, 1);
    });
  });
}
