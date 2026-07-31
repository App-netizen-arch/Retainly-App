# Privacy Policy

## Overview
Retainly ("the App") is built to help students plan their studies while respecting user privacy. This policy explains what data the App collects, how it is used, and the controls available to you.

## Data We Collect
- **Local device data**: subjects, chapters, tasks, focus sessions, revisions, and preferences are stored primarily in local SQLite/Drift databases on your device.
- **Firebase Authentication**: if you sign in with Google or email, Firebase Auth stores your UID and basic profile (email, display name).
- **Firestore / Cloud Storage**: if cloud sync is enabled, study data is replicated to Firestore under your user ID and binary files are uploaded to Cloud Storage.
- **AI / OCR consents**: if you enable AI features, consent flags and daily quota counters are stored locally and a quota record may be written to Firestore.

## How We Use Data
- To provide core study-planning functionality (tasks, revisions, progress).
- To sync data across devices when cloud sync is enabled.
- To provide AI-generated suggestions when you explicitly opt in.

## Data Sharing
We do not sell your personal data. Third-party processors used by the App:
- **Google (Firebase)**: authentication, database, storage.
- **OpenAI (optional AI provider)**: task breakdowns, quiz generation, flashcard drafts — only when you explicitly enable AI assistance and trigger an AI request. No study data is sent to OpenAI unless you opt in.

## Your Rights & Controls
- You can export all local data at any time from Settings.
- You can delete all data from Settings, which removes local databases and requests deletion of Firestore / Storage data where possible.
- You can disable AI assistance and OCR independently.
- You can clear app data via your device OS settings.

## Contact
For privacy inquiries, contact the developer through the in-app "Report a problem" flow.
