# Contributing to Retainly

Thank you for your interest in contributing to Retainly! This document
covers the development environment setup, code standards, commit conventions,
and the verification pipeline. By contributing, you agree to follow these
guidelines.

---

## Table of Contents

1. [Workspace Setup](#1-workspace-setup)
2. [Code Style & Standards](#2-code-style--standards)
3. [Commit & PR Process](#3-commit--pr-process)
4. [Verification Pipeline](#4-verification-pipeline)
5. [Testing](#5-testing)
6. [Adding New Features](#6-adding-new-features)

---

## 1. Workspace Setup

### 1.1 Prerequisites

| Tool | Minimum Version | Required For |
|---|---|---|
| Flutter SDK | 3.24.0 | Dart/Flutter development |
| Dart SDK | 3.7.0 | Language features |
| Node.js | 18.x | Cloud Functions development |
| Firebase CLI | latest | Rule deployment, local emulation |
| Android SDK | API 23+ (Android 6.0) | Android builds |
| Git | any recent | Version control |

The CI workflow (`.github/workflows/ci.yml`) uses `flutter-version: '3.24.0'`
on the `stable` channel. Use the same version to match CI behavior.

### 1.2 Clone and Install

```bash
git clone https://github.com/codesym/retainly.git
cd retainly

# Flutter dependencies
flutter pub get

# Firebase CLI (if not already installed)
npm install -g firebase-tools

# Cloud Functions dependencies
cd functions
npm install
cd ..
```

### 1.3 Configure IDE

The project includes `.vscode/` settings (if present) with recommended
extensions. At minimum, install:

- **Dart** and **Flutter** extensions for VS Code
- **YAML** language support
- **Dart Data Class Generator** (for generating `toMap`/`fromMap` boilerplate)

### 1.4 Environment Variables

The app uses Firebase environment variables for Cloud Function
configuration. Create a `.env` file or use Firebase Functions config:

```bash
# For Cloud Functions local emulation
firebase functions:config:get > .runtimeconfig.json
```

The Flutter app reads `SharedPreferences` and `flutter_secure_storage` —
no additional environment setup is needed for local development. On Linux
desktop, `FlutterSecureStorage` falls back to `SharedPreferences` automatically.

### 1.5 Optional: Firebase Local Emulator Suite

For developing and testing sync/features locally:

```bash
firebase emulators:start
```

This starts Firestore, Functions, Storage, and Auth emulators. The app will
auto-detect the emulator if `FIREBASE_USE_EMULATOR=true` is set in
`SharedPreferences` or if the `DEBUG` flag is enabled.

### 1.6 Project Name

The Dart package name is `retainly` (see `pubspec.yaml`), even though the
directory is named `matric_study_planner`. All internal imports use
`package:retainly/...`. When creating new files, use this package prefix.

---

## 2. Code Style & Standards

### 2.1 Formatting

The project uses `dart format` with the default line length of 80
characters. CI enforces formatting via:

```yaml
dart format --set-exit-if-changed .
```

**Always run formatting before committing:**

```bash
dart format .
```

### 2.2 Linting

The project uses `package:flutter_lints/flutter.yaml` (the standard Flutter
lints) configured in `analysis_options.yaml`. To check for lint violations:

```bash
flutter analyze
```

CI runs `flutter analyze` and fails on any analyzer errors or warnings.
Do not commit code that produces analysis warnings. Use `// ignore: rule_name`
sparingly and only with a justification comment on the preceding line.

### 2.3 Dart Conventions

- Use **null-safety** (Dart 3.7+ with sound null safety). All nullable
  fields must be explicitly typed with `?`.
- Prefer `final` for fields that are not reassigned.
- Use `const` constructors where possible for compile-time constants.
- Use `required` for non-nullable constructor parameters.
- Use `Value(...)` for Drift companion inserts of nullable fields (from
  `package:drift/drift.dart`).
- Follow the existing pattern in `app_models.dart`: all `fromMap()`
  constructors use defensive type checks:
  ```dart
  field: map['field'] is String ? map['field'] as String : 'default',
  ```
  This protects against partial or legacy data.

### 2.4 Riverpod Provider Patterns

- Use `Provider`, `FutureProvider`, `FutureProvider.autoDispose`, and
  `NotifierProvider` as appropriate.
- `autoDispose` must be used for providers that hold data no longer needed
  when the UI leaves the screen (e.g., `todayTasksProvider`,
  `databaseRepositoryProvider`).
- `family` modifiers are used for parameterized providers
  (e.g., `tasksForDateProvider`).
- Overrides for testing: `sharedPreferencesProvider.overrideWith((_) => prefs)`
  is used in `main.dart` to inject a pre-initialized `SharedPreferences`.

### 2.5 Error Handling Conventions

- **Firebase-dependent services**: All Firebase API calls must be wrapped in
  `try/catch` on `FirebaseException`. Failures must NOT propagate — the
  service degrades to local-only mode silently. Follow the pattern in
  `sync_service.dart`:
  ```dart
  try {
    await _firestore!.collection('...').add({...});
  } on FirebaseException catch (_) {}
  ```
- **UI layer**: Use `showErrorSnackBar()` / `showSuccessSnackBar()` from
  `lib/core/utils/error_utils.dart` for user-facing messages.
- **Platform calls**: Wrap `MethodChannel` calls in `PlatformException`
  handlers (see `shortcut_service.dart`, `focus_screen.dart`).
- **Restoration**: Return `RestoreResult` objects with `success: false`
  and a descriptive `message` — never throw to the UI for restore failures.

### 2.6 Backup Encryption Standards

- AES-256 encryption is used for all local backups via the `encrypt` package.
- Encryption keys are 32 bytes from `Key.fromSecureRandom(32)`.
- Secure storage (`FlutterSecureStorage`) is used on Android/iOS/macOS.
- On Linux/Windows, the key falls back to `SharedPreferences`.
- Backup files include a magic header `MSP_BACKUP_V1` and schema version
  `_schemaVersion = 2`. Both must be validated on restore.

### 2.7 Feature Flags

Feature flags are centralized in `lib/core/feature_flags.dart`. New features
should be gated behind a flag:

```dart
static const bool myNewFeature = false;  // compile-time default
```

Runtime overrides are supported via `_runtimeOverrides` and the
`isFeatureEnabled()` / `setFeatureOverride()` methods. Add any new flag to
both the `allFlags` map and the `_rolloutFlags` map if staged rollout is
needed.

### 2.8 Type Safety

- The Cloud Functions code (`functions/src/index.ts`) uses TypeScript.
  The `tsconfig.json` has `skipLibCheck: true` and `strictNullChecks:
  false` — match this configuration for new `.ts` files.
- The Firebase security rules use `rules_version = '2'`.
- Tests in `test/unit/` use the `package:test` framework (not
  `flutter_test` for pure logic tests). Widget tests use
  `package:flutter_test`.

---

## 3. Commit & PR Process

### 3.1 Branch Naming

Follow this convention:

```
type/ticket-short-description
```

| Type | Use Case |
|---|---|
| `feature` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring without behavior change |
| `docs` | Documentation-only changes |
| `chore` | Build/tooling/config changes |
| `perf` | Performance improvements |
| `test` | Test additions or fixes |

Examples:
- `feature/ai-quota-enforcement`
- `fix/focus-session-data-loss`
- `chore/update-firestore-rules`

### 3.2 Commit Messages

Follow **Conventional Commits** format:

```
type(scope): subject

body (optional, wrap at 72 chars)

footer (optional, e.g. "Fixes #123")
```

Types: `feat`, `fix`, `perf`, `refactor`, `docs`, `test`, `chore`, `build`,
`ci`

Examples:
```
fix(sync): resolve tombstone pruning not deleting old records

The pruneTombstones function was using deletedAt comparison with
server timestamp objects instead of Date. Converted to Date
before comparison so the 30-day cutoff is evaluated correctly.

Fixes #45
```

```
feat(ai): add Gemini provider support in aiProxy function

Added getGeminiClient() and Gemini-specific request handling in
the aiProxy Cloud Function. Provider is selectable via
functions.config().ai.provider.
```

### 3.3 Pull Request Process

1. **Base branch**: PRs target `main` for releases or `develop` for ongoing
   work. Use `main` only for production-ready changes.
2. **Description**: Include a summary of changes, the problem solved, and any
   trade-offs. Link related issues (`Closes #123`).
3. **Tests**: All new functionality must include tests. See the Testing
   section for coverage requirements.
4. **No secrets**: Never commit API keys, keystores, or
   `google-services.json` with real credentials. These are gitignored
   — see `.gitignore`. Production secrets must be managed via Firebase
   Secret Manager, not committed to the repo.
5. **CI must pass**: The CI workflow runs `dart format`, `flutter analyze`,
   `flutter test`, and platform builds. All checks must pass before merge.

### 3.4 Merge Strategy

- Use **squash and merge** for feature branches to keep history linear.
- Use **merge commit** (not rebase) for release branches that span multiple
  commits and need historical traceability.

---

## 4. Verification Pipeline

### 4.1 Pre-commit Checks

Before any commit, run the full verification suite locally:

```bash
# 1. Format check (CI runs this with --set-exit-if-changed)
dart format --set-exit-if-changed .

# 2. Static analysis
flutter analyze

# 3. All tests (unit + widget + integration)
flutter test
```

If any of these fail, fix the issues before pushing. CI will run the same
checks and fail the PR.

### 4.2 CI/CD Pipeline

**File**: `.github/workflows/ci.yml`

The CI pipeline runs on push to `main` / `develop` and on pull requests to
`main`. It consists of three jobs:

| Job | Trigger | Steps |
|---|---|---|
| `test` | push, PR | Checkout → cache → Flutter 3.24.0 → `flutter pub get` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test` |
| `build-android` | push to main/develop, PR to main | Same as `test` + Android build (AAB for pushes, debug APK for PRs) |
| `build-linux` | push to main/develop | Same as `test` + `flutter build linux --release` |

**Note**: CI runs in a subdirectory `./retainly` — ensure your working
directory matches (`working-directory: ./retainly`).

### 4.3 Functions Verification

For Cloud Functions changes:

```bash
cd functions

# Lint
npm run lint          # eslint src/**/*

# Type check
npm run build         # tsc

# Rule tests (requires Firebase CLI)
npm run test:rules    # jest --config jest.rules.config.js

# Unit tests
npm run test          # jest
```

### 4.4 Firestore Rules Testing

**File**: `functions/tests/firestore.rules.test.ts`

Rules are tested using `@firebase/rules-unit-testing` with the Jest
framework. Before deploying new rules, run:

```bash
cd functions
npm run test:rules
```

This validates that:
- Unauthenticated users cannot read/write protected collections
- Authenticated owners can access their own data
- User A cannot access User B's data
- AI consents are owner-scoped

New rule changes **must** include corresponding test coverage. The Storage
rules are similarly tested in
`functions/tests/storage.rules.test.ts`.

### 4.5 Release Checklist

Before cutting a release:

- [ ] `flutter analyze` passes with zero warnings
- [ ] `dart format --set-exit-if-changed .` passes
- [ ] `flutter test` — all tests pass
- [ ] `functions` tests pass (`npm run lint`, `npm run build`, `npm run test:rules`)
- [ ] Firestore/Storage rules tests pass
- [ ] `CHANGELOG.md` updated (if present)
- [ ] Version number bumped in `pubspec.yaml` (format: `MAJOR.MINOR.PATCH+BUILD`)

### 4.6 Deployment Verification

**File**: `scripts/deploy.sh`

Production deployments use `./scripts/deploy.sh [android|ios|functions|rules|all]`.
The script:

1. Verifies Firebase CLI authentication
2. Selects the project (`retainly-app-b4f4a`)
3. Deploys rules and/or functions and/or app bundles

Always test rule changes in a **staging Firebase project** before deploying
to production. Never deploy functions with real AI API keys to a test project.

---

## 5. Testing

### 5.1 Test Organization

```
test/
└── unit/
    ├── adaptive_estimates_test.dart
    ├── ai_service_test.dart
    ├── anki_template_test.dart
    ├── auth_security_test.dart
    ├── backup_encryption_test.dart
    ├── backup_manager_screen_test.dart
    ├── backup_models_test.dart
    ├── backup_restore_test.dart
    ├── backup_scheduler_test.dart
    ├── focus_screen_test.dart
    ├── legal_screen_test.dart
    ├── ocr_service_test.dart
    ├── offline_queue_test.dart
    ├── planner_logic_test.dart
    ├── production_fixes_test.dart
    ├── repository_test.dart
    ├── services_test.dart
    ├── settings_screen_test.dart
    ├── smart_planner_test.dart
    └── sync_service_test.dart
```

### 5.2 Test Framework

- **Pure logic tests**: Use `package:test` (e.g., `sync_service_test.dart`,
  `backup_encryption_test.dart`). These do not require Flutter bindings and
  run faster.
- **Widget/UI tests**: Use `package:flutter_test` (e.g.,
  `backup_manager_screen_test.dart`, `focus_screen_test.dart`).
- **Mock data**: Tests use `SharedPreferences.setMockInitialValues({})` to
  isolate state. The `test:shared_preferences` approach is used in
  `backup_encryption_test.dart` and `offline_queue_test.dart`.

### 5.3 Coverage Thresholds

- **Services layer**: 100% coverage required for `SyncService`,
  `OfflineQueueService`, `AIService` gate checks, and
  `BackupManager` coordination logic.
- **Repository layer**: 100% coverage for SM-2 algorithm, task scoring,
  and all query methods with side-effect tracking (`_trackChange`).
- **Backup/restore**: 100% coverage for encryption round-trips, schema
  validation, and all `RestoreResult` failure paths.
- **Cloud Functions**: Rules tests must cover all collection access paths
  (read/write/create for each collection).

New code that does not meet 100% coverage on the affected unit will cause
the PR to fail CI.

### 5.4 Writing New Tests

Follow the existing patterns:

```dart
// For service tests (package:test)
import 'package:test/test.dart';
import 'package:retainly/services/sync_service.dart';

void main() {
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
      // No assertion needed — if it throws, the test fails
    });
  });
}
```

```dart
// For encryption tests with SharedPreferences mocks
setUp(() async {
  SharedPreferences.setMockInitialValues({});
});
```

---

## 6. Adding New Features

### 6.1 Feature Module Structure

When adding a new feature in `lib/features/your_feature/`:

```
your_feature/
├── presentation/         # UI screens (ConsumerWidget or ConsumerStatefulWidget)
├── application/          # Coordinator/service layer (if complex)
├── domain/
│   ├── models/           # @immutable data classes
│   └── repositories/     # Abstract repository interfaces
└── data/
    └── repositories/     # Concrete implementations
```

For simple features (no external dependencies), a single screen file under
`lib/features/` is acceptable, following the pattern of `focus_screen.dart`
or `settings_screen.dart`.

### 6.2 Feature Flag Integration

Wrap new features in a flag in `lib/core/feature_flags.dart`:

```dart
static const bool myNewFeature = false;
```

Check the flag at the call site using `FeatureFlags.isFeatureEnabled('my_new_feature')`.

### 6.3 Cloud Function Integration

When adding a callable function to `functions/src/index.ts`:

1. Export the function with `functions.https.onCall`
2. Add authentication check (`context.auth`) as the first guard
3. Add consent/quota checks as applicable
4. Add entry to `.github/workflows/ci.yml` if the function needs
   environment variables in CI
5. Update `FIREBASE_BACKEND_SETUP.md` with the new function's
   configuration

### 6.4 Database Schema Changes

When adding a new table or column:

1. **Drift schema**: Update `lib/data/drift/app_database.dart` and run
   `dart run build_runner build` to regenerate `app_database.g.dart`
2. **Raw SQLite schema**: Add the column/table to
   `_createDB()` in `lib/data/database_helper.dart`
3. **Migrations**: Add conditional `ALTER TABLE` / `CREATE TABLE` blocks to
   `_extendSchema()` for backward compatibility
4. **Bump schema version**: Increment `schemaVersion` in both
   `AppDatabase` and `DatabaseHelper.openDatabase(version: N)`
5. **Model update**: Add the field to the relevant model in
   `app_models.dart` with defensive `fromMap()` handling
6. **Repository method**: Add accessor methods to `DatabaseRepository`
   that call `_trackChange()` for sync tracking

Use `replaceAll` carefully — the CI format check is strict.
