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
scanning).

**Invariant**: The app must continue operating in local-only mode. No
optional service may throw an unhandled exception or crash the application.
All service exceptions are caught silently at the service boundary.

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
- **No client-side secrets**: AI API keys are stored securely and never
  embedded in the Flutter client binary or committed to the repository.
- **TLS everywhere**: All network traffic to external APIs is encrypted in transit
  via HTTPS/TLS.

### 1.4 Isolation boundaries

- **User data isolation**: Each user's data is isolated locally on the device.
- **AI data isolation**: AI prompts and responses are never stored in
  Firestore. Full prompts/responses live only in the client and are logged
  locally.
- **Process isolation**: Background tasks run in a separate Dart isolate
  when applicable and cannot access the app's in-memory state.

### 1.5 Principle of least privilege

- External API keys are stored securely and never committed to the repository.
- Android permissions (`AndroidManifest.xml:2-10`) are declared explicitly:
  `POST_NOTIFICATIONS`, `ACCESS_NOTIFICATION_POLICY`,
  `READ_EXTERNAL_STORAGE` (for PDF imports), `CAMERA` (for image capture),
  `SCHEDULE_EXACT_ALARM`, `FOREGROUND_SERVICE`. No dangerous permissions
  beyond these are requested.

### 1.6 Consent and gating

- AI features require **explicit opt-in** consent (`aiAssistance` flag stored
  in `SharedPreferences`).
- OCR requires **separate explicit opt-in** consent (`ocrScanning` flag).
- Cost warnings must be accepted before first AI use.
- Daily quota (50 requests) is enforced client-side (SharedPreferences
  with date-rollover reset).

---

## 2. Threat Model

### 2.1 Assets

| Asset | Location | Sensitivity |
|---|---|---|
| Local study data (subjects, chapters, tasks, revisions, sessions) | SQLite | High — personal academic planning |
| Focus session notes & parking lot notes | SQLite `focus_sessions` table | Medium — may contain personal reflections |
| Practical records (experiment observations, viva questions) | SQLite `practical_records` table | Medium — academic work |
| User preferences & settings | `SharedPreferences` | Low |
| AI consent state & daily quota | `SharedPreferences` | Low |
| Encryption key (local backups) | `FlutterSecureStorage` (platform keystore) or `SharedPreferences` (Linux) | Critical for backup confidentiality |

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

#### T2: AI prompt injection / output safety

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
    `AIService.reportHallucination()`, stored locally.

#### T4: Man-in-the-middle (MITM)

- **Risk**: Network interception of API calls to AI providers.
- **Mitigation**:
  - All API traffic uses HTTPS with certificate pinning at the
    OS level.
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

#### T6: Insider threat (server access)

- **Risk**: A developer or maintainer with access to backend infrastructure
  can read or modify production data.
- **Mitigation**:
  - Use separate environments for development, staging, and production.
  - Restrict access to the minimum number of
    maintainers.
  - AI API keys are stored securely, not in the codebase.

#### T7: Denial of service (quota exhaustion)

- **Risk**: An attacker could exhaust a user's AI daily quota by triggering
  repeated AI requests, or the AI provider could be unavailable.
- **Mitigation**:
  - Daily quota (50 requests) is enforced client-side.
  - Client-side quota tracking prevents the user from seeing quota errors
    repeatedly in a single session.
  - If the AI provider is unavailable or returns an error, the app degrades gracefully
    to local-only planning.

#### T8: Sync data resurrection

- **Risk**: A deleted record could reappear if a stale create arrives after a delete.
- **Mitigation**:
  - Deletes are tracked locally to prevent resurrection.
  - Tombstones are retained for 30 days before deletion.

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
| API keys | FlutterSecureStorage | Never committed to repository |

### 3.2 Data in transit

- All API communication uses HTTPS/TLS.
- Google Vision API calls are authenticated via the service account's
  OAuth 2.0 token over HTTPS.
- AI provider (OpenAI/Anthropic/Gemini) calls go through HTTPS; the API key is never exposed to the client.

### 3.3 Data lifecycle

- **Study data**: Persisted indefinitely in local SQLite unless the user
  deletes it or restores a backup that clears it.
- **Backups**: Stored in `documents/backups/` until manually deleted or
  auto-purged by `deleteOldBackups(keepCount: 10)`.
- **AI requests log**: Recorded locally. Retained indefinitely unless manually deleted.
- **OCR jobs**: Processed and results returned to the client.
- **Hallucination reports**: Stored locally (SharedPreferences). Retained until user clears them.

### 3.4 Data deletion

- The app provides in-app controls (Settings screen) for account deletion,
  which triggers local database deletion.
- `SharedPreferences.clear()` is called during restore operations to
  prevent stale preferences from persisting.
- Local backup files can be deleted individually or via
  `cleanupOldBackups()`.

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
   Linux desktop).
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
- Do not test against production infrastructure belonging to other users.

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
5. **Local encrypted backup** (implemented): AES-256 encrypted local backup.

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
attempt tracking or use `EncryptedSharedPreferences` for the lockout state.

### 7.3 No root/jailbreak detection

The app does not detect rooted or jailbroken devices. **Recommended**:
Integrate a root-detection library (e.g., `root_check`) and warn or restrict
online features on compromised devices.

### 7.5 AI output not sanitized for code execution

AI responses may contain content that, if rendered as HTML or executed,
could be unsafe. Currently, all AI output is displayed as plain text in
`Text` widgets (no HTML rendering). This is safe today, but any future
change to render AI output as HTML must use a sanitization library.
