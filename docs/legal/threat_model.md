# Threat Model

## Assets
- **Local study data**: subjects, chapters, tasks, focus sessions, revisions, resources.
- **Authentication state**: PIN hash (encrypted).
- **AI / OCR data**: consents, request logs, OCR outputs.

## Threats
- **Device loss / theft**: local SQLite database and encrypted token vault may be accessed if device is unlocked.
- **AI prompt injection**: external AI provider could return malicious content; responses are not sanitized for code execution.
- **Man-in-the-middle**: external API traffic uses HTTPS; local HTTP calls use encrypted channels.
- **Insider threat**: developer or maintainer access to backend infrastructure could read production data.
- **Denial of service**: quota exhaustion or AI provider outages.

## Mitigations
- **Local encryption**: secrets stored via FlutterSecureStorage (platform Keychain / Keystore).
- **AI consents**: explicit opt-in required; daily quota enforced; no AI access without consent.
- **HTTPS everywhere**: external APIs use TLS.
- **Local-only fallback**: app degrades gracefully when external services are unavailable.

## Residual Risks
- A rooted / jailbroken device with OS-level access could bypass app-level encryption.
- AI provider outages will degrade AI features; the App falls back to local-only planning.
