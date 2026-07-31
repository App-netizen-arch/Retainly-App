import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSyncOutbox {
  final String id;
  final String userId;
  final String entity;
  final String operation;
  final Map<String, dynamic> data;
  final bool synced;
  final Timestamp createdAt;
  final Timestamp? syncedAt;

  FirestoreSyncOutbox({
    required this.id,
    required this.userId,
    required this.entity,
    required this.operation,
    required this.data,
    this.synced = false,
    required this.createdAt,
    this.syncedAt,
  });

  factory FirestoreSyncOutbox.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return FirestoreSyncOutbox(
      id: snap.id,
      userId: data['userId'] as String? ?? '',
      entity: data['entity'] as String? ?? '',
      operation: data['operation'] as String? ?? 'create',
      data: Map<String, dynamic>.from(data['data'] as Map? ?? {}),
      synced: data['synced'] as bool? ?? false,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      syncedAt: data['syncedAt'] as Timestamp?,
    );
  }
}

class FirestoreTombstone {
  final String id;
  final String userId;
  final String entity;
  final String entityId;
  final Timestamp? deletedAt;
  final Timestamp createdAt;

  FirestoreTombstone({
    required this.id,
    required this.userId,
    required this.entity,
    required this.entityId,
    this.deletedAt,
    required this.createdAt,
  });

  factory FirestoreTombstone.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return FirestoreTombstone(
      id: snap.id,
      userId: data['userId'] as String? ?? '',
      entity: data['entity'] as String? ?? '',
      entityId: data['entityId'] as String? ?? '',
      deletedAt: data['deletedAt'] as Timestamp?,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}

class FirestoreConflict {
  final String id;
  final String userId;
  final String entity;
  final String entityId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final String status;
  final Timestamp createdAt;

  FirestoreConflict({
    required this.id,
    required this.userId,
    required this.entity,
    required this.entityId,
    required this.localData,
    required this.remoteData,
    this.status = 'open',
    required this.createdAt,
  });

  factory FirestoreConflict.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return FirestoreConflict(
      id: snap.id,
      userId: data['userId'] as String? ?? '',
      entity: data['entity'] as String? ?? '',
      entityId: data['entityId'] as String? ?? '',
      localData: Map<String, dynamic>.from(data['localData'] as Map? ?? {}),
      remoteData: Map<String, dynamic>.from(data['remoteData'] as Map? ?? {}),
      status: data['status'] as String? ?? 'open',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}
