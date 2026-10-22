# Privacy Policy

Last reviewed: 22 October 2026

Retainly is designed to work offline for study planning, saved chat history, explicitly saved memories, textbook indexing and on-device OCR. Retainly does not provide an account backed by a Retainly-operated cloud database, and it does not automatically synchronize app data to a Retainly server.

## Data stored on this device

Retainly stores profile information, subjects, chapters, tasks, revision records, focus sessions, conversation titles and messages, user-approved memories, imported textbook metadata and extracted text in the app's local database or app-private storage.

The user's Groq API key is stored through platform secure storage rather than in the prompt, chat-message rows or exported memory content. The local SQLite database is not SQLCipher-encrypted. Anyone who compromises the device or gains access to the app's private files may be able to access its database.

## On-device OCR

The PDF/image OCR path uses Tesseract and bundled language data. PDF pages are rendered and recognized locally. The OCR step does not upload the original document or its full OCR result. Extracted text is indexed locally so that the app can search relevant passages.

OCR can make mistakes, especially with formulas, subscripts, tables, diagrams and right-to-left or mixed-script pages. Users should verify text against the original.

## Optional online AI processing

Online AI uses the user's Groq API key and requires explicit AI consent. When a user submits a question, Retainly may send to Groq:

- The question the user submitted.
- Recent conversation turns needed to maintain context.
- Relevant memories the user has saved and left enabled.
- Relevant textbook passages retrieved from the local index.

This is online inference, not on-device AI. Do not send material that must never leave the phone. The app uses the key as an authorization header and does not intentionally include it in the prompt body.

Groq's retention behavior is governed by its current terms and provider settings. Users who require Zero Data Retention must enable ZDR in Groq Console → Data Controls for the account associated with their key. Retainly cannot verify that provider-side setting. ZDR does not make inference local and may not prevent processing of all usage metadata. Consult [Groq's data controls](https://console.groq.com/docs/your-data) and the applicable Groq agreement before using the service with sensitive material.

A user's Groq account may have its own usage records, rate limits, billing rules and account data. Users should review Groq's current policies.

## Backups and deletion

Android automatic app-data backup and device-transfer backup are disabled for Retainly's private data. Users may create deliberate encrypted exports. Any destination selected for an export is outside Retainly's control.

The in-app Delete All Data action removes local chat history, saved memories, textbook indexes and study data; clears app preferences; and attempts to remove the Groq key from secure storage. If a key may have been exposed, users should also revoke it through Groq Console.

## Permissions

Camera permission is requested when the user chooses camera scanning. File and image import is user initiated. Local OCR does not require Retainly cloud storage.

## Contact

For privacy questions, use the in-app report-a-problem flow or the project repository issue tracker.
