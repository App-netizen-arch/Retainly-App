# Retainly

A production-ready Flutter study planner. Built with Flutter, Riverpod, GoRouter, Firebase, and Drift.

## Features

- **Study Planning**: Task scheduling, chapter tracking, daily plan generation
- **Focus Sessions**: Pomodoro-style focus tracking with native Android Do Not Disturb (DND) mode via custom Platform Channels
- **Revision Queue**: Spaced repetition with 1/3/7-day intervals
- **AI Assistance**: Optional AI task breakdown, quizzes, and flashcards (online-only, fails gracefully offline)
- **OCR Scanning**: Extract text from PDFs via secure Cloud Functions proxy (online-only)
- **Import/Export**: Encrypted local backup, CSV export, Anki CSV, syllabus templates
- **Offline-first**: Local SQLite/Drift with optional cloud sync; works completely without Firebase
- **Background Sync**: 15-minute periodic background sync via Workmanager with battery and network constraints

## Platforms

- Android (primary)
- Linux desktop

## Getting Started

### Prerequisites

- Flutter SDK 3.24.0+
- Dart SDK 3.7.0+
- Firebase project (see `FIREBASE_BACKEND_SETUP.md`)

### Installation

```bash
flutter pub get
```

### Running

```bash
flutter run -d linux
```

### Testing

```bash
flutter analyze
flutter test
```

## Build & Release

### Build Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build Release App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

### Sign the APK (optional but recommended for production)

1. Generate a keystore:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Update `android/app/build.gradle.kts` signing configs section
3. Add `keystore.properties` to `android/` (gitignored) with:
   ```properties
   storePassword=YOUR_STORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```
4. Rebuild.

### Physical Device Testing

- Connect an Android phone via USB with USB debugging enabled
- Run `flutter devices` to confirm the device is listed
- Run `flutter run -d <device-id> --release` for a release-mode test run
- For Linux desktop: `flutter run -d linux`

## CI/CD

GitHub Actions workflow (`.github/workflows/ci.yml`) runs on push to `main`/`develop` and PRs:
- `flutter analyze` and `flutter test`
- Android debug APK build
- Linux release build

## Documentation

- `FIREBASE_BACKEND_SETUP.md` — Firebase project setup, AI provider configuration, and security rules deployment
- `docs/legal/` — Privacy Policy, Terms of Service, Data Retention, Threat Model
- `docs/SECURITY_REVIEW.md` — Security audit trail and remaining risks

## Architecture

- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local Database**: SQLite (sqflite) + Drift
- **Native Bridge**: Custom Android Platform Channels (`focus_shield`) for Do Not Disturb mode
- **Background Processing**: Workmanager with battery and network constraints for periodic sync
- **Backend**: Firebase (Auth, Firestore, Storage, Functions) with strict owner-based Firestore security rules
- **AI Backend**: Cloud Functions proxy to OpenAI (extensible to Anthropic/Gemini) — optional online feature
- **Notifications**: Local notifications via `flutter_local_notifications`; no FCM push servers required

## License

See `docs/legal/terms_of_service.md`.
