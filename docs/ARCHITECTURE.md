# Architecture

Retainly is a Flutter-based, offline-first study planner for Pakistani Matric
(Class 9–10) students. The application targets Android (primary) and Linux
desktop, with optional online features. This document describes
the high-level design, component layout, concurrency model, and error handling
strategies for contributors and code auditors.

---

## High-Level Design Principles

### 1. Offline-first with graceful degradation

All core study-planning data (subjects, chapters, tasks, focus sessions,
revision items, resources, practical records) is stored in a local SQLite
database. Optional online features (AI assistance, OCR) are available when
configured. If network access fails — due to missing configuration, no network,
or unsupported platform — the app falls back to **local-only mode** and all
core functionality remains available.

### 2. Single source of truth: local database

The local SQLite database is the **authoritative source of truth** for all
study data. The `DatabaseRepository`
(`lib/data/repositories/database_repository.dart`) is the sole intermediary
between the UI layer and the database. All mutations flow through this
repository.

### 3. Domain-driven modular layout

The codebase follows a feature-first, layered architecture:

```
lib/
├── core/          # Cross-cutting concerns: constants, theme, feature flags, utilities
├── data/          # Data layer: models, database helpers, repositories
├── services/      # Application services: AI, connectivity, focus
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
path and the backup/restore JSON serialization.

#### 2.4 DatabaseRepository

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

---

### Service Layer

#### 3.1 OfflineQueueService

**File**: `lib/services/offline_queue_service.dart`

A client-side queue persisted in `SharedPreferences` (as a JSON string under
the key `offline_queue`). It holds `QueuedOperation` objects with a type
(`sync`, `ai`, `tombstone`), payload, attempt count, and timestamps. The
queue is processed by `processQueue()`, which attempts each operation,
increments the attempt counter on failure, and drops items that exceed
`_maxAttempts` (3). A `StreamController<void>.broadcast()` notifies
listeners of queue changes.

#### 3.2 AIService

**File**: `lib/services/ai_service.dart`

The client-side gateway for AI-powered features. It calls external AI APIs
directly. The service enforces:

- **Consent checks**: `hasAiConsent()` and `hasOcrConsent()` gate access.
   Consent is stored locally in `SharedPreferences`.
- **Cost warning acceptance**: `hasAcceptedCostWarning()` must be `true`.
- **Daily quota**: 50 requests per user per day, tracked client-side
   (SharedPreferences with date-rollover reset).
- **Connectivity check**: Every AI/OCR request is gated by
   `ConnectivityService.isOnline`.
- **Offline fallback**: If the external API is unavailable, returns a
   localizable message string.

AI prompts include a detailed system prompt embedded in the client that
enforces pedagogical rules, draft-only output, source grounding, and
academic-integrity guardrails.

#### 3.4 ConnectivityService

**File**: `lib/services/connectivity_service.dart`

A singleton wrapping `connectivity_plus`. Provides `isOnline` (a
`Future<bool>`) and `onConnectivityChanged` (a `Stream<bool>`). The stream
is consumed by `AppShell` to show an offline banner at the top of the screen.

#### 3.5 ShortcutService

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

- `ocr_scan_screen.dart` — Uploads PDFs for OCR processing via external API,
   and polls for results.
- `quiz_screen.dart` — Generates MCQs via the external AI API.
- `flashcard_screen.dart` — Generates flashcards via external AI API.
- `hallucination_reports_screen.dart` — Displays locally-stored hallucination
  reports (stored in SharedPreferences as a JSON array).

All AI features require explicit opt-in consent (`hasAiConsent()` +
`hasAcceptedCostWarning()`) and enforce the daily quota.

---

### Optional Online Features

#### 5.1 External AI APIs

The app can call external AI providers (OpenAI, Anthropic, Gemini, OpenRouter)
directly for AI assistance and OCR features. The service enforces:

- User consent checks
- Daily quota limits
- Connectivity gating

Requests are made directly from the client to the external API.

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

### 6.2 Synchronization: Offline-First

The sync architecture is **local-first**:

**Stage 1 — Local change capture**: When the app writes to the local SQLite
database, `DatabaseRepository` inserts a record into the local database.
All core data remains on-device by default.

### 6.3 Conflict Resolution

Conflicts are handled locally when possible. Local operations remain
authoritative unless explicitly overridden by the user.

### 6.3 Locking and Thread Safety

- `DatabaseHelper` uses a **double-checked locking** pattern: `_database` is
  a cached field, and `_databaseOpening` is a cached `Future<Database>` that
  prevents concurrent initialization. Once set, `_database` is returned
  synchronously.
- All singleton services use the
  `factory X() => _instance` pattern with a private named constructor.

### 6.4 Background Tasks

- **Local notifications**: `LocalBackupScheduler` uses
  `flutter_local_notifications` to show backup-due reminders. Notification
  initialization is guarded with try/catch as it may fail on some platforms.
- **Foreground service**: `FocusShieldForegroundService` on Android keeps
  the DND session active without being killed by the system.

---

## Error Handling & Failure Modes

### 7.1 Dart-side Error Handling

#### Silent failure for optional features

Optional services catch exceptions silently. This is an intentional design
choice: optional features should never crash the local-only experience.

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

In `main()`, `FlutterError.onError` is set to dump the error to the console.

This captures all Flutter framework rendering errors, widget build failures,
and unhandled exceptions in the UI thread.

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
- **Web**: Explicitly unsupported. The app is designed for Android and Linux desktop.

---

## Key Data Flow Pathways

### Pathway A: Local write (local-only)

```
1. UI calls DatabaseRepository.insertSubject()
   → DatabaseHelper.insertSubject() writes to SQLite
```

### Pathway B: AI request (client → external API → client)

```
1. UI calls AIService.generateTaskBreakdown()
   → Checks consent, cost warning, quota, connectivity
   → Returns error string if any gate fails (no exception)

2. If passed:
   → Calls external AI API directly
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
