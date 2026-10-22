# Security Review

Last reviewed: 22 October 2026

## Implemented controls in this branch

- Study data, chat history, saved memories, textbook metadata and extracted passages are stored locally.
- Local AI data tables are created through a SQLite schema migration.
- SQLite foreign-key enforcement is enabled; subject setup archives unselected subjects instead of deleting records referenced by study history.
- Groq API keys are stored through Flutter Secure Storage rather than being hard-coded or stored in chat rows.
- AI requests target Groq's official OpenAI-compatible endpoint; the hard-coded Vercel/OpenRouter proxy path has been removed.
- Retrieved memory and textbook passages are supplied as reference content and explicitly treated as untrusted, not as instructions that override the system prompt.
- OCR uses a local Tesseract engine, and PDF pages are rendered locally.
- Android automatic backup and device-transfer rules exclude private app data.
- Encrypted local backup remains user initiated.

## Known limitations and risks

- Groq inference is online processing. A question, recent chat turns and relevant local memories or textbook passages may be sent to Groq when Online AI is enabled. ZDR is controlled by the key owner's Groq account; Retainly cannot verify that setting.
- The API key is user-provided. Secure storage improves at-rest protection but cannot promise recovery is impossible on a rooted, debugged or compromised device. Never ship a shared developer key inside the app.
- SQLite is not SQLCipher-encrypted.
- Current textbook retrieval is lexical, not semantic. Retrieval quality and citation correctness need evaluation against a representative textbook test set.
- OCR is not guaranteed accurate. The pan model is for Punjabi Gurmukhi, not Shahmukhi; Urdu-based Shahmukhi recognition is experimental. Equations, tables, formulae and right-to-left layout need separate tests.
- OCR language model files are prepared from an upstream release at build time. Model hashes and provenance should be recorded and verified before a store release.
- This OCR implementation is Android-first. Plugin compatibility and behavior have not been validated on every desktop target.
- An OCR job is capped at 250 PDF pages; large books should be processed in manageable parts.
- User-exported backup copies and data sent to a third-party AI provider are outside Retainly's local deletion controls.

## Release checklist

1. Run the model preparation script, fetch dependencies, format, analyze, run tests and complete an Android release build.
2. Pin and verify checksums for each downloaded OCR model before store distribution.
3. Test migration from existing databases to the new schema.
4. Verify subject switching retains chapters, tasks, revisions and focus history.
5. Test Groq key setup/removal, invalid keys, online consent, quota behavior and provider errors.
6. Test chat persistence, memory search/edit/delete/disable and Delete All Data.
7. Benchmark OCR on English, Urdu, Punjabi Shahmukhi, Punjabi Gurmukhi, Arabic, mathematical equations, chemistry notation and photographed pages.
8. Test PDF imports up to and beyond the 250-page processing limit.
9. Validate Android backup exclusions on supported Android versions.
10. Do not advertise fully offline AI: Groq generation remains online even when ZDR is enabled.
