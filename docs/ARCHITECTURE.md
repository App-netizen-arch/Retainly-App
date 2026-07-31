# Architecture

Retainly is a Flutter-based, offline-first study planner for Pakistani Matric
(Class 9–10) students. The application targets Android (primary) and Linux
desktop, with optional Firebase-backed cloud features. This document describes
the high-level design, component layout, concurrency model, and error handling
strategies for contributors and code auditors.

---

## High-Level Design Principles

### 1. Offline-first with graceful degradation

All core study-planning data (subjects, chapters, tasks, focus sessions,
revision items, resources, practical records) is stored in a local SQLite
database. Firebase-dependent features (cloud sync, AI assistance, OCR) are
strictly optional. If Firebase fails to initialize — due to missing
configuration, no network, or unsupported platform — the app falls back to
**local-only mode** and all core functionality remains available.

This is enforced at the service layer. Each Firebase-dependent service
(`SyncService`, `AIService`, `AnalyticsService`, `CrashlyticsService`,
`RemoteConfigService`) holds a nullable reference to its Firebase SDK
object. Every public method begins with a guard that returns a safe default
(`false`, `0`, `[]`, `null`) when the Firebase reference is `null`. This
invariant — **no Firebase dependency may crash the app** — is codified in
`lib/services/` and verified by tests in `test/unit/sync_service_test.dart`.

### 2. Single source of truth: local database

The local SQLite database is the **authoritative source of truth** for all
study data. The `DatabaseRepository`
(`lib/data/repositories/database_repository.dart`) is the sole intermediary
between the UI layer and the database. All mutations flow through this
repository, which also records a corresponding entry in the `sync_meta`
table (the local outbox metadata) via the private `_trackChange()` method.
This ensures every local write is marked for eventual cloud synchronization
without the caller needing to know about the sync plumbing.

### 3. Domain-driven modular layout

The codebase follows a feature-first, layered architecture:

```
lib/
├── core/          # Cross-cutting concerns: constants, theme, feature flags, utilities
├── data/          # Data layer: models, database helpers, repositories
├── services/      # Application services: sync, AI, analytics, connectivity, focus
├── features/      # Feature modules (each with presentation + domain/data layers)
│   ├── ai/        # AI assistance, OCR scan, hallucination reports
│   ├── backup/    # Local encrypted backup/restore
│   ├── focus/     # Pomodoro-style focus sessions with DND
│   ├── planner/   # Daily plan generation and rescheduling
│   ├── revision/  # Spaced repetition queue
│   ├── resources/ # PDF viewer, practical records
│   └── ...
├── navigation/   # GoRouter configuration
├── providers/    # Riverpod providers (state management + DI)
└── l10n/         # Generated localization delegates
```

Each feature module in `lib/features/` that has non-trivial business logic
follows a **domain/data/presentation** split. For example, the backup feature
separates:

- `domain/models/` — Immutable `@immutable` data classes (`BackupRecord`,
  `BackupSettings`, `RestoreResult`, `RestoreConflict`)
- `domain/repositories/` — Abstract interfaces (`BackupRepository`,
  `BackupEncryptionService`, `BackupStorageservice`, `BackupScheduler`,
  `RestoreService`)
- `data/repositories/` — Concrete implementations (`LocalBackupRepository`,
  `LocalBackupEncryptionService`, `LocalBackupStorageService`,
  `LocalRestoreService`)
- `application/` — Coordination layer (`BackupManager`) that composes the
  repositories into higher-level workflows
- `presentation/` — UI screens

This separation allows the data-access contracts to be mocked in tests
without touching UI code, and allows alternative implementations (e.g., a
cloud-based backup service) to be added by implementing the same interfaces.

### 4. State machine: user onboarding flow

The navigation layer (`lib/navigation/app_router.dart`) implements a
**two-stage gate** state machine:

1. **Database readiness**: The `dbFutureProvider` resolves the `DatabaseHelper`
   singleton. While it is loading, the router returns `null` (no redirect).
2. **Profile existence**: Once the database is ready, the
   `userProfileProvider` resolves. If no profile exists, the router
   redirects to `/onboarding`. If a profile exists, normal navigation
   proceeds.

