# Threat Model

Last reviewed: 22 October 2026

## Assets
- Local study data in SQLite: profile, subjects, chapters, tasks, revisions and focus sessions.
- Local conversation history and user-approved memories.
- Imported textbooks, OCR output and page-aware passage indexes in app-private storage.
- User-provided Groq API key in platform secure storage.
- User-initiated encrypted backup exports.

## Threats
- **Device loss or compromise:** the SQLite database is not SQLCipher-encrypted. A rooted, debugged or otherwise compromised device may expose local records.
- **Online prompt disclosure:** when Online AI is enabled, the submitted question plus relevant recent turns, saved memories and retrieved textbook passages may be transmitted to Groq.
- **Provider retention:** ZDR is controlled by the account that owns the Groq API key; Retainly cannot verify the setting and usage metadata may still be processed.
- **Prompt injection:** imported books and conversation content are untrusted reference material and might include instructions intended to manipulate an AI response.
- **OCR errors:** incorrectly recognized characters, formulae, tables or right-to-left text can cause wrong study answers.
- **Credential compromise:** a user-owned API key may be exposed if the device or platform secure storage is compromised.
- **Deletion limitations:** Retainly cannot delete files exported by the user to other locations or data handled by a third-party AI provider under its terms.

## Mitigations
- Core study data, chat history, saved memories, textbook indexes and OCR processing are local.
- Android automatic app-data backup and device-transfer backup are disabled for Retainly private data.
- The Groq key is not hard-coded into source or intentionally inserted into the prompt body; it is stored in platform secure storage.
- Online requests require explicit consent, acknowledgement of the online AI disclosure, a key, connectivity and a local request quota.
- System instructions are separated from user question/history/memory/book reference data; retrieved text is labelled as untrusted evidence.
- OCR output and generated textbook answers advise users to verify information against the original page. The assistant must not invent textbook citations.
- SQLite foreign keys are enabled; subject changes archive unselected subjects instead of deleting linked study history.
- Delete All Data removes local chat and memory rows, textbook indexes, study data and preferences, and attempts to remove the Groq key and app-private imported document copies.

## Residual risks
- Groq inference is online, even when ZDR is enabled. Retainly cannot claim all AI processing is on-device.
- SQLite is not SQLCipher-encrypted.
- A local quota is not provider-side billing enforcement.
- OCR and AI may still be wrong. Punjabi Shahmukhi recognition using Urdu model data is experimental; the bundled Punjabi model is for Gurmukhi.
- Secure storage, backup behavior, migrations, low-end-device performance and OCR accuracy still require testing on actual supported Android devices.

## Release checklist
1. Run formatting, static analysis, unit tests and supported platform builds.
2. Test v3-to-v4 database migration against representative user databases.
3. Test Groq key setup/removal, invalid keys, quota, connectivity and account ZDR instructions.
4. Test local chat persistence, search, rename/delete, memory edit/disable/delete and Delete All Data.
5. Benchmark OCR on English, Urdu, Punjabi Shahmukhi, Punjabi Gurmukhi, Arabic, Mathematics and Chemistry pages.
6. Verify upstream OCR model checksums, license notices and actual Android device behavior before store release.
