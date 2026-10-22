# Data Retention Policy

## Local app data

Retainly stores study data, conversation history, saved memories, textbook metadata and extracted text in its local database or app-private storage. It persists until the user deletes it in Retainly, clears app data through the operating system, or uninstalls the app.

Retainly does not implement automatic synchronization to a Retainly-operated cloud database. Android automatic app-data backup and device-transfer backup are excluded for Retainly's private data.

## Groq API key

The user's Groq API key is stored in platform secure storage. It persists until the user removes it in Settings, uses Delete All Data successfully, clears app data, or uninstalls the app. If deletion through secure storage fails, the user should remove or revoke the key in Groq Console.

## Online AI requests

When Online AI is enabled, the question and relevant conversation, memory and textbook context are transmitted to Groq for inference. Retainly does not store a second cloud copy of requests on a Retainly-operated backend.

Groq's data retention is governed by its current terms and the key owner's Data Controls. The user must enable ZDR in the Groq account when required; Retainly cannot verify that setting. Usage metadata may still be processed. See [Groq's data controls](https://console.groq.com/docs/your-data).

## OCR and textbook index

OCR runs on-device. Retainly stores document metadata and extracted text in its local index. Deleting a textbook from Retainly removes its metadata and index entries; it does not necessarily delete the original file at its source path. The user remains responsible for the original PDF or image file.

## User-exported backups

Encrypted backups are created only at the user's request. Retainly does not manage or automatically delete copies exported or moved to another service or location.

## Delete All Data

Settings → Delete All Data removes local conversations, memories, textbook index and study records, clears local preferences, and attempts to remove the Groq key from platform secure storage.
