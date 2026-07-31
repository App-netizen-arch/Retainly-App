# Retainly: Offline-First Adaptive Study Planner — Technical White Paper

**Version:** 1.0  
**Classification:** Public / Technical Reference  
**Target Audience:** Systems engineers, security auditors, technical stakeholders  
**Codebase:** `retainly` (Flutter/Dart client + Firebase Cloud Functions)  
**License:** Apache License, Version 2.0  
**Organization:** CodeSym  

---

## Abstract

Retainly is a cross-platform, offline-first mobile application engineered to deliver adaptive daily study planning, Pomodoro-style focus tracking, and spaced-repetition revision for Pakistani Matriculation (Class 9–10) students. The system is architected around a local SQLite single source of truth with optional Firebase-backed cloud synchronization, AI-assisted task decomposition, and encrypted local backup. This white paper exhaustively documents the system's layered architecture, data-flow invariants, algorithmic mechanics, concurrency model, security posture, and extensibility roadmap.

---

## Table of Contents

1. [Executive Summary & Core Objectives](#1-executive-summary--core-objectives)
2. [System Architecture & High-Level Design](#2-system-architecture--high-level-design)
3. [Deep-Dive Subsystem Mechanics](#3-deep-dive-subsystem-mechanics)
4. [Memory Management & Hardware/Resource Interaction](#4-memory-management--hardwareresource-interaction)
5. [Data Flow, Interfaces & API Specifications](#5-data-flow-interfaces--api-specifications)
6. [Verification, Safety & Security Model](#6-verification-safety--security-model)
7. [Performance Profiles & Benchmarking](#7-performance-profiles--benchmarking)
8. [Deployment, Integration & Future Expansion Roadmap](#8-deployment-integration--future-expansion-roadmap)

---

## 1. Executive Summary & Core Objectives

### 1.1 Mission Statement

Retainly exists to transform a static syllabus into an adaptive, personalized daily study plan for students in low-connectivity environments. The system must function identically on a device with no network access as it does online, with zero data loss and no crash paths attributable to unavailable cloud services.

### 1.2 Core Technical Goals

| Goal | Implementation Mechanism |
|------|--------------------------|
| Offline-first resilience | Local SQLite as sole source of truth; all Firebase dependencies degrade silently |
| Adaptive planning | Greedy knapsack daily budget allocation scored by urgency, priority, and fit |
| Retention optimization | SuperMemo-2 (SM-2) spaced-repetition algorithm with adaptive ease factor |
| Data durability | Encrypted AES-256 local backups; sync outbox with tombstone-based conflict prevention |
| Cross-platform parity | Flutter 3.24+ targeting Android (primary) and Linux desktop; explicit web rejection |
| Privacy-by-default | AI/OCR/sync strictly opt-in with consent, cost-warning, and daily-quota gates |
| Academic integrity | AI outputs labeled as draft-only; hallucination reporting; source-grounding prompts |

### 1.3 Non-Goals

- Multi-user collaboration or real-time co-editing
- Web platform support (explicitly rejected; `firebase_options.dart` throws `UnsupportedError` on web)
- Native iOS or macOS as primary targets (desktop FFI fallback only)
- Offline semantic merge of conflicting remote mutations (manual resolution required)

### 1.4 Architectural Philosophy

The system follows a **layered, feature-first, domain-driven** architecture with three immutable invariants:

1. **Local-first authority:** The SQLite database is the single source of truth. No UI state is derived directly from cloud state.
2. **No Firebase crash path:** Every Firebase-dependent service catches `FirebaseException` and returns a safe default. The application never terminates due to cloud unavailability.
3. **Explicit opt-in for online features:** Cloud sync, AI assistance, OCR, analytics, and crash reporting require explicit user consent and fail gracefully when denied or unavailable.

### 1.5 System Invariants

```
INV-1: Every local mutation flows through DatabaseRepository.
INV-2: Every local mutation is recorded in sync_meta via _trackChange().
INV-3: No UI screen depends on Firebase availability for rendering.
INV-4: AI/OCR requests are gated by (consent AND cost_warning AND quota AND connectivity).
INV-5: Focus session state transitions are: idle → running → completed|idle.
INV-6: Sync tombstones are retained ≥30 days to prevent resurrection attacks.
INV-7: SM-2 ease factor is clamped to [1.3, ∞).
INV-8: Backup encryption key is stored in platform secure storage when available.
```

---

## 2. System Architecture & High-Level Design

### 2.1 Architectural Paradigm

Retainly employs a **layered, offline-first, event-driven** architecture. The client is a single Flutter application with a clear separation between presentation, service, and data layers. The backend is a thin Firebase layer consisting of four Cloud Functions and Firestore/Storage security rules.

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                           │
│  Flutter Widgets (Material 3) + Riverpod State + GoRouter          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│  │   Home   │ │  Planner │ │  Focus   │ │ Revision │ │ Backup   │ │
│  │  Screen  │ │  Screen  │ │  Screen  │ │  Screen  │ │  Screen  │ │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ │
│       │             │             │             │             │      │
│  ┌────┴─────────────┴─────────────┴─────────────┴─────────────┴──┐ │
│  │                    Riverpod Providers (DI + State)             │ │
│  │  dbFutureProvider | userProfileProvider | dashboardProvider    │ │
│  └────────────────────────────┬────────────────────────────────────┘ │
└───────────────────────────────┼──────────────────────────────────────┘
                                │
┌───────────────────────────────▼──────────────────────────────────────┐
│                         SERVICE LAYER                                │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌───────────────┐  │
│  │ SyncService │ │ OfflineQueue │ │ AIService   │ │ConnectivitySvc│  │
│  │(singleton)  │ │ Service      │ │(singleton)  │ │(singleton)    │  │
│  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘ └──────┬───────┘  │
│         │                │                │                │         │
│  ┌──────┴────────────────┴────────────────┴────────────────┴───────┐ │
│  │               SyncWorkerService (Workmanager)                   │ │
│  │         Background Isolate @pragma('vm:entry-point')            │ │
│  └────────────────────────────┬────────────────────────────────────┘ │
└───────────────────────────────┼──────────────────────────────────────┘
                                │
┌───────────────────────────────▼──────────────────────────────────────┐
│                          DATA LAYER                                  │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                    DatabaseRepository (Facade)              │   │
│  │  Wraps: DatabaseHelper (sqflite) + AppDatabase (Drift, opt) │   │
│  │  Responsibilities: CRUD, SM-2, analytics, sync tracking      │   │
│  └────────────────────────────┬─────────────────────────────────┘   │
│                               │                                      │
│  ┌────────────────────────────▼─────────────────────────────────┐   │
│  │                    DatabaseHelper (sqflite)                  │   │
│  │  11-table schema, singleton, backward-compatible migration    │   │
│  │  File: getApplicationDocumentsDirectory()/study_planner.db   │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │              AppDatabase (Drift, Android-only)               │   │
│  │  schemaVersion: 3, NativeDatabase.createInBackground()       │   │
│  └──────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────┘
                                │
                    ┌───────────┴────────────┐
                    │   Local Only (Default)  │
                    │   OR                    │
                    │   Firebase (Optional)   │
                    └───────────┬────────────┘
                                │
┌───────────────────────────────▼──────────────────────────────────────┐
│                         CLOUD LAYER (Optional)                        │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │              Firebase Firestore                              │   │
│  │  Collections: sync_outbox, sync_tombstones, sync_conflicts,  │   │
│  │  ai_consents, ai_requests, ocr_jobs, quizzes, quiz_attempts │   │
│  └────────────────────────────┬─────────────────────────────────┘   │
│                               │                                      │
│  ┌────────────────────────────▼─────────────────────────────────┐   │
│  │              Firebase Cloud Functions (Node.js/TS)           │   │
│  │  ┌──────────┐ ┌──────────┐ ┌─────────────┐ ┌──────────────┐ │   │
│  │  │ aiProxy  │ │ocrProcess│ │ syncWorker  │ │pruneTombstones│ │   │
│  │  │(https)   │ │ (https)  │ │(pubsub 15m) │ │(pubsub 24h) │ │   │
│  │  └──────────┘ └──────────┘ └─────────────┘ └──────────────┘ │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │              Firebase Storage (ai-uploads/, ocr-output/)     │   │
│  └──────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────┘
```

### 2.2 Module Boundaries & Dependencies

```
lib/
├── core/                  # Zero dependencies on data/services
│   ├── constants/         # AppConstants, MatricSubjects
│   ├── enums/             # ResourceType
│   ├── feature_flags.dart # Compile-time/runtime feature toggles
│   ├── theme/             # AppTheme (Material 3)
│   └── utils/             # error_utils, planner_utils
│
├── data/                  # Depends only on core
│   ├── models/            # Plain Dart data classes (toMap/fromMap)
│   ├── database_helper.dart    # sqflite singleton
│   ├── drift/             # Optional Drift ORM (Android only)
│   ├── firestore/         # Firestore-specific models
│   └── repositories/      # DatabaseRepository (facade)
│
├── services/              # Depends on data + Firebase SDKs
│   ├── sync_service.dart
│   ├── offline_queue_service.dart
│   ├── sync_worker_service.dart
│   ├── ai_service.dart
│   ├── connectivity_service.dart
│   ├── analytics_service.dart
│   ├── crashlytics_service.dart
│   ├── remote_config_service.dart
│   └── shortcut_service.dart
│
├── features/              # Depends on services + data + providers
│   ├── ai/                # OCR, flashcards, quiz, hallucination reports
│   ├── backup/            # Full DDD: domain/data/application/presentation
│   ├── focus/             # Pomodoro timer + Android DND channel
│   ├── planner/           # Daily plan generation + reschedule
│   ├── revision/          # SM-2 spaced repetition queue
│   ├── resources/         # PDF viewer, practical records
│   ├── subjects/          # Subject setup, chapter management
│   ├── tasks/             # Add task, global search
│   └── ...                # home, progress, settings, legal, onboarding
│
├── navigation/            # GoRouter config (depends on providers)
│   └── app_router.dart    # ShellRoute + modal routes
│
├── providers/             # Riverpod providers (DI + state)
│   └── database_provider.dart
│
└── l10n/                  # Generated localization (en + ur)
```

### 2.3 Inter-Process Communication

| IPC Mechanism | Direction | Purpose |
|---------------|-----------|---------|
| `MethodChannel('focus_shield')` | Dart ↔ Kotlin | Toggle Android DND mode during focus sessions |
| `MethodChannel('app_shortcuts')` | Dart ↔ Kotlin | Handle Android app shortcut launch intent |
| `Workmanager` background isolate | Main isolate ↔ Background isolate | Periodic sync task (15 min) in separate Dart VM |
| `StreamController.broadcast()` | Service → UI | Offline queue change notifications |
| `connectivity_plus` stream | Native → Dart | Connectivity state changes (online/offline banner) |
| `SharedPreferences` | Main isolate ↔ Background isolate | Persistent config (quota counters, queue state) |

### 2.4 Onboarding State Machine

The navigation layer implements a two-stage gate implemented via `_RouterRefreshNotifier`:

```
┌─────────────┐
│   Start     │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│ dbFutureProvider?   │── No ──▶ return null (wait)
│   resolved?         │
└─────────┬───────────┘
          │ Yes
          ▼
┌─────────────────────┐
│ userProfile exists? │── No ──▶ redirect /onboarding
│                     │
└─────────┬───────────┘
          │ Yes
          ▼
┌─────────────────────┐
│ Normal Navigation   │
│ (ShellRoute / modal)│
└─────────────────────┘
```

### 2.5 Focus Session State Machine

```
┌─────────┐
│  IDLE    │ ← New session can be initiated
└────┬────┘
     │ startSession()
     ▼
┌─────────┐
│ RUNNING  │ ← Timer active, DND enabled (Android)
└────┬────┘
     │ complete() / pause() / app dispose()
     ▼
┌─────────┐
│COMPLETED │ ← Session persisted, DND disabled
└────┬────┘
     │ reset()
     ▼
┌─────────┐
│  IDLE    │
└─────────┘
```

---

## 3. Deep-Dive Subsystem Mechanics

### 3.1 Data Layer

#### 3.1.1 DatabaseHelper (sqflite Singleton)

`DatabaseHelper` implements a thread-safe singleton with double-checked locking:

```dart
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static Future<Database>? _databaseOpening;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _databaseOpening ??= _initDB('study_planner.db');
    _database = await _databaseOpening!;
    return _database!;
  }
}
```

The database file resides at `getApplicationDocumentsDirectory()/study_planner.db`. On creation, 11 tables are defined with foreign-key constraints (`ON DELETE CASCADE` / `ON DELETE SET NULL`).

**Schema versioning strategy:** The database is opened at `version: 1`. On every open, `_extendSchema()` runs inside a transaction, querying `PRAGMA table_info()` for each table to detect missing columns and applying `ALTER TABLE` additions idempotently. This enables backward-compatible schema evolution without data destruction.

**11-Table Schema:**

| Table | Primary Key | Foreign Keys | Purpose |
|-------|-------------|--------------|---------|
| `user_profiles` | `id` (auto) | — | Single-row user configuration |
| `subjects` | `id` (auto) | — | Academic subjects |
| `chapters` | `id` (auto) | `subject_id` → subjects | Chapter-level granularity |
| `study_tasks` | `id` (auto) | `subject_id`, `chapter_id` | Scheduled study tasks |
| `focus_sessions` | `id` (auto) | `task_id` → study_tasks | Pomodoro session records |
| `revision_items` | `id` (auto) | `chapter_id` → chapters | Spaced-repetition queue |
| `resources` | `id` (auto) | `subject_id`, `chapter_id` | PDF/pinned resources |
| `practical_records` | `id` (auto) | `subject_id`, `resource_id` | Lab practical records |
| `backup_records` | `id` (auto) | — | Backup audit trail |
| `syllabus_templates` | `id` (auto) | — | Imported/exported syllabus schemas |
| `sync_meta` | `id` (auto) | — | Local outbox metadata; `UNIQUE(entity, local_id)` |

#### 3.1.2 Drift ORM (Optional, Android-Only)

`AppDatabase` provides type-safe DAO access via the Drift framework. It is initialized only when `Platform.isAndroid` using `NativeDatabase.createInBackground()`, which offloads SQLite I/O to a background isolate. The `DatabaseRepository` selects between sqflite and Drift at runtime via the `_useDrift` getter:

```dart
bool get _useDrift => driftDb != null;

Future<int> insertSubject(SubjectModel subject) async {
  int id;
  if (_useDrift) {
    id = await driftDb!.into(driftDb!.subjects).insert(
      SubjectsCompanion.insert(
        name: subject.name,
        color: subject.color,
        sortOrder: subject.sortOrder,
        createdAt: subject.createdAt,
      ),
    );
  } else {
    id = await db.insertSubject(subject.toMap());
  }
  await _trackChange('subjects', id.toString(), 'create', subject.toMap());
  return id;
}
```

The Drift schema is maintained in parallel with the raw SQLite schema; both must be updated when columns or tables change. `schemaVersion` is currently 3.

#### 3.1.3 Data Models

All models are plain Dart classes with `toMap()` and `fromMap()` constructors. `fromMap()` uses defensive type checking to handle partial or legacy rows:

```dart
factory UserModel.fromMap(Map<String, dynamic> map) {
  return UserModel(
    id: map['id'] as int?,
    studentName: map['student_name'] is String
        ? map['student_name'] as String
        : '',
    // ... all fields with defensive casting
  );
}
```

This protects against:
- Rows from older schema versions that lack newer columns
- Malformed data from backup imports
- Type coercion edge cases between sqflite and Drift

#### 3.1.4 DatabaseRepository (Central Facade)

`DatabaseRepository` is the **sole intermediary** between the UI layer and the database. It enforces `INV-1` and `INV-2`. Key responsibilities:

**CRUD Operations:** Every entity type has typed accessors (e.g., `getTodayTasks()`, `getTasksForDate()`, `getSubjectProgress()`). Each mutating method calls `_trackChange()` to write a `sync_meta` entry.

**SM-2 Spaced Repetition Algorithm:**

The implementation follows the SuperMemo-2 specification with the following mechanics:

```dart
double _sm2NewEaseFactor(double currentEaseFactor, int quality) {
  final q = quality.clamp(0, 5);
  final adjustment = 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02);
  return max(_sm2MinEaseFactor, currentEaseFactor + adjustment);
}

int _sm2NewInterval(int repetitions, double easeFactor, int currentInterval) {
  if (repetitions == 0) return 1;    // First review: 1 day
  if (repetitions == 1) return 6;    // Second review: 6 days
  if (repetitions == 2) return 6;    // Third review: 6 days
  return (currentInterval * easeFactor).round().clamp(1, 365);
}

Map<String, dynamic> _sm2Schedule(...) {
  final newEaseFactor = _sm2NewEaseFactor(currentEaseFactor, quality);
  int newRepetitions = currentRepetitions;
  if (quality >= 3) {
    newRepetitions += 1;            // Successful recall increments
  } else {
    newRepetitions = 0;             // Failed recall resets streak
  }
  final newInterval = _sm2NewInterval(newRepetitions, newEaseFactor, currentInterval);
  final dueAt = DateTime.now().add(Duration(days: newInterval)).toIso8601String();
  return { 'ease_factor': newEaseFactor, 'interval_days': newInterval, ... };
}
```

Confidence-to-quality mapping:
```dart
int _confidenceToSm2Quality(int confidence) {
  if (confidence >= 90) return 5;
  if (confidence >= 75) return 4;
  if (confidence >= 60) return 3;
  if (confidence >= 40) return 2;
  if (confidence >= 20) return 1;
  return 0;
}
```

**Task Scoring Function:**
```dart
int computeTaskScore(TaskModel task, int dailyMinutes) {
  var score = 0;
  if (task.dueAt != null) {
    final diff = DateTime.parse(task.dueAt!).difference(now).inDays;
    score += diff < 0 ? 50 : (30 - diff.clamp(0, 30));
  }
  score += task.priority * 10;
  if (task.estimatedMinutes <= dailyMinutes) score += 5;
  return score;
}
```

**Analytics Queries:** Six raw SQL analytics methods provide insights:
- `getRecallTrends()` — 90-day rolling average confidence by subject
- `getSubjectConfidenceDecay()` — Subject-level confidence aggregation
- `getTaskEstimateAccuracy()` — Estimated vs. actual focus minutes per task
- `getProductiveTimeInsights()` — Hour-of-day focus session distribution
- `getMissedDayPatterns()` — 30-day completion rate by date
- `getSubjectEstimateAccuracy()` — Per-subject estimate accuracy

**Sync Tracking (`_trackChange`):**
```dart
Future<void> _trackChange(String entity, String localId, String operation, Map<String, dynamic> data) async {
  await rawDb.insert('sync_meta', {
    'entity': entity,
    'local_id': localId,
    'sync_status': 'pending',
    'conflict_data': null,
    'created_at': now,
    'updated_at': now,
  }, conflictAlgorithm: ConflictAlgorithm.replace);
}
```

The `UNIQUE(entity, local_id)` constraint ensures idempotent retry behavior.

### 3.2 Service Layer

#### 3.2.1 SyncService

A singleton bridging local changes to Firestore. Key operations:

- `enqueueLocalChange()` — Writes a `sync_outbox` document with `synced: false`. Does NOT directly mutate the target collection; the Cloud Function `syncWorker` handles application.
- `markEntityDeleted()` — Writes a `sync_tombstones` document with `deletedAt` timestamp.
- `retryPending()` — Client-side fallback that reads unsynced outbox items and applies them directly to target collections. Uses last-write-wins for non-delete operations.
- `pruneTombstones()` — Deletes tombstones older than 30 days.
- `recordConflict()` — Writes a `sync_conflicts` document with `localData` and `remoteData` snapshots.

All methods follow the guard pattern:
```dart
Future<void> _ensureFirebase() async {
  if (_firestore != null) return;
  try {
    _firestore = FirebaseFirestore.instance;
  } catch (_) {
    _firestore = null;
  }
}
```

And every public method catches `FirebaseException` silently:
```dart
try {
  await _firestore!.collection('sync_outbox').add({...});
} on FirebaseException catch (_) {}
```

#### 3.2.2 OfflineQueueService

A client-side queue persisted as JSON in `SharedPreferences` under the key `offline_queue`. It holds `QueuedOperation` objects with fields: `type` (`sync`, `ai`, `tombstone`), `payload`, `attemptCount`, `createdAt`, `updatedAt`.

Processing semantics:
- `processQueue()` iterates queued operations, attempting each.
- On failure, `attemptCount` is incremented.
- Operations exceeding `_maxAttempts` (3) are dropped.
- A `StreamController<void>.broadcast()` notifies listeners.

This queue is distinct from the Firestore `sync_outbox`: the `OfflineQueueService` buffers operations when the device is offline; the Firestore outbox is the eventual cloud consistency target.

#### 3.2.3 SyncWorkerService

Orchestrates background sync via `workmanager`. Registers a periodic task (`sync_worker_process_queue`) with:
- Frequency: 15 minutes
- Network constraint: `NetworkType.connected`
- Backoff: linear starting at 5 minutes

The worker runs in a **separate Dart isolate** using `@pragma('vm:entry-point')` to ensure the entry point is retained in release builds. It initializes Firebase independently from the main isolate:

```dart
@pragma('vm:entry-point')
void syncWorkerDispatcher() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Process queue, retry pending, force sync
}
```

State machine: `idle → syncing → idle | error`. An `_isRunning` boolean provides coarse re-entrancy guarding.

#### 3.2.4 AIService

Client-side gateway for AI features. Calls `aiProxy` and `ocrProcess` via `httpsCallable`. Enforces five gates in sequence:

1. **Consent:** `hasAiConsent()` / `hasOcrConsent()` from `SharedPreferences`
2. **Cost warning:** `hasAcceptedCostWarning()`
3. **Quota:** 50 requests/day tracked client-side (with date-rollover reset) and server-side
4. **Connectivity:** `ConnectivityService.isOnline` must be true
5. **Firebase availability:** `FirebaseFunctions` instance must be non-null

If any gate fails, a localizable error string is returned (no exception thrown). The embedded system prompt enforces:
- Draft-only output (not final answers)
- Source grounding
- Academic-integrity guardrails
- Age-appropriate language for Pakistani Matric curriculum

#### 3.2.5 ConnectivityService

Singleton wrapping `connectivity_plus`. Provides:
- `isOnline` (`Future<bool>`)
- `onConnectivityChanged` (`Stream<bool>`)

Consumed by `AppShell` to render an offline banner.

#### 3.2.6 Analytics / Crashlytics / RemoteConfig

All three follow the same pattern:
- `_initialized` boolean guard
- `try/catch` on initialization
- Graceful degradation to no-op when Firebase is unavailable

`CrashlyticsService` is wired to `FlutterError.onError` in `main()`:
```dart
FlutterError.onError = (details) {
  FlutterError.dumpErrorToConsole(details);
  CrashlyticsService.instance.recordError(
    details.exception,
    details.stack ?? StackTrace.current,
  );
};
```

### 3.3 Feature Layer

#### 3.3.1 Planner — Greedy Knapsack Daily Budget

The planner generates a daily study plan by:

1. Fetching all pending tasks via `getAllPendingTasks()`
2. Scoring each task via `computeTaskScore()` (urgency × 1 + priority × 10 + fit-bonus × 5)
3. Sorting tasks descending by score
4. Filling the daily minute budget greedily: adding tasks in score order until `sum(estimatedMinutes) >= dailyStudyMinutes`
5. Surfacing overflow tasks for manual rescheduling

**Complexity:** O(n log n) due to sort, where n = pending tasks. The greedy approach is not optimal for the knapsack problem but is computationally cheap and produces acceptable results for the Matric use case (small task sets).

#### 3.3.2 Focus — Pomodoro with Android DND

The focus screen implements a three-state machine (`idle` → `running` → `completed`). Key behaviors:

- On `dispose()` or `AppLifecycleState.paused`, an in-progress session is persisted via `_saveSession()` to prevent data loss.
- Android DND is toggled via `MethodChannel('focus_shield')`:
  - `isFocusShieldAvailable` — checks `NotificationManager.PolicyAccess`
  - `toggleFocusShield(enable)` — calls `setInterruptionFilter(INTERRUPTION_FILTER_NONE)` or `INTERRUPTION_FILTER_ALL`
- A foreground service (`FocusShieldForegroundService`) keeps the DND session alive against Android OS killing.

#### 3.3.3 Backup — Encrypted Export/Import

The backup feature follows a full DDD split:

- **Domain:** `BackupRecord`, `BackupSettings`, `RestoreResult`, `RestoreConflict` (immutable)
- **Domain repositories:** `BackupRepository`, `BackupEncryptionService`, `BackupStorageService`, `BackupScheduler`, `RestoreService` (abstract interfaces)
- **Data repositories:** `LocalBackupRepository`, `LocalBackupEncryptionService`, `LocalBackupStorageService`, `LocalRestoreService`
- **Application:** `BackupManager` — composes repositories into workflows
- **Presentation:** `backup_manager_screen.dart`

**Encryption mechanics:**
- Algorithm: AES-256 via the `encrypt` package (AES-CBC under the hood)
- Key: 32-byte `Key.fromSecureRandom(32)`
- Key storage:
  - Android/iOS/macOS: `FlutterSecureStorage` (platform Keystore/Keychain)
  - Linux/Windows: `SharedPreferences` (plaintext fallback)
- File format: `MSP_BACKUP_V1` magic header + 16-byte IV + AES ciphertext

**Restore validation:**
1. File existence check
2. Empty file detection
3. Decryption failure (magic header mismatch, truncated data)
4. Invalid JSON
5. Missing required fields
6. Schema version mismatch (must equal `_schemaVersion = 2`)

Each failure mode returns a `RestoreResult` with `success: false` and an error message; no exceptions propagate to the UI.

#### 3.3.4 Revision — SM-2 Spaced Repetition

The revision screen displays due items where `due_at <= now`. When a user submits confidence feedback:

1. Confidence (0–100) is mapped to SM-2 quality (0–5) via `_confidenceToSm2Quality`
2. `_sm2Schedule()` computes new ease factor, interval, and repetition count
3. The next review is scheduled at `now + interval_days`
4. For completed reviews with linked chapters, active task estimates are adjusted:
   ```dart
   final ratio = originalEstimate > 0 ? confidence / 100.0 : 0.5;
   final newEstimate = (originalEstimate * ratio).round().clamp(1, originalEstimate * 3);
   ```

### 3.4 Cloud Layer

#### 3.4.1 Cloud Functions

Four Firebase Cloud Functions (TypeScript, Firebase Functions v2):

| Function | Trigger | Purpose |
|----------|---------|---------|
| `aiProxy` | `https.onCall` | Proxies AI requests to OpenAI/Anthropic/Gemini with consent + quota checks |
| `ocrProcess` | `https.onCall` | Enqueues OCR jobs via Google Vision API with duplicate suppression |
| `syncWorker` | `pubsub.schedule('every 15 minutes')` | Processes `sync_outbox`, applying mutations to target collections |
| `pruneTombstones` | `pubsub.schedule('every 24 hours')` | Deletes `sync_tombstones` older than 30 days |

**aiProxy flow:**
1. Validate `context.auth.uid` exists
2. Read `ai_consents/{userId}` document
3. Enforce 50-request/day quota by querying `ai_requests` for current day
4. Record request in `ai_requests` (prompt truncated to 2000 chars)
5. Resolve provider/model, call appropriate AI SDK
6. Validate response non-empty and ≤ 4000 chars
7. Return `{ requestId, provider, model, output, notice }`

**ocrProcess flow:**
1. Validate auth and OCR consent
2. Duplicate detection: query `ocr_jobs` for matching `userId` + `filePath` with status `queued`/`processing` within last hour
3. Create `ocr_jobs` document
4. Invoke `ImageAnnotatorClient.asyncBatchAnnotateFiles()` for PDF text detection
5. Return job ID for client polling

**syncWorker flow:**
1. Read `sync_outbox` where `synced == false` (limit 100)
2. For each document, resolve target collection reference
3. Apply `delete`, `update`, or `set(..., {merge: true})`
4. Mark document `synced: true` with `syncedAt` timestamp
5. On failure, write error to document's `error` field; function does NOT throw

**pruneTombstones flow:**
1. Query `sync_tombstones` where `deletedAt < cutoff` (30 days ago, limit 500)
2. Batch delete
3. Commit

#### 3.4.2 Firestore Security Rules

The rules implement a strict **owner-based access control** model:

```
function isOwner(userId) {
  return isAuthenticated() && request.auth.uid == userId;
}
```

| Collection | Read | Write/Create |
|------------|------|--------------|
| `sync_outbox` | Authenticated + owner | Authenticated + owner |
| `sync_tombstones` | Authenticated + owner | Authenticated + owner |
| `sync_conflicts` | Authenticated + owner | Authenticated + owner |
| `user_profiles` | Owner | Owner |
| `quizzes` | Authenticated | Owner |
| `quiz_attempts` | Owner | Owner |

Collections `ai_consents`, `ai_requests`, `ocr_jobs`, and `ai_hallucination_reports` are not explicitly listed because they are accessed exclusively by Cloud Functions (which bypass client-side rules) or by client methods with embedded ownership checks.

#### 3.4.3 Storage Rules

| Path | Access |
|------|--------|
| `users/{userId}/{allPaths=**}` | Read/Write: owner only |
| `ai-uploads/{userId}/{allPaths=**}` | Read/Write: owner only |
| `ocr-output/{userId}/{allPaths=**}` | Read/Write: owner only |
| `study-groups/{groupId}/{allPaths=**}` | Read: authenticated; Write: denied |

---

## 4. Memory Management & Hardware/Resource Interaction

### 4.1 Dart Isolate Model

The Flutter application operates primarily in a **single Dart isolate** with a single-threaded event loop. Database operations are `async` and yield to the event loop at `await` points; they are not dispatched to separate OS threads.

- **sqflite path:** Queries execute on the main isolate's event loop. SQLite itself is thread-safe at the C level, but the Dart wrapper serializes access through the singleton `DatabaseHelper`.
- **Drift path:** `NativeDatabase.createInBackground()` offloads SQLite I/O to a **background Dart isolate** using `Isolate.spawn`. This prevents I/O latency from blocking the UI thread.
- **workmanager:** Spawns a **separate Dart isolate** for background sync. The entry point is annotated with `@pragma('vm:entry-point')` to prevent tree-shaking in release builds. This isolate initializes its own `Firebase.initializeApp()` instance.

### 4.2 Memory Layout & Allocation Profiles

| Resource | Location | Lifetime | Notes |
|----------|----------|----------|-------|
| SQLite database file | `getApplicationDocumentsDirectory()/study_planner.db` | Persistent | ~11 tables; estimated 2–10 MB for typical Matric student data |
| Encryption key (backup) | `FlutterSecureStorage` or `SharedPreferences` | Persistent | 32 bytes; plaintext fallback on desktop |
| Backup files | `documents/backups/` | Persistent | AES-256 ciphertext; user-initiated |
| Sync outbox (Firestore) | Cloud | Ephemeral | Marked `synced: true` after processing |
| Offline queue (SharedPreferences) | Local | Ephemeral | Max 3 retry attempts per operation |
| `sync_meta` table | SQLite | Persistent | Local outbox ledger; entries accumulate until synced |
| Focus session state | In-memory + SQLite | Session + persistent | Saved on `dispose()` to prevent data loss |

### 4.3 Zero-Copy Abstractions

The application does not employ explicit zero-copy abstractions. Data flows through:
1. SQLite returns `Map<String, dynamic>` rows
2. `fromMap()` constructs model instances (copy)
3. `toMap()` serializes back to `Map<String, dynamic>`
4. Firestore writes receive these maps directly

For large payloads (AI prompts, OCR PDFs), data is transferred as:
- AI prompts: ≤2000 chars truncated server-side
- AI responses: ≤4000 chars validated server-side
- OCR files: Uploaded to Firebase Storage; processing is asynchronous via polling

### 4.4 Native Android Integration

**FocusShieldForegroundService (Kotlin):**

```kotlin
class FocusShieldForegroundService : Service() {
  override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
    val notification = createNotification("Focus session active", "DND mode enabled")
    startForeground(NOTIFICATION_ID, notification)
    // Toggle DND via NotificationManager
    return START_STICKY
  }
}
```

The foreground service holds a persistent notification and prevents the OS from killing the DND toggle process during active focus sessions.

**FocusAccessibilityService (Kotlin):** An optional accessibility service for usage-time tracking (not actively used in the current feature set).

**App Shortcuts:** `MainActivity.kt` registers the `focus_shield` platform channel and handles the `app_shortcuts` channel for launch-intent detection.

### 4.5 Platform-Specific Constraints

| Platform | sqflite | Drift | Secure Storage | Notes |
|----------|---------|-------|----------------|-------|
| Android | ✓ | ✓ (default) | Keystore | Primary target |
| iOS | ✓ | ✗ | Keychain | Not primary target |
| Linux | ✓ (FFI) | ✗ | SharedPreferences (plaintext) | Desktop support |
| Windows | ✓ (FFI) | ✗ | SharedPreferences (plaintext) | Desktop support |
| macOS | ✓ (FFI) | ✗ | Keychain | Desktop support |
| Web | ✗ | ✗ | ✗ | Explicitly unsupported |

---

## 5. Data Flow, Interfaces & API Specifications

### 5.1 End-to-End Data Flow: Local Write → Cloud Sync

```
Pathway A: Local Mutation → Cloud Synchronization
═══════════════════════════════════════════════════════

Step 1: UI Invocation
  └─ User action (e.g., complete chapter)
     └─ UI calls DatabaseRepository.updateChapterStatus(id, 'completed')

Step 2: Local Database Write
  └─ DatabaseHelper.updateChapterStatus()
     └─ SQLite: UPDATE chapters SET status='completed', completed_at=... WHERE id=?
     └─ Returns row count

Step 3: Sync Metadata Tracking (INV-2)
  └─ DatabaseRepository._trackChange('chapters', id.toString(), 'update', {...})
     └─ SQLite: INSERT OR REPLACE INTO sync_meta (entity, local_id, sync_status, ...)
        VALUES ('chapters', '42', 'pending', ...)

Step 4: Online Cloud Enqueue
  └─ If ConnectivityService.isOnline == true:
     └─ SyncService.enqueueLocalChange(userId, 'chapters', '42', 'update', {...})
        └─ Firestore: sync_outbox.add({
             userId, entity: 'chapters', entityId: '42',
             operation: 'update', data: {...}, synced: false
           })

Step 5a: Background Cloud Processing (every 15 min)
  └─ Cloud Function syncWorker
     └─ Queries sync_outbox where synced == false
     └─ For each: applies to target Firestore collection
     └─ Marks synced: true

Step 5b: Client-Side Fallback (if Cloud Function unavailable)
  └─ SyncService.retryPending()
     └─ Reads sync_outbox where synced == false
     └─ Applies create/update/delete to target collection
     └─ Marks synced: true

Step 6: Offline Queue (if Step 4 fails)
  └─ OfflineQueueService.enqueue({ type: 'sync', payload: {...} })
     └─ SharedPreferences: stores JSON array
  └─ Workmanager (15 min, NetworkType.connected):
     └─ SyncWorkerService.processQueue()
        └─ OfflineQueueService.processQueue()
           └─ For each queued operation: calls SyncService.enqueueLocalChange()
```

### 5.2 End-to-End Data Flow: AI Request

```
Pathway B: AI-Assisted Task Breakdown
═══════════════════════════════════

Step 1: UI Invocation
  └─ User taps "AI Task Breakdown" on a chapter
     └─ UI calls AIService.generateTaskBreakdown(chapterTitle)

Step 2: Gate Checks (sequential, short-circuit on failure)
  └─ hasAiConsent() → SharedPreferences
  └─ hasAcceptedCostWarning() → SharedPreferences
  └─ getQuotaRemaining() → SharedPreferences (date-rollover)
  └─ ConnectivityService.isOnline → Future<bool>
  └─ Any gate fails → return localized error string

Step 3: Client-Side Quota Increment
  └─ SharedPreferences: increment ai_requests_today, set ai_requests_date

Step 4: Cloud Function Call
  └─ FirebaseFunctions.httpsCallable('aiProxy')
     └─ Server-side:
        - Auth check (context.auth.uid)
        - Consent check (ai_consents/{userId}.aiAssistance)
        - Quota check (ai_requests count for today < 50)
        - Record request in ai_requests collection
        - Resolve provider/model
        - Call OpenAI/Anthropic/Gemini SDK
        - Validate output non-empty, ≤ 4000 chars
     └─ Returns { requestId, provider, model, output, notice }

Step 5: UI Display
  └─ UI renders output with "AI responses may contain errors" disclaimer
  └─ Optionally store in hallucination_reports for later review
```

### 5.3 End-to-End Data Flow: Backup Creation

```
Pathway C: Encrypted Local Backup
════════════════════════════════

Step 1: BackupManager.createBackup()
  └─ DatabaseRepository collects all entities:
     subjects, chapters, tasks, focus_sessions, revision_items,
     resources, practical_records, user_profiles, backup_records,
     syllabus_templates, sync_meta
  └─ Serializes to JSON

Step 2: Encryption
  └─ LocalBackupEncryptionService.encryptData(jsonString)
     └─ Retrieves/generates 32-byte AES key from FlutterSecureStorage
     └─ Generates 16-byte random IV
     └─ AES-CBC encrypt: ciphertext = AES.encrypt(pkcs7_pad(json), key, iv)
     └─ Returns: "MSP_BACKUP_V1" + iv_base64 + ciphertext_base64

Step 3: File Write
  └─ LocalBackupStorageService.writeBackupFile(encryptedData)
     └─ Path: getApplicationDocumentsDirectory()/backups/backup_<timestamp>.msp
     └─ File write

Step 4: Metadata Record
  └─ DatabaseHelper.insertBackupRecord(destination, status)
     └─ SQLite: INSERT INTO backup_records (created_at, destination, status)
```

### 5.4 Public API Specifications

#### 5.4.1 DatabaseRepository Interface

```dart
class DatabaseRepository {
  // User
  Future<UserModel?> getUserProfile();
  Future<int> createUserProfile(UserModel profile);
  Future<int> updateUserProfile(UserModel profile);

  // Subjects
  Future<List<SubjectModel>> getSubjects();
  Future<int> insertSubject(SubjectModel subject);
  Future<int> deleteSubject(int id);

  // Chapters
  Future<List<ChapterModel>> getChaptersBySubject(int subjectId);
  Future<int> insertChapter(ChapterModel chapter);
  Future<int> updateChapterStatus(int id, String status);
  Future<void> setChapterCompletion(int chapterId, bool completed);
  Future<ChapterModel?> getChapterById(int id);

  // Tasks
  Future<List<TaskModel>> getTodayTasks();
  Future<List<TaskModel>> getAllPendingTasks();
  Future<List<TaskModel>> getTasksForDate(DateTime date);
  Future<List<TaskModel>> getTasksForDateRange(DateTime start, DateTime end);
  Future<int> insertTask(TaskModel task);
  Future<int> updateTask(int id, Map<String, dynamic> data);
  Future<int> deleteTask(int id);
  int computeTaskScore(TaskModel task, int dailyMinutes);

  // Focus Sessions
  Future<FocusSessionModel?> getActiveFocusSession();
  Future<int> insertFocusSession(FocusSessionModel session);
  Future<int> updateFocusSession(int id, Map<String, dynamic> data);

  // Revision (SM-2)
  Future<List<RevisionItemModel>> getDueRevisions();
  Future<void> recordRevisionFeedback(int revisionId, int confidence, String status);

  // Analytics
  Future<List<Map<String, dynamic>>> getRecallTrends();
  Future<List<Map<String, dynamic>>> getSubjectConfidenceDecay();
  Future<List<Map<String, dynamic>>> getTaskEstimateAccuracy();
  Future<List<Map<String, dynamic>>> getProductiveTimeInsights();
  Future<List<Map<String, dynamic>>> getMissedDayPatterns();
  Future<List<Map<String, dynamic>>> getSubjectEstimateAccuracy();

  // Search
  Future<List<dynamic>> search(String query);

  // Backup
  Future<List<Map<String, dynamic>>> getBackupHistory();
  String exportAnkiCsv(List<SubjectModel> subjects, List<ChapterModel> chapters);
  List<Map<String, dynamic>> importAnkiCsv(String csvContent, int subjectId);
}
```

#### 5.4.2 SyncService Interface

```dart
class SyncService {
  Future<void> enqueueLocalChange({
    required String userId,
    required String entity,
    required String entityId,
    required String operation, // 'create' | 'update' | 'delete'
    required Map<String, dynamic> data,
  });

  Future<void> markEntityDeleted({
    required String userId,
    required String entity,
    required String entityId,
  });

  Future<List<Map<String, dynamic>>> getPendingOutbox(String userId);
  Future<void> markSynced(String outboxId);
  Future<void> recordConflict({
    required String userId,
    required String entity,
    required String entityId,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
  });
  Future<void> retryPending();
  Future<int> pruneTombstones();
  Future<int> getPendingOutboxCount();
  Future<int> getPendingConflictsCount();
}
```

#### 5.4.3 AIService Interface

```dart
class AIService {
  Future<String> generateTaskBreakdown(String chapterTitle, String subjectName);
  Future<String> generateRevisionDraft(String chapterTitle);
  Future<String> generateFlashcards(String chapterTitle);
  Future<String> generateQuiz(String chapterTitle, int questionCount);
  Future<String> answerSubjectQuestion(String question, String context);
  Future<String> processOcrScan(String filePath, String language);
}
```

All methods return `String` — either the AI output or a localizable error message. No exceptions are thrown for gating failures.

#### 5.4.4 Type System & Invariants

The Dart type system is used extensively but relies on runtime checks for external data (SQLite rows, Firestore documents, JSON). Key type invariants:

- `TaskModel.status` is one of: `'pending'`, `'in_progress'`, `'completed'`
- `FocusSessionModel.status` is one of: `'running'`, `'completed'`, `'paused'`
- `revision_items.recall_confidence` is `int` in range [0, 100]
- `revision_items.ease_factor` is `double` ≥ 1.3
- `sync_meta.sync_status` is one of: `'pending'`, `'synced'`, `'conflict'`
- `chapters.content_tier` is one of: `'official'`, `'supplementary'`

The `sync_meta` table has a `UNIQUE(entity, local_id)` constraint enforced at the SQLite level, ensuring that `_trackChange()` calls are idempotent for the same entity mutation.

---

## 6. Verification, Safety & Security Model

### 6.1 Static Analysis & Testing

| Layer | Tool | Coverage |
|-------|------|----------|
| Dart/Flutter | `flutter analyze` (flutter_lints baseline) | All Dart code |
| Unit tests | `flutter test` | 21 unit test files + widget tests |
| Firestore rules | Jest + `@firebase/rules-unit-testing` | Rule logic validation |
| Cloud Functions | Jest | Function logic + error paths |
| CI/CD | GitHub Actions | Format, analyze, test, build on push/PR |

Test files cover: AI service, sync service, offline queue, backup encryption/restore, planner logic, repository, focus screen, settings, legal screen, OCR service, production fixes, and sync worker.

### 6.2 Defensive Programming Guarantees

**Type Safety in Data Models:** Every `fromMap()` constructor uses `is` checks before casting:
```dart
studentName: map['student_name'] is String ? map['student_name'] as String : '',
```

This protects against partial rows, legacy schemas, and malformed backup imports.

**Firebase Error Swallowing:** All Firebase-dependent services catch `FirebaseException` and return safe defaults. This is an intentional invariant — no Firebase dependency may crash the app. Verified by tests in `test/unit/sync_service_test.dart`.

**FlutterError.onError:** Captures all Flutter framework errors and routes them to Crashlytics when available:
```dart
FlutterError.onError = (details) {
  FlutterError.dumpErrorToConsole(details);
  CrashlyticsService.instance.recordError(details.exception, details.stack);
};
```

### 6.3 Security Architecture

#### 6.3.1 Threat Model

| Threat | Mitigation |
|--------|------------|
| Unauthorized cloud data access | Firestore/Storage owner-based rules; all collections require `request.auth.uid == userId` |
| Data resurrection after delete | 30-day tombstone retention in `sync_tombstones`; Cloud Function applies tombstones before allowing new creates |
| AI quota abuse | Client-side (50/day SharedPreferences) + server-side (Firestore `ai_requests` count) enforcement |
| AI consent bypass | Both client and server enforce `ai_consents/{userId}.aiAssistance` |
| Backup decryption by attacker | AES-256 encryption; key in platform Keystore/Keychain (not plaintext on mobile) |
| Backup tampering | Magic header validation (`MSP_BACKUP_V1`); schema version check on restore |
| Unauthorized DND toggle | Android `ACCESS_NOTIFICATION_POLICY` permission required; app directs user to system settings if missing |
| Sync conflict data loss | Last-write-wins for non-deletes; true conflicts recorded in `sync_conflicts` for manual resolution |
| Excessive AI cost | 50-request/day quota; cost-warning acceptance required before first AI use |
| OCR duplicate processing | Server-side duplicate detection: same `userId` + `filePath` + status within 1 hour |

#### 6.3.2 Memory Safety Invariants

- All SQLite operations use parameterized queries (no string concatenation in `where` clauses)
- Foreign keys use `ON DELETE CASCADE` / `ON DELETE SET NULL` to prevent orphaned rows
- The `sync_meta` `UNIQUE(entity, local_id)` constraint prevents duplicate outbox entries
- AES encryption uses random IV per operation (no ECB mode; AES-CBC via `encrypt` package)
- Encryption keys are never logged or transmitted

#### 6.3.3 Permission & Consent Model

| Feature | Client Gate | Server Gate |
|---------|-------------|-------------|
| Cloud sync | None (always enabled when online) | Firestore rules (authenticated) |
| AI assistance | `hasAiConsent()` + `hasAcceptedCostWarning()` + quota | `ai_consents/{userId}.aiAssistance` |
| OCR scanning | `hasOcrConsent()` + connectivity | `ai_consents/{userId}.ocrScanning` |
| Analytics | `AnalyticsService.initialize()` (opt-out via settings) | N/A (Firebase config) |
| Crashlytics | `CrashlyticsService.initialize()` | N/A (Firebase config) |
| Android DND | `ACCESS_NOTIFICATION_POLICY` runtime permission | N/A (OS-level) |

#### 6.3.4 Licensing & Governance

- **License:** Apache License, Version 2.0
- **Copyright:** CodeSym, 2026
- **Third-party dependencies:** Managed via `pubspec.yaml` and `package.json`; all licenses are permissive (MIT, BSD, Apache) compatible with the project's Apache 2.0 license
- **AI provider terms:** Users are responsible for compliance with OpenAI/Anthropic/Gemini/OpenRouter terms of service; the app does not store API keys client-side (keys are in Firebase Functions config/environment variables)
- **Data retention:** Documented in `docs/legal/data_retention_policy.md`; sync tombstones pruned after 30 days

---

## 7. Performance Profiles & Benchmarking

### 7.1 Theoretical Performance Bounds

| Operation | Complexity | Notes |
|-----------|------------|-------|
| `getTodayTasks()` | O(n) | Full table scan with date filter; n = total tasks |
| `getAllPendingTasks()` | O(n) | Full table scan with status filter |
| `getTasksForDate(date)` | O(log n) | Assumes index on `scheduled_at` |
| `getSubjectProgress()` | O(s + c) | Join over subjects + chapters; s = subjects, c = chapters |
| `getRecallTrends()` | O(r) | Raw query with GROUP BY; r = revision items |
| `computeTaskScore(task, dailyMinutes)` | O(1) | Pure arithmetic |
| `_sm2Schedule(...)` | O(1) | Pure arithmetic |
| Greedy knapsack (planner) | O(n log n) | Sort + linear scan |
| `retryPending()` | O(o) | o = outbox items (capped at 100) |
| `search(query)` | O(n × m) | n = total rows across 5 tables; m = avg row size |

### 7.2 SQLite Query Optimization

The application uses raw SQL for analytics queries with explicit JOINs and GROUP BY. The schema lacks explicit indexes beyond primary keys. For typical Matric data volumes (≤100 subjects, ≤1000 chapters, ≤5000 tasks), query times are sub-10ms on modern mobile hardware.

Recommended index additions for scaling:
```sql
CREATE INDEX idx_study_tasks_scheduled_at ON study_tasks(scheduled_at);
CREATE INDEX idx_study_tasks_status ON study_tasks(status);
CREATE INDEX idx_revision_items_due_at ON revision_items(due_at);
CREATE INDEX idx_focus_sessions_task_id ON focus_sessions(task_id);
CREATE INDEX idx_sync_meta_entity_local_id ON sync_meta(entity, local_id);
```

### 7.3 Background Sync Efficiency

- **Frequency:** 15 minutes (configurable via Remote Config)
- **Batch size:** 100 outbox items per syncWorker invocation
- **Tombstone pruning:** 500 tombstones per `pruneTombstones` invocation (daily)
- **Network constraint:** `NetworkType.connected` — sync does not run on metered/unmetered ambiguity; requires active connectivity

The 15-minute interval is a trade-off between cloud consistency and battery/network usage. For a student population primarily on mobile data, this minimizes background network activity while maintaining reasonable sync freshness.

### 7.4 Offline Queue Bounds

- **Max retries per operation:** 3
- **Persistence:** `SharedPreferences` (JSON array)
- **Eviction:** Operations exceeding max retries are silently dropped
- **Memory footprint:** Negligible; queue is loaded into memory on access and written back on modification

### 7.5 Focus Session Timer Precision

The Pomodoro timer uses Dart's `Timer.periodic()` with a 1-second tick. On `AppLifecycleState.paused`, the session is persisted to SQLite. On resume, the timer continues from its last tick. There is no compensation for time spent in background; the timer counts wall-clock seconds.

### 7.6 AI Request Throughput

- **Client-side quota:** 50 requests/day per user
- **Server-side quota:** Same 50-request/day limit enforced in `aiProxy`
- **Prompt truncation:** 2000 characters (server-side)
- **Response cap:** 4000 characters (validated server-side)
- **Timeout:** Inherited from Firebase Functions default (60 seconds for `https.onCall`)

### 7.7 Cache Efficiency

The application does not implement an explicit caching layer beyond SQLite. The `DatabaseHelper` singleton caches the open `Database` connection, avoiding repeated file open/close overhead. Riverpod providers cache derived state (e.g., `todayTasksProvider` caches the result until dependencies change).

---

## 8. Deployment, Integration & Future Expansion Roadmap

### 8.1 Production Deployment Requirements

| Component | Target | Build Command | Artifact |
|-----------|--------|---------------|----------|
| Android App | Android 5.0+ (API 21+) | `flutter build apk --release` or `flutter build appbundle` | `.apk` or `.aab` |
| Linux Desktop | x64 Linux | `flutter build linux` | Binary in `build/linux/x64/release/bundle/` |
| Firebase Functions | Node.js 20+ | `cd functions && npm run deploy` | Cloud Functions |
| Firestore Rules | — | `firebase deploy --only firestore:rules` | Security rules |
| Storage Rules | — | `firebase deploy --only storage` | Security rules |

### 8.2 Build Toolchain

```
┌─────────────────────────────────────────────────────────────────┐
│                    BUILD PIPELINE                                │
│                                                                  │
│  flutter analyze                                                  │
│      │                                                           │
│      ▼                                                           │
│  flutter test                                                     │
│      │                                                           │
│      ▼                                                           │
│  flutter build apk --release (Android)                            │
│  flutter build linux (Desktop)                                    │
│      │                                                           │
│      ▼                                                           │
│  cd functions && npm ci && npm run build                         │
│      │                                                           │
│      ▼                                                           │
│  firebase deploy --only functions,firestore,storage              │
└─────────────────────────────────────────────────────────────────┘
```

### 8.3 CI/CD (GitHub Actions)

`.github/workflows/ci.yml` triggers on push/PR to `main`/`develop`:
1. `flutter pub get`
2. `dart format --set-exit-if-changed .`
3. `flutter analyze`
4. `flutter test`
5. Build Android AAB (release) or APK (debug on PR)
6. Build Linux release binary

`.github/workflows/firestore-rules.yml` triggers on changes to rules:
1. `cd functions && npm ci`
2. `npm run test:rules`

### 8.4 Extensibility Mechanisms

#### 8.4.1 Feature Flags

`lib/core/feature_flags.dart` defines compile-time and runtime feature flags:

```dart
class FeatureFlags {
  static const bool enableAI = bool.fromEnvironment('ENABLE_AI', defaultValue: true);
  static const bool enableOCR = bool.fromEnvironment('ENABLE_OCR', defaultValue: true);
  static const bool enableSpacedRepetition = bool.fromEnvironment('ENABLE_SR', defaultValue: true);
  static const bool enableEncryptedStorage = bool.fromEnvironment('ENABLE_ENCRYPTED_STORAGE', defaultValue: true);
  // ...
}
```

Flags can be overridden at build time via `--dart-define=ENABLE_AI=false`.

#### 8.4.2 DDD Pattern for Complex Features

The backup feature demonstrates the full domain/data/presentation/application split. New complex features should follow this pattern:
- Define abstract interfaces in `domain/repositories/`
- Implement in `data/repositories/`
- Compose workflows in `application/`
- Render in `presentation/`

This enables mock-based testing without UI and allows alternative implementations (e.g., cloud backup) by implementing the same interfaces.

#### 8.4.3 AI Provider Extensibility

The `aiProxy` Cloud Function supports multiple AI providers via environment variables:
- `AI_PROVIDER` — selects provider (`openai`, `anthropic`, `gemini`, `openrouter`)
- `AI_API_KEY` — OpenAI/OpenRouter API key
- `ANTHROPIC_API_KEY` — Anthropic API key
- `GEMINI_API_KEY` — Google Gemini API key

Adding a new provider requires:
1. Adding a client factory in `functions/src/index.ts`
2. Adding a branch in the `aiProxy` try block
3. Adding the provider to `providerDefaults`

#### 8.4.4 Syllabus Template System

The `syllabus_templates` table allows importing/exporting structured syllabus data as JSON. The system seeds default Pakistani Matric subjects on first launch if no templates exist. New boards or class levels can be supported by:
1. Adding template entries to `MatricSubjects.subjects`
2. Or importing JSON templates with `{ subjects: [...], chapters: [...] }` structure

### 8.5 Architectural Roadmap

| Phase | Milestone | Technical Work |
|-------|-----------|----------------|
| **v1.1** | Multi-device sync hardening | Implement vector clocks for causality tracking; replace last-write-wins with CRDT merge for task titles |
| **v1.2** | Conflict resolution UX | Build guided merge UI for `sync_conflicts`; auto-archive resolved conflicts |
| **v1.3** | Performance scaling | Add composite indexes on `scheduled_at`, `status`, `due_at`; implement SQLite FTS5 for full-text search |
| **v2.0** | Cloud-native backup | Implement `CloudBackupRepository` interface; store encrypted backups in Firebase Storage with user-controlled keys |
| **v2.1** | Collaborative study groups | Extend Firestore rules for group-scoped collections; implement real-time presence via Firestore listeners |
| **v2.2** | Adaptive ML planning | Replace greedy knapsack with reinforcement learning policy; train on user completion patterns |
| **v3.0** | Platform expansion | Add iOS/macOS support via `flutter_secure_storage` Keychain integration; enable Drift on all platforms |

### 8.6 Known Technical Debt

| Item | Severity | Mitigation |
|------|----------|------------|
| Drift schema maintained in parallel with raw SQLite | Medium | Consider migrating fully to Drift and dropping `DatabaseHelper` |
| `sync_meta` table not exposed via Drift DAOs | Low | Add `SyncMeta` Drift table + DAO |
| Plaintext encryption key fallback on desktop | Medium | Integrate with OS keyrings (libsecret on Linux, Credential Manager on Windows) |
| No FTS5 for search | Low | Add FTS5 virtual tables for `study_tasks`, `chapters`, `subjects` |
| `retryPending()` last-write-wins | Medium | Implement server-side version vectors or operational transforms |
| Hard-coded 15-minute sync interval | Low | Expose via Remote Config + user settings |

---

## Appendix A: ASCII Data Flow Summary

```
┌─────────────────────────────────────────────────────────────────────┐
│                        COMPLETE SYSTEM VIEW                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐    Riverpod     ┌──────────────┐    sqflite/Drift   │
│  │  Flutter  │ ──────────────▶ │ DatabaseRepo │ ──────────────────┤
│  │   UI     │ ◀────────────── │  (Facade)    │                   │
│  └──────────┘                 └──────┬───────┘                   │
│                                     │                              │
│                            ┌────────▼────────┐                    │
│                            │ DatabaseHelper │                    │
│                            │   (sqflite)    │                    │
│                            └────────────────┘                    │
│                                                                     │
│  ┌──────────┐    Platform     ┌──────────────────┐               │
│  │ Android  │ ◀───────────── │ FocusShieldSvc   │               │
│  │ Native   │                │ (DND Foreground)  │               │
│  │ (Kotlin) │ ──────────────▶ │                  │               │
│  └──────────┘   MethodChannel └──────────────────┘               │
│                                                                     │
│  ┌──────────────────┐    15-min     ┌──────────────────┐         │
│  │ Workmanager Isolate│ ◀────────── │ SyncWorkerService│         │
│  │  (Background)      │             │  (Orchestrator)  │         │
│  └─────────┬──────────┘             └────────┬─────────┘         │
│            │                                 │                    │
│            │         ┌───────────────────────▼───────────┐       │
│            │         │         SyncService (singleton)    │       │
│            │         │  enqueueLocalChange / retryPending │       │
│            │         └───────────────────┬───────────────┘       │
│            │                             │                        │
│            │                             ▼                        │
│            │                    ┌─────────────────┐             │
│            │                    │   Firestore     │             │
│            │                    │  sync_outbox    │             │
│            │                    │  sync_tombstones│             │
│            │                    │  sync_conflicts │             │
│            │                    └────────┬────────┘             │
│            │                             │                        │
│            │                             ▼                        │
│            │                    ┌─────────────────┐             │
│            │                    │ Cloud Functions │             │
│            │                    │ syncWorker      │             │
│            │                    │ pruneTombstones │             │
│            │                    │ aiProxy         │             │
│            │                    │ ocrProcess      │             │
│            │                    └─────────────────┘             │
│            │                                                │     │
│  ┌─────────▼──────────┐                                    │     │
│  │ OfflineQueueService│ ─ SharedPreferences (JSON)        │     │
│  │  (max 3 retries)   │                                    │     │
│  └────────────────────┘                                    │     │
│                                                             ▼     │
│                                                    ┌────────────────┐│
│                                                    │ Firebase Storage││
│                                                    │ ai-uploads/    ││
│                                                    │ ocr-output/    ││
│                                                    └────────────────┘│
└─────────────────────────────────────────────────────────────────────┘
```

## Appendix B: SM-2 Algorithm Pseudocode

```
FUNCTION _sm2Schedule(quality, currentEaseFactor, currentInterval, currentRepetitions):
  newEaseFactor = max(1.3, currentEaseFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02)))
  IF quality >= 3:
    newRepetitions = currentRepetitions + 1
  ELSE:
    newRepetitions = 0
  IF newRepetitions == 0: newInterval = 1
  ELSE IF newRepetitions == 1: newInterval = 6
  ELSE IF newRepetitions == 2: newInterval = 6
  ELSE: newInterval = clamp(round(currentInterval * newEaseFactor), 1, 365)
  dueAt = now + newInterval days
  RETURN { easeFactor: newEaseFactor, intervalDays: newInterval,
           repetitions: newRepetitions, dueAt, lastReviewAt: now }
```

## Appendix C: Firestore Security Rule Pseudocode

```
FUNCTION isOwner(userId):
  RETURN request.auth != null AND request.auth.uid == userId

MATCH /sync_outbox/{outboxId}:
  ALLOW read, write: IF isAuthenticated() AND resource.data.userId == request.auth.uid
  ALLOW create: IF isAuthenticated() AND request.resource.data.userId == request.auth.uid

MATCH /sync_tombstones/{tombstoneId}:
  ALLOW read, write: IF isAuthenticated() AND resource.data.userId == request.auth.uid
  ALLOW create: IF isAuthenticated() AND request.resource.data.userId == request.auth.uid

MATCH /quizzes/{quizId}:
  ALLOW read: IF isAuthenticated()
  ALLOW create: IF isAuthenticated() AND request.resource.data.ownerId == request.auth.uid
  ALLOW update, delete: IF isAuthenticated() AND resource.data.ownerId == request.auth.uid
```

---

*End of White Paper*  
*Retainly v1.0 | CodeSym | Apache 2.0*
