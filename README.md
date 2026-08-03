# Retainly

![Retainly](logo-192.png)

An offline-first Flutter study planner for Pakistani Matric (Class 9–10) students. It turns a syllabus into an adaptive daily plan, tracks focus sessions, and drives spaced-repetition revision — with optional cloud sync and AI assistance when online.

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen?logo=githubactions)](.github/workflows/ci.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue)](#license--compliance)
[![Version](https://img.shields.io/badge/version-1.0.0--1)]()
[![Tests](https://img.shields.io/badge/tests-unit%20%26%20widget-brightgreen)]()

---

## Key Features

- **Offline-first study planning** — Local SQLite/Drift store; all core data stays on-device.
- **Adaptive daily plans** — Priority-weighted scheduler that fits tasks into a daily study budget and surfaces a minimum-viable-day when overloaded.
- **SM-2 spaced repetition** — Revision queue with 1/3/7-day intervals and per-item difficulty adjustment.
- **Pomodoro focus sessions** — Native Android `Do Not Disturb` enforcement via a custom platform-channel foreground service (`focus_shield`).
- **AI assistance (optional, online-only)** — Task breakdown, revision drafts, flashcards, and quizzes through external AI APIs (OpenAI, Anthropic, Gemini), gated by consent + a 50-request/day quota.
- **Secure PDF/OCR** — PDFs are processed via external OCR API; results stay on the device.
- **Encrypted local backups** — AES-256 local export/restore with keys held in platform secure storage; Anki CSV and syllabus-template import/export.
- **Progressive Desktop** — Runs on Android (primary) and Linux desktop; Urdu + English localisation.

---

## Architecture Overview

Retainly is layered into a thin Flutter presentation layer on top of a repository-abstraction data layer, with local-only storage and optional online features.

```
┌──────────────────────────────────────────────────────────────────┐
│  PRESENTATION (Flutter widgets)                                   │
│  lib/features/*  ── GoRouter navigation ── lib/navigation/*        │
│  State via flutter_riverpod ────────────────────────────────────┐ │
└────────────────────────────────────────────────────────────────│ │
│  DOMAIN / SERVICES  lib/services/*                                │
│  AIService • Connectivity ─────────────────────────────────────┘ │
│                                                                  │
│  DATA LAYER  lib/data/*                                          │
│  ┌──────────────────────┐  ┌───────────────────────┐           │
│  │ DatabaseRepository   │  │ AppDatabase (Drift)   │           │
│  │ (business logic,     │  │ sqflite FFI desktop │           │
│  │  SM-2, scoring, CSV) │  │ schema v3           │           │
│  └────────┬─────────────┘  └──────────┬──────────┘           │
│           │  adapter                  │                        │
│           ▼                           ▼                        │
│  ┌──────────────────────┐  ┌───────────────────────┐           │
│  │ DatabaseHelper       │  │ Encrypted backup      │           │
│  │ (sqflite CRUD layer) │  │ (.retainly/backup*)   │           │
│  └──────────────────────┘  └───────────────────────┘           │
│                                                                  │
│  ANDROID NATIVE                                                  │
│  MainActivity.kt ─────►│ Platform Channel                        │
│  focus_shield: DND     │ FocusShieldForeground                   │
│  FocusAccessibilitySvc │ Service.kt                              │
└──────────────────────────────────────────────────────────────────┘
```

**Data flow:** User edits land in the local Drift/SQLite store. Online-only features (AI, OCR) call external APIs directly; every request is gated by explicit user consent. All core data remains on-device by default.

---

## Getting Started

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | 3.24.0+ (stable) |
| Dart SDK | 3.7.0+ |
| Android SDK | API 24+ (for device builds) |

### Install dependencies

```bash
flutter pub get
```

### Run locally

```bash
# Linux desktop (fully local)
flutter run -d linux

# Android device or emulator
flutter run -d android-emulator
```

The app boots in **local-only mode**; AI and OCR are available when configured, while core study data remains on-device.

### Building a release

```bash
# Android App Bundle (Play Store ready)
flutter build appbundle --release

# Android APK
flutter build apk --release

# Linux desktop
flutter build linux --release
```

Release artifacts land in:
- Android: `build/app/outputs/bundle/release/app-release.aab` (or `app-release.apk`)
- Linux: `build/linux/x64/release/bundle/`

Signing is handled via `android/keystore.properties` (gitignored). See *Sign the APK* for the keytool workflow, or run `scripts/build_release.sh` for an analyze → test → build pipeline.

### Configuration

Runtime behaviour is driven by these files and environment values — none are required for a local-only build.

| Source | Purpose |
|--------|---------|
| `AI_API_KEY` | OpenAI / Anthropic / Gemini key for the AI provider. |
| `AI_PROVIDER` | `openai` (default), `anthropic`, `gemini`, `openrouter`. |
| `SharedPreferences` keys | `ai_daily_usage`, `ai_consent`, `ocr_consent`, theme flags. |

Feature flags live in `lib/core/feature_flags.dart` and may be toggled in code.

---

## Usage & Code Examples

### CLI bootstrap

```bash
# 1. Fetch packages
flutter pub get

# 2. Run on desktop (local only)
flutter run -d linux
```

### Programmatic API — core data layer

The repository exposes a typed, synchronous-ish API over the local store. Most callers obtain it through Riverpod.

```dart
import 'package:retainly/data/repositories/database_repository.dart';
import 'package:retainly/data/models/app_models.dart';

final repo = await ref.watch(databaseRepositoryProvider.future);

// Profile / syllabus setup
await repo.createUserProfile(UserModel(
  classLevel: '10',
  board: 'FBISE',
  examDate: '2026-04-30',
  createdAt: now, updatedAt: now,
));
final subjectId = await repo.insertSubject(SubjectModel(
  name: 'Mathematics', color: 0xFF1976D2, sortOrder: 0, createdAt: now,
));

// Schedule a task with a daily budget fit check
final task = TaskModel(
  subjectId: subjectId, title: 'Solve quadratic equations',
  scheduledAt: now, estimatedMinutes: 30, status: 'not_started',
  createdAt: now, updatedAt: now,
);
await repo.insertTask(task);

// Record a focus session
await repo.insertFocusSession(FocusSessionModel(
  taskId: taskId, startedAt: now, plannedMinutes: 25,
  status: 'running', completedMinutes: 0, createdAt: now,
));

// Submit revision feedback (SM-2 update)
await repo.recordRevisionFeedback(revisionId, confidence: 80, status: 'completed');
```

### AI service (online only)

```dart
import 'package:retainly/services/ai_service.dart';

final ai = AIService();
final breakdown = await ai.generateTaskBreakdown(userId, 'Trigonometry basics');
final flashcards = await ai.generateFlashcards(userId, sourceText);
```

All AI calls return a human-readable `String?` and handle consent, quota, and connectivity gating internally; they return a descriptive error string rather than throwing when a prerequisite is missing.

---

## Project Layout

```
.
├── android/                     # Android app + Kotlin platform channels
│   └── app/src/kotlin/com/codesym/retainly/
│       ├── MainActivity.kt          # Activity, registers focus_shield channel
│       ├── FocusShieldForegroundService.kt  # DND + foreground timer
│       └── FocusAccessibilityService.kt     # Usage/accessibility helper
├── lib/
│   ├── main.dart                     # App bootstrap: themes, routing
│   ├── core/                         # Theme, constants, feature flags, utils
│   ├── data/                         # DatabaseHelper (sqflite), Drift schema, models, repository
│   ├── services/                     # AI, background worker, connectivity
│   ├── providers/                    # Riverpod state holders (dashboard, analytics, sync)
│   ├── navigation/                   # GoRouter routes + shell
│   ├── features/                     # Screen-level features (planner, focus, revision, backup, ai, settings, legal)
│   └── l10n/                         # ARB bundles: en + ur (English + Urdu)
├── test/unit/                      # Unit tests for services, repository, planner logic, security
├── test/widget_test.dart           # Widget smoke test
├── scripts/                        # build_release.sh (multi-target)
├── docs/                           # Project documentation
│   ├── ARCHITECTURE.md             # System architecture deep-dive
│   ├── CONTRIBUTING.md             # Contribution guidelines
│   ├── SECURITY.md                 # Security policy
│   ├── SECURITY_REVIEW.md          # Security audit trail and remaining risks
│   └── legal/                      # Legal documents
│       ├── terms_of_service.md     # Terms of Service
│       ├── privacy_policy.md       # Privacy Policy
│       ├── data_retention_policy.md
│       └── threat_model.md
├── pubspec.yaml                    # Flutter package manifest (v1.0.0+1)
├── analysis_options.yaml           # flutter_lints baseline + custom rules
└── README.md
```

---

## Testing & Benchmarking

```bash
# Static analysis + formatting gate
dart format --set-exit-if-changed .
flutter analyze

# Unit + widget tests (Dart)
flutter test

# Targeted suites
flutter test test/unit/planner_logic_test.dart
flutter test test/unit/smart_planner_test.dart
flutter test test/unit/backup_encryption_test.dart
```

There are no dedicated Dart benchmarks (`flutter drive` performance tracing is recommended for focus-session timing).

---

## Security & Compliance

- All user data stays on-device by default.
- Online-only features require **explicit, revocable consent** stored locally.
- AI usage is capped at **50 requests/day/user**, enforced client-side.
- Local backups are **AES-256 encrypted**; encryption keys are stored in `FlutterSecureStorage` (Android Keystore). Backups are **never** auto-uploaded.
- The full threat model and audit trail are in [`docs/SECURITY_REVIEW.md`](docs/SECURITY_REVIEW.md).

---

## License & Compliance

Retainly is licensed under the **Apache License, Version 2.0** — see [`LICENSE`](LICENSE). It is free, open-source software: you may use, modify, and distribute it for any purpose, provided you include the license and notices and preserve the existing attribution. Trademark and service names remain the property of their respective owners.

| Aspect | Detail |
|--------|--------|
| License | Apache-2.0 (`LICENSE`) |
| Usage | Free for personal, educational, and commercial use |
| Redistribution | Include `LICENSE`; mark your changes in modified files |
| Trademarks | Project and service names are not granted by the License |
| AI content | Suggestions only — verify against your textbook |
| Data retention | See [`docs/legal/data_retention_policy.md`](docs/legal/data_retention_policy.md) |
| Privacy | See [`docs/legal/privacy_policy.md`](docs/legal/privacy_policy.md) |

For licensing inquiries, contact the maintainer through the in-app "Report a problem" flow.
