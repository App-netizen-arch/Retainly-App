# Retainly

Retainly is an offline-first Flutter study companion for Pakistani Matric students. Study plans, revision schedules, focus sessions, chat history, saved memories and textbook indexes are stored locally on the device.

**Online AI is optional, but it is not on-device inference.** When enabled, Retainly sends the user's question and the context needed to answer it to Groq. Retainly does not operate a cloud account or automatic cloud synchronization service.

## Main features

- Local study planning, subjects, chapters, progress and spaced-repetition revision.
- Pomodoro focus sessions and user-initiated encrypted backups.
- Full-screen AI chat with persistent local conversation history.
- User-approved, editable, disableable and deletable local memories.
- Local PDF/image OCR and a page-aware textbook text index.
- Local lexical retrieval of relevant textbook passages for AI prompts.
- Urdu and English tutoring prompts, with experimental language support options for Arabic and Punjabi scripts.

## Online AI through Groq

Retainly calls Groq's official OpenAI-compatible chat-completions API. The current default model is **openai/gpt-oss-120b**, selected for reasoning-heavy tutoring and source-grounded Q&A. This model is an online service: its output quality depends on the available context and may still contain errors.

The user supplies their own Groq API key in Settings. Retainly stores the key in platform secure storage; keys must never be committed to the repository or embedded in an application release. The user is responsible for their Groq account, rate limits and any applicable charges.

To request Groq Zero Data Retention (ZDR), enable it in Groq Console → Data Controls for the account that owns the key. Retainly cannot inspect or verify the provider-side setting. ZDR does not make inference local, and provider usage metadata may still be processed. Consult Groq's current [data controls](https://console.groq.com/docs/your-data).

When Online AI is enabled, the submitted question may be sent along with recent chat turns, relevant saved memories and relevant textbook passages selected from the local index. The app stores chat history and saved memories locally, but the context used for online inference leaves the device.

## OCR and language notes

OCR is performed locally with the Tesseract engine. For searchable PDFs, Retainly first extracts each page's existing text layer with the open-source read_pdf_text plugin; pages without extractable text are rendered locally and passed to Tesseract. A build-time preparation script downloads selected official Tesseract tessdata_fast language models and embeds them in the app bundle, so OCR does not need to download model files at runtime.

The configured models are English (eng), Urdu (urd), Arabic (ara) and Punjabi Gurmukhi (pan). **The Punjabi model is Gurmukhi, not Pakistani Punjabi Shahmukhi.** Urdu-model recognition of Shahmukhi Punjabi is an experimental fallback and must be checked against the original. OCR may also misread equations, subscripts, tables, chemical notation and mixed right-to-left text.

A single OCR job is currently limited to 250 PDF pages. Text extraction and lexical indexing are local. Retrieval quality and the final AI answer are not guaranteed, so users should verify answers and source references against the original book.

Textbook PDFs are not automatically bundled or redistributed by Retainly. Users should import books they are authorized to use. Any future starter-book collection must be cleared for redistribution first.

## Development and builds

Requirements include a compatible Flutter stable SDK, Dart SDK, Android SDK for Android builds, and curl to prepare OCR language data.

Before running checks or building a release, run the OCR-model preparation script, fetch Flutter dependencies, then run dart format, flutter analyze and flutter test. The release script prepares the models before building an APK. The GitHub Actions workflow also prepares the models before checking/building.

The core planner has a Linux desktop build path. The OCR plugins have different platform support; the OCR flow is Android-first and should not be advertised as cross-platform until each target is tested.

## Privacy summary

- Study data, conversations, saved memories and extracted textbook passages are stored locally.
- OCR does not upload the selected document.
- Online AI sends the question and relevant context to Groq when the user submits a request with Online AI enabled.
- Android automatic data backup and device-transfer backup are disabled for private app data.
- Encrypted backups are user initiated; copies exported elsewhere are outside Retainly's control.
- The SQLite database is not SQLCipher-encrypted. App sandboxing and operating-system encryption do not protect against every rooted or compromised-device scenario.
- Delete All Data removes local study data, chats, memories and textbook indexes, and attempts to remove the Groq key from secure storage.

See the [Privacy Policy](docs/legal/privacy_policy.md), [Data Retention Policy](docs/legal/data_retention_policy.md) and [Security Review](docs/SECURITY_REVIEW.md).

## Third-party notices

Retainly is licensed under Apache-2.0. Tesseract trained-data models are sourced from the official tessdata_fast repository. The tesseract_ocr binding and pdfx renderer retain their respective upstream licenses. Verify the licenses and notices of all dependencies and model files before redistributing a release.
