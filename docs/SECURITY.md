# Security Policy

This document outlines the security model, invariants, threat model, and
vulnerability disclosure process for the Retainly study planner application.

---

## Table of Contents

1. [Security Invariants](#1-security-invariants)
2. [Threat Model](#2-threat-model)
3. [Data Protection](#3-data-protection)
4. [Authentication & Authorization](#4-authentication--authorization)
5. [Vulnerability Disclosure Policy](#5-vulnerability-disclosure-policy)
6. [Security Review](#6-security-review)

---

## 1. Security Invariants

### 1.1 Offline-first data isolation

The local SQLite database is the authoritative data store. All core
study-planning features (task scheduling, chapter tracking, focus sessions,
revision queues, practical records) function entirely offline without any
network dependency. No user data is transmitted to any server unless the
user explicitly enables and uses an online-only feature (AI assistance, OCR
scanning, or cloud sync).

**Invariant**: If Firebase fails to initialize, the app must continue
operating in local-only mode. No Firebase-dependent code path may throw an
unhandled exception or crash the application. All `FirebaseException`
instances are caught silently at the service boundary.

### 1.2 Memory safety

The Flutter/Dart runtime provides managed memory (garbage-collected). There
are no raw pointer operations, no manual memory allocation, and no C/C++
code in the Dart layer. The Android native layer (`MainActivity.kt`,
`FocusShieldForegroundService.kt`, `FocusAccessibilityService.kt`) is
written in Kotlin and is subject to the JVM's memory safety guarantees.

### 1.3 Cryptographic assumptions

- **AES-256**: Local backups are encrypted using the `encrypt` package with
  AES-256. The encryption key is 32 bytes generated via
  `Key.fromSecureRandom(32)` (CSPRNG).
- **Key storage**: On Android/iOS/macOS, encryption keys are stored in the
  platform's secure hardware-backed keystore (Android Keystore / iOS Keychain)
  via `flutter_secure_storage`. On Linux desktop, keys fall back to
  `SharedPreferences` (plaintext — see [Residual Risks](#9-residual-risks)).
- **No client-side secrets**: AI API keys and Firebase service account
  credentials are stored exclusively in Firebase Secret Manager or the
  Firebase Functions environment config. They are never embedded in the
  Flutter client binary or committed to the repository.
- **TLS everywhere**: All network traffic to Firebase (Firestore, Storage,
  Functions, Analytics, Crashlytics, Remote Config) is encrypted in transit
  via HTTPS/TLS. The `cloud_functions` SDK enforces HTTPS for all callable
  function invocations. Google Vision API traffic is similarly encrypted.

### 1.4 Isolation boundaries

- **User data isolation**: Each user's data is isolated by UID. Firestore
  security rules (see `firestore.rules:25-38`) enforce ownership checks on
  every user-scoped collection (`sync_outbox`, `sync_tombstones`,
  `sync_conflicts`, `user_profiles`). A user cannot read or write another
  user's data — this is enforced server-side by Firestore rules, not
  client-side checks.
- **Storage path isolation**: Cloud Storage rules (`storage.rules:11-14`)
  scope `users/{userId}/`, `ai-uploads/{userId}/`, and
  `ocr-output/{userId}/` to the authenticated owner only. Cross-user
  access is denied by the rules engine.
- **AI data isolation**: AI prompts and responses are never stored in
  Firestore (only the first 2000 characters of the prompt are recorded in
  `ai_requests` for quota tracking). Full prompts/responses live only in
  the Cloud Function's ephemeral memory and are logged to Cloud Logging.
  OCR output is stored in the user-scoped `ocr-output/{userId}/` storage
  path.
- **Process isolation**: Background sync runs in a separate Dart isolate
  (spawned by `workmanager`) that initializes its own Firebase context.
  This isolate cannot access the app's in-memory state but communicates
  through the shared Firestore outbox.

### 1.5 Principle of least privilege

- The Firebase service account used by Cloud Functions has the minimum
  permissions required (Firestore data admin, Storage object admin, Secret
  Manager secret accessor for AI keys). No broad GCP permissions are granted.
- Android permissions (`AndroidManifest.xml:2-10`) are declared explicitly:
  `POST_NOTIFICATIONS`, `ACCESS_NOTIFICATION_POLICY`,
  `READ_EXTERNAL_STORAGE` (for PDF imports), `CAMERA` (for image capture),
  `SCHEDULE_EXACT_ALARM`, `FOREGROUND_SERVICE`. No dangerous permissions
  beyond these are requested.

### 1.6 Consent and gating

- AI features require **explicit opt-in** consent (`aiAssistance` flag stored
  in `SharedPreferences` and mirrored to `ai_consents/{userId}`).
- OCR requires **separate explicit opt-in** consent (`ocrScanning` flag).
- Cost warnings must be accepted before first AI use.
- Daily quota (50 requests) is enforced both client-side (SharedPreferences
  with date-rollover reset) and server-side (Firestore count query in
  `aiProxy`).

---

## 2. Threat Model

### 2.1 Assets

| Asset | Location | Sensitivity |
|---|---|---|
| Local study data (subjects, chapters, tasks, revisions, sessions) | SQLite (`study_planner.db`, `study_planner_drift.db`) | High — personal academic planning |
| Focus session notes & parking lot notes | SQLite `focus_sessions` table | Medium — may contain personal reflections |
| Practical records (experiment observations, viva questions) | SQLite `practical_records` table | Medium — academic work |
| User preferences & settings | `SharedPreferences` | Low |
| AI consent state & daily quota | `SharedPreferences` | Low |
| Encryption key (local backups) | `FlutterSecureStorage` (platform keystore) or `SharedPreferences` (Linux) | Critical for backup confidentiality |
| Cloud-synced data | Firestore (owner-scoped collections) | High |
| AI prompt/response data | Cloud Function memory, Cloud Logging (truncated) | Medium — transient |
| OCR source PDFs & extracted text | Cloud Storage (`ocr-output/{userId}/`) | Medium |

### 2.2 Threats and Mitigations

#### T1: Device loss / theft

- **Risk**: Physical access to an unlocked device allows reading the local
  SQLite database and SharedPreferences.
- **Mitigation**:
  - The local SQLite database is **not encrypted at rest** (no SQLCipher).
    Users should enable device-level encryption (Android File-Based
    Encryption / iOS Data Protection).
  - The encryption key for local backups is stored in the platform keystore,
    which requires device unlock to access (on Android/iOS/macOS).
  - Backups are stored as encrypted files and are useless without the key.

#### T2: Unauthorized cloud access (misconfigured rules)

- **Risk**: Firestore or Storage rules could be misconfigured to allow
  cross-user data access.
- **Mitigation**:
  - All user-scoped collections require `request.auth.uid` to match the
    document's `userId` field or document ID.
  - Rules are unit-tested via `@firebase/rules-unit-testing`
    (`functions/tests/firestore.rules.test.ts` and
    `functions/tests/storage.rules.test.ts`).
  - CI runs rules tests on every push and PR.
  - **Procedure**: Always run `npm run test:rules` before deploying rules.
    Any new collection requires corresponding rule coverage and tests.

#### T3: AI prompt injection / output safety

- **Risk**: The AI provider could return malicious, inaccurate, or harmful
  content. Prompts are constructed from user input (chapter titles, task
  descriptions).
- **Mitigation**:
  - AI responses are treated as **drafts**. The system prompt explicitly
    states: "Every task breakdown, flashcard set, quiz item, or revision
    schedule you generate is strictly a draft" and "No Direct Plan
    Mutation."
  - AI output is never written directly to the database. Users must review
    and manually confirm before any AI-generated content is added to their
    study plan.
  - An academic integrity guardrail prevents the AI from completing graded
    assignments or exam questions on behalf of the student.
  - Response length is capped at 4000 characters; empty responses are
    rejected.
  - Users can submit hallucination reports via
    `AIService.reportHallucination()`, stored locally and mirrored to
    `ai_hallucination_reports` collection in Firestore.

#### T4: Man-in-the-middle (MITM)

- **Risk**: Network interception of API calls to Firebase or AI providers.
- **Mitigation**:
  - All Firebase SDK traffic uses HTTPS with certificate pinning at the
    OS level.
  - Cloud Functions callable functions use `httpsCallable`, which enforces
    HTTPS and Firebase-generated auth tokens.
  - Google Vision API and OpenAI/Gemini/Anthropic SDK clients use HTTPS
    exclusively with their respective TLS configurations.

#### T5: Rooted / jailbroken device

- **Risk**: A rooted Android device could bypass app-level encryption,
  inspect memory, or tamper with the SQLite database or SharedPreferences.
- **Mitigation**:
  - No root detection is currently implemented. This is an accepted risk.
  - Users are advised not to store sensitive data (e.g., exam notes with
    personal information) if their device is rooted.
  - See [Residual Risks](#9-residual-risks).

#### T6: Insider threat (Firebase project access)

- **Risk**: A developer or maintainer with access to the Firebase project
  can read or modify production data.
- **Mitigation**:
  - Use separate Firebase projects for development, staging, and production.
  - Restrict IAM roles on the production project to a minimum number of
    maintainers.
  - AI API keys are stored in Secret Manager, not in Firestore or the
    codebase.

#### T7: Denial of service (quota exhaustion)

- **Risk**: An attacker could exhaust a user's AI daily quota by triggering
  repeated AI requests, or the AI provider could be unavailable.
- **Mitigation**:
  - Daily quota (50 requests) is enforced server-side by `aiProxy`.
  - Client-side quota tracking prevents the user from seeing quota errors
    repeatedly in a single session.
  - If the AI provider is unavailable or returns an error, the function
    returns a human-readable error string — the app degrades gracefully
    to local-only planning.

#### T8: Sync data resurrection

- **Risk**: A deleted record from one device could reappear on another
  device during sync if a stale create arrives after a remote delete.
- **Mitigation**:
  - Deletes are tracked via `sync_tombstones` with a `deletedAt` timestamp.
  - The `pruneTombstones` Cloud Function and `SyncService.pruneTombstones()`
    method retain tombstones for 30 days before deletion.
  - The server-side `syncWorker` function processes the outbox, but the
    current server-side implementation does not check tombstones before
    applying mutations — this is a **known gap** (see Remaining Risks).

#### T9: PIN brute-force

- **Risk**: A local PIN (stored as a hash) could be brute-forced.
- **Mitigation**:
  - Rate-limiting is implemented client-side in `auth_screen.dart`: 5
    failed attempts trigger a 30-second lockout, persisted in
    `SharedPreferences`.
  - **Limitation**: Clearing app data resets the counter. See
    [Residual Risks](#9-residual-risks).
  - Account deletion requires PIN re-verification (added per
    `docs/SECURITY_REVIEW.md`).

---

## 3. Data Protection

### 3.1 Data at rest

| Data | Protection | Notes |
|---|---|---|
| Local SQLite database | Unencrypted (SQLCipher not integrated) | Platform FBE / iOS Data Protection recommended |
| Local backups | AES-256 encrypted | Key in platform keystore (Android/iOS/macOS) |
| SharedPreferences | Unencrypted | Contains only non-sensitive preferences |
| AI consent state | SharedPreferences | Boolean flags — no PII |
| Cloud Storage | Server-side encryption (Google-managed) | Object-level ACLs enforced via storage.rules |
| Firestore | Server-side encryption (Google-managed) | Access controlled via firestore.rules |

### 3.2 Data in transit

- All Firebase SDK communication uses HTTPS/TLS.
- Cloud Functions are HTTPS callable or scheduled via Pub/Sub (server-to-server).
- Google Vision API calls are authenticated via the service account's
  OAuth 2.0 token over HTTPS.
- AI provider (OpenAI/Anthropic/Gemini) calls go through the Cloud Function
  over HTTPS; the API key is never exposed to the client.

### 3.3 Data lifecycle

- **Study data**: Persisted indefinitely in local SQLite unless the user
  deletes it or restores a backup that clears it.
- **Backups**: Stored in `documents/backups/` until manually deleted or
  auto-purged by `deleteOldBackups(keepCount: 10)`.
- **AI requests log**: Recorded in Firestore `ai_requests` (prompt truncated
  to 2000 chars). Retained indefinitely unless manually deleted.
- **OCR jobs**: Recorded in Firestore `ocr_jobs`. Retained indefinitely.
- **Tombstones**: Auto-deleted after 30 days by `pruneTombstones`.
- **Hallucination reports**: Stored locally (SharedPreferences) and in
  Firestore `ai_hallucination_reports`. Retained until user clears them.
- **Analytics/Crashlytics**: Retention follows Firebase's default policies
  (Analytics: 14 months; Crashlytics: 180 days by default, configurable).

### 3.4 Data deletion

- The app provides in-app controls (Settings screen) for account deletion,
  which triggers local database deletion and (when cloud sync is enabled)
  Firestore document deletion requests.
- `SharedPreferences.clear()` is called during restore operations to
  prevent stale preferences from persisting.
- Local backup files can be deleted individually or via
  `cleanupOldBackups()`.

---

## 4. Authentication & Authorization

### 4.1 Authentication Model

- **Local PIN / local-only mode**: When the app is used without Firebase,
  authentication is via a local PIN (stored as a salted hash in
  `SharedPreferences`). This is primarily an access-control mechanism for the
  device, not a user-identity system.
- **Firebase Auth (optional)**: When enabled, users can sign in via Google
  OAuth or email/password. The Firebase UID becomes the `userId` used for
  all cloud-scoped data.
- **Authentication context**: The `firebase_options.dart` file throws
  `UnsupportedError` on web platforms to prevent runtime failures. See
  `docs/SECURITY_REVIEW.md` for details.

### 4.2 Authorization (Firestore)

All Firestore rules enforce ownership:

```firestore
function isOwner(userId) {
  return isAuthenticated() && request.auth.uid == userId;
}
```

Collections and their access patterns:

| Collection | Read | Write | Create | Delete |
|---|---|---|---|---|
| `users/{userId}` | Owner | Owner | — | — |
| `sync_outbox/{outboxId}` | Owner (via `resource.data.userId`) | Owner | Owner (via `request.resource.data.userId`) | Owner |
| `sync_tombstones/{tombstoneId}` | Owner | Owner | Owner | Owner |
| `sync_conflicts/{conflictId}` | Owner | Owner | Owner | Owner |
| `user_profiles/{profileId}` | Owner | Owner | Authenticated (matching UID) | — |
| `ai_consents/{userId}` | Server-only (via function) | Server-only (via function) | — | — |
| `ai_requests/{requestId}` | Server-only | Server-only | — | — |
| `ocr_jobs/{jobId}` | Client reads (ownership checked in code) | Server-only | Server-only (via function) | — |
| `quizzes/{quizId}` | Authenticated | Owner (via `resource.data.ownerId`) | Owner (via `request.resource.data.ownerId`) | Owner |
| `quiz_attempts/{attemptId}` | Owner | Owner | Owner | — |

### 4.3 Authorization (Cloud Storage)

```storage
match /users/{userId}/{allPaths=**} {
  allow read, write: if isOwner(userId);
}
match /ai-uploads/{userId}/{allPaths=**} {
  allow read, write: if isOwner(userId);
}
match /ocr-output/{userId}/{allPaths=**} {
  allow read, write: if isOwner(userId);
}
match /study-groups/{groupId}/{allPaths=**} {
  allow read: if isAuthenticated();  // future groups feature
  allow write: if false;
}
```

The `study-groups` path is read-only for authenticated users, anticipating
a future study-groups feature. All writes to study groups are denied.

---

## 5. Vulnerability Disclosure Policy

### 5.1 Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security
vulnerability in Retainly, please report it responsibly:

**Preferred**: Use the in-app "Report a problem" flow (Settings → Help &
Feedback → Report a problem). Select "Security issue" as the category.
This is monitored by the core team.

**GitHub**: For non-security issues, please use GitHub Issues. For security
vulnerabilities, **do not** use GitHub Issues — use the in-app reporting
flow above to allow us to coordinate a fix before public disclosure.

### 5.2 What to Include

When reporting a vulnerability, please include:

1. **Description**: A clear description of the vulnerability and its impact.
2. **Reproduction**: Step-by-step instructions to reproduce the issue.
3. **Affected version**: The app version and platform (e.g., Android 3.24.0,
   Linux desktop, Firebase project name if relevant).
4. **Proof of concept**: A minimal PoC if available.
5. **Contact**: Your preferred contact method and timezone for follow-up.

### 5.3 Response Timeline

| Phase | Timeline |
|---|---|
| Initial acknowledgment | Within 48 hours |
| Triage and assessment | Within 5 business days |
| Fix development | Varies by severity (P0: <24h, P1: <7 days, P2: <30 days) |
| Patch release | Varies by severity (P0: immediate, P1: <14 days, P2: next release) |
| Public disclosure | After patch is released + 30 days grace period |

### 5.4 Severity Classification

| Severity | Criteria | Response Time |
|---|---|---|
| **P0 (Critical)** | Remote code execution, authentication bypass, data exposure of PII | < 24 hours |
| **P1 (High)** | Cross-user data access, privilege escalation, AI key exposure | < 7 days |
| **P2 (Medium)** | Local PIN brute-force, weak default config, information disclosure (non-PII) | < 30 days |
| **P3 (Low)** | Minor info disclosure, defense-in-depth improvements, documentation | Next release cycle |

### 5.5 Safe Harbor

We support responsible disclosure. If you make a good-faith effort to
follow this policy, we will not initiate legal action against you for
security research conducted in accordance with this policy. However:

- Do not exploit the vulnerability beyond what is necessary to demonstrate it.
- Do not access, modify, or delete data that does not belong to you.
- Do not conduct denial-of-service testing.
- Do not attempt to access or extract data from other users.
- Do not test against production Firebase projects belonging to other users.

### 5.6 Bug Bounty

Currently, Retainly does not offer a paid bug bounty program. We
appreciate security researchers who report vulnerabilities responsibly and
will publicly credit you (if desired) in release notes for the fix.

### 5.7 Security Advisories

Security advisories will be published as GitHub Security Advisories and
cross-posted to the in-app changelog. Advisories will include:

- Affected versions
- Impact assessment
- Upgrade instructions
- CVE assignment (for P0/P1 issues, when applicable)

---

## 6. Security Review

The project maintains a security review log at
`docs/SECURITY_REVIEW.md` documenting known issues, fixed vulnerabilities,
and remaining risks. Before submitting a PR that touches authentication,
authorization, data storage, or encryption, review this file and ensure
your changes are reflected in it.

### Key areas reviewed in the latest security assessment:

1. **Sync worker data loss** (fixed): The `syncWorker` Cloud Function now
   reads `entity`, `entityId`, `operation`, and `data` from each outbox item
   and applies the mutation before marking as synced.
2. **PIN brute-force protection** (implemented): 5 failed attempts trigger
   a 30-second lockout.
3. **Account deletion re-authentication** (implemented): PIN verification
   required before account deletion.
4. **Email validation** (implemented): Format validation prevents invalid
   email patterns.
5. **Auth context validation** (fixed): Replaced hardcoded UIDs with
   `FirebaseAuth.instance.currentUser?.uid` in 6 files.
6. **Firestore rules hardening** (implemented): Strict owner-based CRUD
   rules on all collections.
7. **OCR duplicate suppression** (implemented): Server-side deduplication.
8. **Platform guards** (implemented): `firebase_options.dart` throws
   `UnsupportedError` for web.
9. **Local encrypted backup** (implemented): AES-256 encrypted local backup.

---

## 7. Remaining Risks & Future Work

The following risks are documented and accepted pending mitigation
(tracked as technical debt):

### 7.1 Unencrypted local database

The SQLite database lacks OS-level encryption (no SQLCipher integration).
A device compromise (root/jailbreak) with the device unlocked could expose
study data. **Recommended**: Integrate `sqlcipher_flutter_libs` or
`drift` with SQLCipher to encrypt the local database at rest.

### 7.2 SharedPreferences-based lockout

The PIN brute-force lockout counter is stored in `SharedPreferences`, which
can be reset by clearing app data. **Recommended**: Implement server-side
attempt tracking when Firebase Auth is enabled, or use
`EncryptedSharedPreferences` for the lockout state.

### 7.3 Tombstone bypass in syncWorker

The server-side `syncWorker` Cloud Function applies mutations from
`sync_outbox` without checking `sync_tombstones` for prior deletes. A
stale create from one device could resurrect deleted data on another.
**Recommended**: Add a tombstone existence check before applying create/update
operations in the `syncWorker` function.

### 7.4 No root/jailbreak detection

The app does not detect rooted or jailbroken devices. **Recommended**:
Integrate a root-detection library (e.g., `root_check`) and warn or restrict
online features on compromised devices.

### 7.5 AI output not sanitized for code execution

AI responses may contain content that, if rendered as HTML or executed,
could be unsafe. Currently, all AI output is displayed as plain text in
`Text` widgets (no HTML rendering). This is safe today, but any future
change to render AI output as HTML must use a sanitization library.
