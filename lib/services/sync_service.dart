import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});

class SyncService {
  static final SyncService _instance = SyncService._();
  SyncService._();
  factory SyncService() => _instance;

  FirebaseFirestore? _firestore;

  bool get isAvailable => _firestore != null;

  Future<void> _ensureFirebase() async {
    if (_firestore != null) return;
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (_) {
      _firestore = null;
    }
  }

  Future<void> enqueueLocalChange({
    required String userId,
    required String entity,
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    await _ensureFirebase();
    if (_firestore == null) return;
    try {
      await _firestore!.collection('sync_outbox').add({
        'userId': userId,
        'entity': entity,
        'entityId': entityId,
        'operation': operation,
        'data': data,
        'synced': false,
        'createdAt': FieldValue.serverTimestamp(),
        'syncedAt': null,
      });
    } on FirebaseException catch (_) {}
  }

  Future<void> markEntityDeleted({
    required String userId,
    required String entity,
    required String entityId,
  }) async {
    await _ensureFirebase();
    if (_firestore == null) return;
    try {
      await _firestore!.collection('sync_tombstones').add({
        'userId': userId,
        'entity': entity,
        'entityId': entityId,
        'deletedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (_) {}
  }

  Future<List<Map<String, dynamic>>> getPendingOutbox(String userId) async {
    await _ensureFirebase();
    if (_firestore == null) return [];
    try {
      final snapshot =
          await _firestore!
              .collection('sync_outbox')
              .where('userId', isEqualTo: userId)
              .where('synced', isEqualTo: false)
              .limit(200)
              .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'userId': data['userId'] as String? ?? '',
          'entity': data['entity'] as String? ?? '',
          'entityId': data['entityId'] as String? ?? '',
          'operation': data['operation'] as String? ?? 'create',
          'data': Map<String, dynamic>.from(data['data'] as Map? ?? {}),
          'synced': data['synced'] as bool? ?? false,
        };
      }).toList();
    } on FirebaseException catch (_) {
      return [];
    }
  }

  Future<void> markSynced(String outboxId) async {
    await _ensureFirebase();
    if (_firestore == null) return;
    try {
      await _firestore!.collection('sync_outbox').doc(outboxId).update({
        'synced': true,
        'syncedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (_) {}
  }

  Future<void> recordConflict({
    required String userId,
    required String entity,
    required String entityId,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
  }) async {
    await _ensureFirebase();
    if (_firestore == null) return;
    try {
      await _firestore!.collection('sync_conflicts').add({
        'userId': userId,
        'entity': entity,
        'entityId': entityId,
        'localData': localData,
        'remoteData': remoteData,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (_) {}
  }

  Future<void> retryPending() async {
    await _ensureFirebase();
    if (_firestore == null) return;
    try {
      final snapshot =
          await _firestore!
              .collection('sync_outbox')
              .where('synced', isEqualTo: false)
              .limit(100)
              .get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final entity = data['entity'] as String? ?? '';
        final entityId = data['entityId'] as String? ?? '';
        final operation = data['operation'] as String?;
        if (operation != 'create' &&
            operation != 'update' &&
            operation != 'delete') {
          continue;
        }
        final payload = Map<String, dynamic>.from(data['data'] as Map? ?? {});
        if (entity.isEmpty) continue;

        final targetRef =
            entityId.isNotEmpty
                ? _firestore!.collection(entity).doc(entityId)
                : _firestore!.collection(entity).doc();

        try {
          if (operation == 'delete') {
            await targetRef.delete();
          } else if (operation == 'update') {
            await targetRef.update(payload);
          } else {
            await targetRef.set(payload, SetOptions(merge: true));
          }
          await doc.reference.update({
            'synced': true,
            'syncedAt': FieldValue.serverTimestamp(),
            'error': null,
          });
        } catch (e) {
          await doc.reference.update({
            'error': e.toString(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } on FirebaseException catch (_) {}
  }

  Future<int> getPendingConflictsCount() async {
    await _ensureFirebase();
    if (_firestore == null) return 0;
    try {
      final snapshot =
          await _firestore!
              .collection('sync_conflicts')
              .where('status', isEqualTo: 'open')
              .count()
              .get();
      return snapshot.count ?? 0;
    } on FirebaseException catch (_) {
      return 0;
    }
  }

  Future<int> pruneTombstones() async {
    await _ensureFirebase();
    if (_firestore == null) return 0;
    try {
      final cutoff = DateTime.now().subtract(const Duration(days: 30));
      final snapshot =
          await _firestore!
              .collection('sync_tombstones')
              .where('deletedAt', isLessThan: cutoff)
              .limit(500)
              .get();
      final batch = _firestore!.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return snapshot.docs.length;
    } on FirebaseException catch (_) {
      return 0;
    }
  }

  Future<int> getPendingOutboxCount() async {
    await _ensureFirebase();
    if (_firestore == null) return 0;
    try {
      final snapshot =
          await _firestore!
              .collection('sync_outbox')
              .where('synced', isEqualTo: false)
              .count()
              .get();
      return snapshot.count ?? 0;
    } on FirebaseException catch (_) {
      return 0;
    }
  }
}