This is implemented via `_RouterRefreshNotifier`, which listens to both
providers and notifies GoRouter to re-evaluate the redirect logic whenever
either changes. The onboarding screen writes a `UserModel` to the
`user_profiles` table, which causes `userProfileProvider` to resolve to a
non-null value, clearing the redirect.

### 5. State machine: focus session lifecycle

The `FocusScreen` (`lib/features/focus/focus_screen.dart`) implements a
focus-session state machine with three canonical states:

- **idle**: No active session; a new session can be started.
- **running**: A `FocusSessionModel` with `status: 'running'` exists in the
  `focus_sessions` table. The timer is active, and the Focus Shield (DND
  mode) is enabled on Android.
- **completed** (break or session end): The session is saved via
  `DatabaseRepository.insertFocusSession()` / `updateFocusSession()`, the
  timer is disposed, and the Focus Shield is disabled.

On `dispose()`, if a session is still running, `_saveSession()` persists the
in-progress session to prevent data loss on app exit. The Android platform
channel (`focus_shield`) toggles Do Not Disturb via
`NotificationManager.setInterruptionFilter(INTERRUPTION_FILTER_NONE)`,
guarded by a `FOREGROUND_SERVICE` (`FocusShieldForegroundService`).

---

## Component Breakdown

### Data Layer

#### 2.1 Local SQLite Database (sqflite)

**File**: `lib/data/database_helper.dart`

`DatabaseHelper` is a singleton that manages a single `sqflite.Database`
connection. It lazily initializes the database on first access and caches
the open `Database` instance. The database file is stored at
`getApplicationDocumentsDirectory()/study_planner.db`.

On creation (`_createDB`), 11 tables are defined with explicit column
definitions and foreign-key constraints with `ON DELETE CASCADE`. On
subsequent opens, `_extendSchema()` runs a **backward-compatible migration**
that uses `PRAGMA table_info()` to detect which columns already exist and
only adds missing ones via `ALTER TABLE`. This ensures upgrades never destroy
user data.

The `DatabaseHelper` exposes a raw `Database` object. Higher-level callers
should use `DatabaseRepository` instead, which wraps the raw queries and
provides model-based typed accessors (`getTodayTasks()`, `getTasksForDate()`,
`getSubjectProgress()`, etc.).

#### 2.2 Drift Database (drift)

**Files**: `lib/data/drift/app_database.dart`, `lib/data/drift/database_provider.dart`

A **Drift** (Dart-only ORM) layer is optionally initialized on Android
platforms. It defines the same schema as the raw SQLite tables but provides
type-safe DAO access with auto-incrementing IDs, references, and a
`MigrationStrategy` with `schemaVersion: 3`.

The `DatabaseProvider` singleton (`lib/data/drift/database_provider.dart`)
initializes `AppDatabase` only on Android (`Platform.isAndroid`), using
`NativeDatabase.createInBackground()` to avoid blocking the UI thread.
On non-Android platforms, `driftDb` is `null`, and `DatabaseRepository`
falls back to the raw `sqflite` path. The `_useDrift` flag in
`DatabaseRepository` selects between the two at runtime per operation.

The Drift schema and the raw SQLite schema are kept in sync manually — both
must be updated when adding columns or tables. The Drift `MigrationStrategy`
handles version upgrades via `onUpgrade` callbacks.

#### 2.3 Data Models

**File**: `lib/data/models/app_models.dart`

Plain Dart data classes (`UserModel`, `SubjectModel`, `ChapterModel`,
`TaskModel`, `FocusSessionModel`, `RevisionItemModel`, `ResourceModel`,
`PracticalRecordModel`, `SubjectProgressModel`, `ChapterWithSubjectModel`,
`SyllabusTemplateModel`). Each model provides:

- `toMap()` — serializes to a `Map<String, dynamic>` for SQLite insertion
- `fromMap()` — deserializes from a database row, with defensive type checks
  (`map['field'] is String ? map['field'] as String : fallback`) to handle
  partial or legacy data gracefully.

These models are **not** Drift companions; they serve the raw `sqflite`
path and the backup/restore JSON serialization. The Drift layer uses
`XCompanion.insert()` constructors (e.g., `SubjectsCompanion.insert()`)
which are generated in `app_database.g.dart`.

