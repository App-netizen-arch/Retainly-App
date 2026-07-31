# Threat Model

## Assets
- **Local study data**: subjects, chapters, tasks, focus sessions, revisions, resources.
- **Authentication state**: PIN hash, Firebase UID, Google OAuth tokens (encrypted).
- **Cloud data**: Firestore documents, Cloud Storage blobs.
- **AI / OCR data**: consents, request logs, OCR outputs.

## Threats
- **Device loss / theft**: local SQLite database and encrypted token vault may be accessed if device is unlocked.
- **Unauthorized cloud access**: misconfigured Firestore / Storage rules could expose user data.
- **AI prompt injection**: external AI provider could return malicious content; responses are not sanitized for code execution.
- **Man-in-the-middle**: Cloud Functions traffic uses HTTPS; local HTTP calls use encrypted channels.
- **Insider threat**: developer or maintainer access to Firebase project could read production data.
- **Denial of service**: quota exhaustion, storage quota limits, or Firebase outages.

## Mitigations
- **Local encryption**: secrets stored via FlutterSecureStorage (platform Keychain / Keystore).
- **Firestore rules**: ownership checks on all user-scoped collections; authentication required.
- **Storage rules**: path-scoped ownership checks; no public bucket access.
- **AI consents**: explicit opt-in required; daily quota enforced; no AI access without consent.
- **HTTPS everywhere**: Firebase and Cloud Functions use TLS.
- **Tombstones**: deleted records marked for 30 days to prevent resurrection attacks.

## Residual Risks
- A rooted / jailbroken device with OS-level access could bypass app-level encryption.
- Firebase project owners can inspect data; use separate production and test projects.
- AI provider outages will degrade AI features; the App falls back to local-only planning.
