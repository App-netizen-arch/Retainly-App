import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'sync_service.dart';
import 'connectivity_service.dart';

enum QueuedOperationType { sync, ai, tombstone }

class QueuedOperation {
  final String id;
  final QueuedOperationType type;
  final Map<String, dynamic> payload;
  final DateTime queuedAt;
  int attempts;
  DateTime? lastAttemptAt;

  QueuedOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.queuedAt,
    this.attempts = 0,
    this.lastAttemptAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'payload': payload,
    'queuedAt': queuedAt.toIso8601String(),
    'attempts': attempts,
    'lastAttemptAt': lastAttemptAt?.toIso8601String(),
  };

  factory QueuedOperation.fromMap(Map<String, dynamic> map) {
    return QueuedOperation(
      id: map['id'] as String,
      type: QueuedOperationType.values.firstWhere((t) => t.name == map['type']),
      payload: Map<String, dynamic>.from(map['payload'] as Map),
      queuedAt: DateTime.parse(map['queuedAt'] as String),
      attempts: map['attempts'] as int? ?? 0,
      lastAttemptAt:
          map['lastAttemptAt'] == null
              ? null
              : DateTime.parse(map['lastAttemptAt'] as String),
    );
  }
}

class OfflineQueueService {
  static final OfflineQueueService _instance = OfflineQueueService._();
  OfflineQueueService._();
  factory OfflineQueueService() => _instance;

  static const String _storageKey = 'offline_queue';
  static const int _maxAttempts = 3;
  final _controller = StreamController<void>.broadcast();

  Future<List<QueuedOperation>> _loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => QueuedOperation.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveQueue(List<QueuedOperation> queue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(queue.map((e) => e.toMap()).toList()),
    );
  }

  Future<void> enqueue(
    QueuedOperationType type,
    Map<String, dynamic> payload,
  ) async {
    final queue = await _loadQueue();
    queue.add(
      QueuedOperation(
        id: '${type.name}_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        payload: payload,
        queuedAt: DateTime.now(),
      ),
    );
    await _saveQueue(queue);
    _notifyListeners();
  }

  Future<bool> _process(QueuedOperation op) async {
    final connectivity = ConnectivityService();
    if (!await connectivity.isOnline) return false;

    try {
      switch (op.type) {
        case QueuedOperationType.sync:
          final sync = SyncService();
          await sync.enqueueLocalChange(
            userId: op.payload['userId'] as String? ?? '',
            entity: op.payload['entity'] as String? ?? '',
            entityId: op.payload['entityId'] as String? ?? '',
            operation: op.payload['operation'] as String? ?? 'create',
            data: Map<String, dynamic>.from(
              op.payload['data'] as Map? ?? {},
            ),
          );
          return sync.isAvailable;
        case QueuedOperationType.tombstone:
          final sync = SyncService();
          await sync.markEntityDeleted(
            userId: op.payload['userId'] as String? ?? '',
            entity: op.payload['entity'] as String? ?? '',
            entityId: op.payload['entityId'] as String? ?? '',
          );
          return sync.isAvailable;
        case QueuedOperationType.ai:
          return true;
      }
    } catch (_) {
      return false;
    }
  }

  Future<void> processQueue() async {
    final queue = await _loadQueue();
    if (queue.isEmpty) return;

    final remaining = <QueuedOperation>[];

    for (final op in queue) {
      final success = await _process(op);
      if (success) {
        continue;
      } else {
        op.attempts++;
        op.lastAttemptAt = DateTime.now();
        if (op.attempts < _maxAttempts) {
          remaining.add(op);
        }
      }
    }

    await _saveQueue(remaining);
    _notifyListeners();
  }

  StreamSubscription<void> addListener(void Function() listener) {
    return _controller.stream.listen((_) => listener());
  }

  void removeListener(StreamSubscription<void> subscription) {
    subscription.cancel();
  }

  void _notifyListeners() {
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }

  Future<int> get pendingCount async => (await _loadQueue()).length;
}