#### 2.4 Firestore Sync Layer

**File**: `lib/data/firestore/firestore_models.dart`

Three Firestore-specific model classes represent the cloud sync metadata:

- `FirestoreSyncOutbox` — Documents in the `sync_outbox` collection; each
  represents a pending local mutation (create/update/delete) awaiting cloud
  application.
- `FirestoreTombstone` — Documents in the `sync_tombstones` collection;
  soft-delete markers that prevent resurrected data during concurrent sync.
- `FirestoreConflict` — Documents in the `sync_conflicts` collection;
  recorded when local and remote versions diverge and can't be auto-resolved.

These models are separate from the local SQLite models because Firestore
uses String IDs while SQLite uses integer IDs, and Firestore documents
include `Timestamp` rather than ISO-8601 strings.

#### 2.5 DatabaseRepository

**File**: `lib/data/repositories/database_repository.dart`

The central data-access facade. It wraps `DatabaseHelper` (sqflite) or
`AppDatabase` (Drift) and provides:

- CRUD operations for all entity types
- The **SM-2 spaced repetition algorithm** for revision scheduling
  (`_sm2Schedule()`, `_sm2NewEaseFactor()`, `_sm2NewInterval()`) — implemented
  per the SuperMemo-2 model: ease factor adjusts by `(5 - quality)`
  with a minimum of 1.3, intervals follow 1→6→6→exponential progression
- Analytics query methods (`getRecallTrends()`, `getSubjectConfidenceDecay()`,
  `getTaskEstimateAccuracy()`, `getProductiveTimeInsights()`,
  `getMissedDayPatterns()`, `getSubjectEstimateAccuracy()`)
- The `computeTaskScore()` scoring function that ranks tasks by urgency
  (due date proximity × 1, priority × 10, fit-to-budget bonus × 5)
- The sync outbox tracker (`_trackChange()`) which inserts a row into the
  `sync_meta` table on every write, marking it `sync_status: 'pending'`

---

### Service Layer

#### 3.1 SyncService

**File**: `lib/services/sync_service.dart`

A singleton that bridges local changes to Firestore. It is the **client-side**
half of the sync pipeline:

- `enqueueLocalChange()` — Writes a `sync_outbox` document to Firestore with
  `userId`, `entity`, `entityId`, `operation`, `data`, and `synced: false`.
  This does NOT apply the change directly to the target collection; instead,
  the Cloud Function `syncWorker` processes the outbox.
- `markEntityDeleted()` — Writes a `sync_tombstones` document.
- `retryPending()` — Reads unsynced outbox items client-side and applies
  them to the target Firestore collections. This is a fallback path used
  when the Cloud Function is unavailable.
- Conflict tracking and tombstone pruning are also exposed.

The singleton pattern (`factory SyncService() => _instance`) ensures a single
Firestore instance reference across the app, consistent with the singleton
pattern used by all service classes.

#### 3.2 OfflineQueueService

**File**: `lib/services/offline_queue_service.dart`

A client-side queue persisted in `SharedPreferences` (as a JSON string under
the key `offline_queue`). It holds `QueuedOperation` objects with a type
(`sync`, `ai`, `tombstone`), payload, attempt count, and timestamps. The
queue is processed by `processQueue()`, which attempts each operation,
increments the attempt counter on failure, and drops items that exceed
`_maxAttempts` (3). A `StreamController<void>.broadcast()` notifies
listeners of queue changes.

This is distinct from the Firestore `sync_outbox`: the `OfflineQueueService`
is for operations that fail because the device is offline, while the Firestore
outbox is for eventual cloud consistency. The `SyncWorkerService` calls
`OfflineQueueService.processQueue()` which in turn calls
`SyncService.enqueueLocalChange()`.

#### 3.3 SyncWorkerService

**File**: `lib/services/sync_worker_service.dart`

Orchestrates background sync via the `workmanager` package. It registers a
periodic task (`sync_worker_process_queue`) with a 15-minute frequency and
`NetworkType.connected` constraint. Three task types are dispatched:

- `_taskProcessQueue` — Processes the offline queue
- `_taskRetryPending` — Retries pending Firestore outbox items
- `_taskForceSync` — Full sync: queue processing + retry + tombstone pruning

