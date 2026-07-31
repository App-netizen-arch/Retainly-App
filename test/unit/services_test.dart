import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:retainly/services/offline_queue_service.dart';
import 'package:retainly/services/sync_worker_service.dart';
import 'package:retainly/services/analytics_service.dart';
import 'package:retainly/services/crashlytics_service.dart';
import 'package:retainly/services/remote_config_service.dart';

void main() {
  group('OfflineQueueService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('enqueue adds an operation and pendingCount reflects it', () async {
      final service = OfflineQueueService();
      expect(await service.pendingCount, 0);
      await service.enqueue(
        QueuedOperationType.sync,
        {'userId': 'u1', 'entity': 'tasks', 'entityId': 't1', 'operation': 'create', 'data': {}},
      );
      expect(await service.pendingCount, 1);
    });

    test('enqueue adds multiple operations', () async {
      final service = OfflineQueueService();
      await service.enqueue(QueuedOperationType.sync, {'userId': 'u1'});
      await service.enqueue(QueuedOperationType.tombstone, {'userId': 'u1'});
      await service.enqueue(QueuedOperationType.ai, {'userId': 'u1'});
      expect(await service.pendingCount, 3);
    });

    test('processQueue drops items after max attempts when offline', () async {
      final service = OfflineQueueService();
      await service.enqueue(
        QueuedOperationType.sync,
        {'userId': 'u1', 'entity': 'tasks', 'operation': 'create', 'data': {}},
      );
      expect(await service.pendingCount, 1);

      await service.processQueue();
      expect(await service.pendingCount, 1);

      await service.processQueue();
      expect(await service.pendingCount, 1);

      await service.processQueue();
      expect(await service.pendingCount, 0);
    });

    test('processQueue is a no-op when queue is empty', () async {
      final service = OfflineQueueService();
      await service.processQueue();
      expect(await service.pendingCount, 0);
    });
  });

  group('SyncWorkerService', () {
    test('initial state is idle', () {
      final worker = SyncWorkerService();
      expect(worker.state, SyncWorkerState.idle);
    });

    test('isRunning is false initially', () {
      final worker = SyncWorkerService();
      expect(worker.isRunning, false);
    });

    test('lastError is null initially', () {
      final worker = SyncWorkerService();
      expect(worker.lastError, isNull);
    });

    test('pending counts are zero initially', () {
      final worker = SyncWorkerService();
      expect(worker.pendingOutbox, 0);
      expect(worker.pendingConflicts, 0);
      expect(worker.prunedTombstones, 0);
    });
  });

  group('AnalyticsService', () {
    test('isAvailable is false before initialization', () {
      expect(AnalyticsService.instance.isAvailable, isFalse);
    });

    test('initialize does not throw when Firebase unavailable', () async {
      await AnalyticsService.instance.initialize();
      expect(AnalyticsService.instance.isAvailable, isFalse);
    });

    test('logEvent is a no-op when not initialized', () async {
      await AnalyticsService.instance.logEvent('test_event');
    });

    test('setUserProperty is a no-op when not initialized', () async {
      await AnalyticsService.instance.setUserProperty('test', 'value');
    });

    test('setPerformanceCollectionEnabled is a no-op when not initialized', () async {
      await AnalyticsService.instance.setPerformanceCollectionEnabled(false);
    });
  });

  group('CrashlyticsService', () {
    test('isAvailable is false before initialization', () {
      expect(CrashlyticsService.instance.isAvailable, isFalse);
    });

    test('initialize does not throw when Firebase unavailable', () async {
      await CrashlyticsService.instance.initialize();
      expect(CrashlyticsService.instance.isAvailable, isFalse);
    });

    test('logBreadcrumb is a no-op when not enabled', () async {
      await CrashlyticsService.instance.logBreadcrumb('test breadcrumb');
    });

    test('recordError is a no-op when not enabled', () async {
      await CrashlyticsService.instance.recordError(Exception('test'), StackTrace.current);
    });

    test('setKey is a no-op when not enabled', () async {
      await CrashlyticsService.instance.setKey('test_key', 'test_value');
    });
  });

  group('RemoteConfigService', () {
    test('isAvailable is false before initialization', () {
      expect(RemoteConfigService.instance.isAvailable, isFalse);
    });

    test('initialize does not throw when Firebase unavailable', () async {
      await RemoteConfigService.instance.initialize();
      expect(RemoteConfigService.instance.isAvailable, isFalse);
    });

    test('getBoolean returns default when not initialized', () {
      expect(RemoteConfigService.instance.getBoolean('test_key', true), isTrue);
      expect(RemoteConfigService.instance.getBoolean('test_key', false), isFalse);
    });

    test('getInt returns default when not initialized', () {
      expect(RemoteConfigService.instance.getInt('test_key', 42), 42);
    });

    test('getString returns default when not initialized', () {
      expect(RemoteConfigService.instance.getString('test_key', 'default'), 'default');
    });
  });
}