The worker runs in a **separate process** (`syncWorkerDispatcher` is a
`@pragma('vm:entry-point')` function that initializes Firebase independently
from the app's main isolate). An `_isRunning` flag provides basic
single-execution guarding; the state machine transitions through
`SyncWorkerState.idle → syncing → idle/error`.

#### 3.4 AIService

**File**: `lib/services/ai_service.dart`

The client-side gateway for AI-powered features. It calls Firebase Cloud
Functions via `httpsCallable('aiProxy')` and `httpsCallable('ocrProcess')`.
The service enforces:

- **Consent checks**: `hasAiConsent()` and `hasOcrConsent()` gate access.
  Consent is stored locally in `SharedPreferences` and mirrored to the
  `ai_consents/{userId}` Firestore document.
- **Cost warning acceptance**: `hasAcceptedCostWarning()` must be `true`.
- **Daily quota**: 50 requests per user per day, tracked both client-side
  (SharedPreferences with date-rollover reset) and server-side (the Cloud
  Function rejects requests when `ai_requests` count >= 50).
- **Connectivity check**: Every AI/OCR request is gated by
  `ConnectivityService.isOnline`.
- **Offline fallback**: If Firebase Functions are unavailable, returns a
  localizable message string (`'AI is unavailable in local-only mode.'`).

AI prompts include a detailed system prompt embedded in the client that
enforces pedagogical rules, draft-only output, source grounding, and
academic-integrity guardrails.

#### 3.5 ConnectivityService

**File**: `lib/services/connectivity_service.dart`

A singleton wrapping `connectivity_plus`. Provides `isOnline` (a
`Future<bool>`) and `onConnectivityChanged` (a `Stream<bool>`). The stream
is consumed by `AppShell` to show an offline banner at the top of the screen.

#### 3.6 AnalyticsService, CrashlyticsService, RemoteConfigService

**Files**: `lib/services/{analytics,crashlytics,remote_config}_service.dart`

- **AnalyticsService**: Wraps `FirebaseAnalytics`; all methods are guarded
  by `_initialized`. Logs events with arbitrary parameters and sets user
  properties.
- **CrashlyticsService**: Wraps `FirebaseCrashlytics`; `recordError()` is
  wired to `FlutterError.onError` in `main()` to capture all Flutter
  framework errors. Uses `recordError()` (not `recordFlutterError()`) for
  manual reporting.
- **RemoteConfigService**: Wraps `FirebaseRemoteConfig`; defines default
  values for `sync_interval_minutes`, `ai_quota_daily`, etc. Falls back to
  defaults if Remote Config is unavailable.

All three follow the same **try/catch initialization** pattern and degrade
silently when Firebase is unavailable.

#### 3.7 ShortcutService

**File**: `lib/services/shortcut_service.dart`

Uses a `MethodChannel('app_shortcuts')` to interface with the Android
app-shortcut API. On app launch, it checks whether the "focus" shortcut was
tapped (via a launch intent) and navigates to `/focus` if so. All calls are
wrapped in `Platform.isIOS` checks and `PlatformException` handlers.

---

### Feature Layer

#### 4.1 Navigation (GoRouter)

**Files**: `lib/navigation/app_router.dart`, `lib/navigation/app_shell.dart`

GoRouter defines two navigation contexts:

1. **ShellRoute** (`/`, `/planner`, `/subjects/:id`, `/subjects/setup`,
   `/settings`, `/backup`, `/onboarding`) — These routes render inside
   `AppShell`, which provides the bottom `NavigationBar` and connectivity
   banner. The shell uses the current URI path to determine the selected
   navigation index.

2. **Top-level GoRoutes** (`/focus`, `/revision`, `/resources`, `/ocr`,
   `/ai/hallucination-reports`, `/pdf`, `/progress`, `/tasks/add`,
   `/search`, `/practicals`, `/reschedule`, `/legal/:documentKey`) —
   These are modal/full-screen routes outside the shell.

The redirect logic gates on database readiness and profile existence,
implementing the onboarding state machine described above.

#### 4.2 Focus Feature

**File**: `lib/features/focus/focus_screen.dart`

A Pomodoro timer with configurable work/break durations. Communicates with
the Android native layer via `MethodChannel('focus_shield')` to:

- Check DND access (`isFocusShieldAvailable`)
- Toggle DND mode (`toggleFocusShield` with `enable` argument)
- Open Android DND settings (`openDndSettings`)

The native implementation is in
`android/app/src/main/kotlin/com/codesym/retainly/MainActivity.kt`,
which uses `NotificationManager.setInterruptionFilter()` to toggle
`INTERRUPTION_FILTER_NONE` (blocking all notifications) and
`INTERRUPTION_FILTER_ALL` (restoring normal behavior). A foreground service
(`FocusShieldForegroundService`) keeps the DND session alive.

#### 4.3 Planner Feature

**File**: `lib/features/planner/planner_screen.dart`

Generates a daily study plan by selecting tasks from `getAllPendingTasks()`
that fit within the user's `dailyStudyMinutes` budget. Tasks are scored via
`DatabaseRepository.computeTaskScore()` and sorted descending. The plan is
a greedy knapsack fill: tasks are added in score order until the daily
minute budget is exhausted. Overflow tasks are surfaced for manual
rescheduling. The RescheduleScreen allows moving tasks to different dates.

#### 4.4 Revision Feature (Spaced Repetition)

**File**: `lib/features/revision/revision_screen.dart`

Displays due revisions from `db.getDueRevisions()` (items where
`due_at <= now`). When a user submits feedback on a revision item,
`DatabaseRepository.recordRevisionFeedback()` applies the SM-2 algorithm:

1. Converts the user's 0–100 confidence rating to a 0–5 quality score
   (`_confidenceToSm2Quality()`)
2. Computes a new ease factor, interval, and repetition count
3. Schedules the next review at `now + interval_days`
4. Adjusts linked task estimates based on the confidence ratio

Revision intervals follow the 1/3/7-day spaced-repetition pattern described
in the README, with intervals adaptively adjusted via SM-2.

#### 4.5 Backup Feature

**Files**: `lib/features/backup/` (full domain/data/presentation split)

The backup system produces a single JSON blob containing all study data and
SharedPreferences keys, serialized, then encrypted with **AES-256**
(via the `encrypt` package). The encryption key is a 32-byte
`Key.fromSecureRandom(32)` stored in:

- **Android/iOS/macOS**: `FlutterSecureStorage` (platform Keystore/Keychain)
- **Linux/Windows**: `SharedPreferences` (plain, as a fallback)

The encrypted file is written with a magic header `MSP_BACKUP_V1` followed
by a 16-byte IV and the AES ciphertext. Backups are stored in the app's
documents directory under `backups/`. The `BackupManager.autoBackup()`
method respects user-configured frequency (daily/weekly/monthly) and is
off by default. Restores validate the schema version (must equal `_schemaVersion = 2`)
and required fields before importing.

#### 4.6 AI Feature

**Files**: `lib/features/ai/`

Three AI-powered screens:

- `ocr_scan_screen.dart` — Uploads PDFs to Firebase Storage (`ai-uploads/{userId}/`),
  triggers the `ocrProcess` Cloud Function (which calls Google Vision API),
  and polls for results.
- `quiz_screen.dart` — Generates MCQs via the `aiProxy` Cloud Function.
- `flashcard_screen.dart` — Generates flashcards via `aiProxy`.
- `hallucination_reports_screen.dart` — Displays locally-stored hallucination
  reports (stored in SharedPreferences as a JSON array).

All AI features require explicit opt-in consent (`hasAiConsent()` +
`hasAcceptedCostWarning()`) and enforce the daily quota.

---

### Cloud Layer (Firebase)

#### 5.1 Cloud Functions

**File**: `functions/src/index.ts`

Four callable/scheduled functions:

| Function | Type | Trigger | Purpose |
|---|---|---|---|
| `aiProxy` | HTTPS Callable | `https.onCall` | Proxies AI requests to OpenAI/Anthropic/Gemini with consent + quota checks |
| `ocrProcess` | HTTPS Callable | `https.onCall` | Enqueues OCR jobs via Google Vision API with duplicate suppression |
| `syncWorker` | Scheduled | `pubsub.schedule('every 15 minutes')` | Processes Firestore sync_outbox, applying mutations to target collections |
| `pruneTombstones` | Scheduled | `pubsub.schedule('every 24 hours')` | Deletes sync_tombstones older than 30 days |

The `aiProxy` function:
1. Validates that the caller is authenticated (`context.auth.uid`)
2. Checks the `ai_consents/{userId}` document for consent flags
3. Enforces a daily quota of 50 requests by querying `ai_requests` for the
   current day
4. Records each request in `ai_requests` (with a 2000-char prompt truncate)
5. Resolves the provider and model, then calls the appropriate AI SDK
6. Validates the response is non-empty and ≤ 4000 characters
7. Returns `{ requestId, provider, model, output, notice }`

The `ocrProcess` function:
1. Validates authentication and OCR consent
2. Performs duplicate detection: queries `ocr_jobs` for matching `userId` +
   `filePath` with status `queued`/`processing` within the last hour
3. Creates an `ocr_jobs` document, then invokes
   `ImageAnnotatorClient.asyncBatchAnnotateFiles()` for PDF document text
   detection
4. Returns the job ID for client-side polling

#### 5.2 Firestore Security Rules

**File**: `firestore.rules`

The rules implement a **strict ownership model**:

- All user-scoped collections require `request.auth.uid` to match the
  document's `userId` or document ID
- `sync_outbox`, `sync_tombstones`, `sync_conflicts` enforce ownership via
  the `userId` field in the document data
- `ai_consents` is not explicitly listed in the rules but is accessed only
  via the `aiProxy` Cloud Function (which checks `context.auth.uid`), so the
  rules don't need to govern client access
- `ai_requests`, `ocr_jobs`, `ai_hallucination_reports` are accessed only
  server-side; client reads to `ocr_jobs` include an ownership check in the
  `AIService.getOcrResult()` method
- `quizzes` and `quiz_attempts` enforce owner-based access

#### 5.3 Cloud Storage Rules

**File**: `storage.rules`

Storage paths are owner-scoped:
- `users/{userId}/{allPaths=**}` — full read/write for the owner only
- `ai-uploads/{userId}/{allPaths=**}` — full read/write for the owner only
- `ocr-output/{userId}/{allPaths=**}` — full read/write for the owner only
- `study-groups/{groupId}/{allPaths=**}` — read-only for authenticated users (no writes)

---

## Concurrency & Synchronization Model

### 6.1 Dart Isolates and Async

The Flutter app runs in a single Dart isolate (with a UI thread and an
event-loop). All database operations are `async` and run on the event loop,
not on separate threads. The Drift layer uses
`NativeDatabase.createInBackground()` to offload SQLite I/O to a background
isolate, but the sqflite path runs queries on the calling isolate's event
loop. Long-running operations (backup encryption, file I/O) are `async` but
not multi-threaded — they yield to the event loop at `await` points.

The `workmanager` package spawns a **separate Dart isolate** for background
sync tasks, running the `syncWorkerDispatcher` entry point. This isolate
initializes its own `Firebase.initializeApp()` instance, independent of the
app's main isolate.

### 6.2 Synchronization: Offline-First Sync Pipeline

The sync architecture is a **two-stage pipeline**:

**Stage 1 — Local change capture**: When the app writes to the local SQLite
database, `DatabaseRepository._trackChange()` inserts a record into the
`sync_meta` table with `sync_status: 'pending'`. This is the authoritative
local ledger of unsynced changes.

**Stage 2 — Cloud application**: Two mechanisms apply local changes to the
cloud:

1. **Client-side retry** (`SyncService.retryPending()`): Reads the Firestore
   `sync_outbox` collection (NOT the local `sync_meta` table — the outbox is
   written by `SyncService.enqueueLocalChange()` when online) and applies
   each `create`/`update`/`delete` operation to the target collection.
   Failures are written back as an `error` field on the outbox document.

2. **Server-side Cloud Function** (`syncWorker`): A scheduled function
   (every 15 minutes) that reads `sync_outbox` documents with `synced: false`,
   applies the mutation to the target collection, and marks the document
   `synced: true`.

The local `OfflineQueueService` bridges the gap: when offline, changes are
queued in SharedPreferences. When connectivity is restored, the queue is
processed, which calls `SyncService.enqueueLocalChange()` to write to the
Firestore outbox. The Workmanager periodic task handles this automatically
every 15 minutes.

### 6.3 Conflict Resolution

Conflicts are handled via a **tombstone + conflict document** pattern:

- When a local delete occurs, a `sync_tombstones` document is written with
  `deletedAt` timestamp. The Cloud Function applies the delete to Firestore.
- Tombstones are retained for 30 days (pruned by `pruneTombstones` /
  `SyncService.pruneTombstones()`) to prevent **resurrection attacks** where
  a stale create from one device reappears after a delete on another.
- When a local write conflicts with a remote change, the `SyncService`
  records a `sync_conflicts` document with both `localData` and `remoteData`.
  The conflict is surfaced to the user via the sync status UI; the user
  resolves it manually via `clearConflict()` or `markEntityConflict()`.
- The Conflict type is last-write-wins for non-delete operations during
  `retryPending()`: the function overwrites the remote document with the
  local payload. True merge semantics are not implemented; users must
  manually resolve detected conflicts.

### 6.4 Locking and Thread Safety

- `DatabaseHelper` uses a **double-checked locking** pattern: `_database` is
  a cached field, and `_databaseOpening` is a cached `Future<Database>` that
  prevents concurrent initialization. Once set, `_database` is returned
  synchronously.
- `SyncWorkerService` uses an `_isRunning` boolean flag as a coarse
  re-entrancy guard — if a sync cycle is already in progress, subsequent
  calls to `processQueue()`, `retryPending()`, or `forceSync()` return
  immediately.
- All singleton services (`SyncService`, `OfflineQueueService`,
  `SyncWorkerService`, `ConnectivityService`, etc.) use the
  `factory X() => _instance` pattern with a private named constructor.

### 6.5 Background Tasks

- **Workmanager**: Registers `sync_worker_periodic` (15-minute frequency,
  `NetworkType.connected` constraint, linear backoff starting at 5 minutes).
- **Local notifications**: `LocalBackupScheduler` uses
  `flutter_local_notifications` to show backup-due reminders. Notification
  initialization is guarded with try/catch as it may fail on some platforms.
- **Foreground service**: `FocusShieldForegroundService` on Android keeps
  the DND session active without being killed by the system.

---

## Error Handling & Failure Modes

### 7.1 Dart-side Error Handling

#### FirebaseError swallowing

All Firebase-dependent services catch `FirebaseException` silently. This is
an intentional design choice: Firebase is an optional enhancement, and
network/permission/auth errors should never crash the local-only experience.
The pattern is:

```dart
try {
  await _firestore!.collection('sync_outbox').add({...});
} on FirebaseException catch (_) {}
```

This means that sync failures are **silent** from the user's perspective —
the `SyncWorkerService` tracks `_lastError` and `_state`, but the UI only
surfaces sync status as a count (`syncStatusProvider` returns
`pendingOutbox`, `pendingConflicts`, `prunedTombstones`).

#### Defensive type checking in models

All `fromMap()` constructors in `app_models.dart` use defensive type checks:

```dart
studentName: map['student_name'] is String
    ? map['student_name'] as String
    : '',
```

This protects against:
- Partial/legacy database rows from older schema versions
- Malformed data from backup imports
- Type coercion issues between sqflite and Drift

#### FlutterError.onError

In `main()`, `FlutterError.onError` is set to:
1. Dump the error to the console
2. Report it to Crashlytics via `CrashlyticsService.instance.recordError()`

This captures all Flutter framework rendering errors, widget build failures,
and unhandled exceptions in the UI thread.

### 7.2 Cloud Function Error Handling

#### aiProxy

- Throws `HttpsError('unauthenticated')` if no auth context
- Throws `HttpsError('permission-denied')` if consent is missing
- Throws `HttpsError('resource-exhausted')` if daily quota exceeded
- Throws `HttpsError('invalid-argument')` for missing/empty prompt or
  empty/too-long AI response
- Catches AI API errors and returns them as a string in `output` (not thrown)
  — the client displays this as a user-facing message

#### syncWorker

- Each outbox item is processed in a try/catch. On failure, the error is
  written to the document's `error` field — the function does NOT throw,
  so one failed item doesn't block subsequent items.
- The function returns `null` (not `void`) as required by the Firebase
  Functions v2 API.

#### ocrProcess

- Validates that `filePath` starts with `gs://` (Cloud Storage URI)
- Duplicate jobs are suppressed (early return, not error)
- On Vision API failure, the `ocr_jobs` document is updated to
  `status: 'failed'` with the error message, and an `HttpsError('internal')`
  is thrown with the job ID as metadata

### 7.3 Restore/Import Failure Modes

`LocalRestoreService.restoreFromFile()` handles failures through a
multi-layered validation:

1. **File existence**: `FileSystemException` → returns
   `RestoreResult(success: false, ...)`
2. **Empty file**: `FormatException('Backup file is empty...')`
3. **Decryption failure**: `FormatException` from the encryption service
4. **Invalid JSON**: `FormatException`
5. **Missing required fields**: `FormatException` with field name
6. **Schema version mismatch**: Returns `RestoreResult` with
   `conflictsEncountered: 1` (non-throwing)

Each failure mode is tested in `test/unit/backup_restore_test.dart`.

### 7.4 Backup Encryption Failure Modes

`LocalBackupEncryptionService`:

- If secure storage is unavailable, falls back to `SharedPreferences`
- If key storage fails entirely, the encryption key exists only in memory
  for the current session (best-effort)
- `decryptData()` throws `FormatException` for truncated or malformed data
  (magic header mismatch, insufficient length)
- AES with ECB-like single-block IV (each encryption generates a fresh
  random IV; the encrypt package uses AES-CBC under the hood)

### 7.5 Platform-specific failure modes

- **Android DND**: `setFocusShield()` returns `false` if the user hasn't
  granted `ACCESS_NOTIFICATION_POLICY` permission. The app shows a dialog
  directing the user to the system settings via `openDndSettings()`.
- **Desktop (Linux)**: `FlutterSecureStorage` is unavailable, so encryption
  keys fall back to `SharedPreferences` (plaintext). The Drift database is
  not initialized (only sqflite is used).
- **Web**: Explicitly unsupported. The `firebase_options.dart` throws
  `UnsupportedError` for web platforms.

---

## Key Data Flow Pathways

### Pathway A: Local write → sync to cloud

```
1. UI calls DatabaseRepository.insertSubject()
   → DatabaseHelper.insertSubject() writes to SQLite
   → DatabaseRepository._trackChange() writes sync_meta row (status: pending)

2. If online:
   → SyncService.enqueueLocalChange() writes Firestore sync_outbox doc (synced: false)

3. Cloud Function (syncWorker, every 15 min) or client retry (SyncService.retryPending):
   → Reads sync_outbox where synced == false
   → Applies create/update/delete to target collection
   → Marks outbox doc synced: true

4. If offline (OfflineQueueService):
   → Enqueue to SharedPreferences queue
   → Workmanager (15 min, network connected) processes queue
   → SyncService.enqueueLocalChange() writes to Firestore outbox
```

### Pathway B: AI request (client → function → AI provider → client)

```
1. UI calls AIService.generateTaskBreakdown()
   → Checks consent, cost warning, quota, connectivity
   → Returns error string if any gate fails (no exception)

2. If passed:
   → Calls FirebaseFunctions.httpsCallable('aiProxy')
   → Function checks auth, consent, quota
   → Resolves provider/model, calls OpenAI/Anthropic/Gemini SDK
   → Records request in ai_requests collection
   → Returns { output, provider, model, requestId, notice }

3. Client:
   → Records local quota usage (SharedPreferences)
   → Estimates cost, updates local cost counter
   → Returns output string to UI
```

### Pathway C: Backup creation

```
1. BackupManager.createBackup()
   → DatabaseRepository collects all entities
   → LocalBackupRepository._collectBackupData() serializes to JSON
   → LocalBackupEncryptionService.encryptData() applies AES-256
   → LocalBackupStorageService writes to documents/backups/
   → DatabaseHelper.insertBackupRecord() records metadata
```
