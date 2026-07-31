# Data Retention Policy

## Local Data
- All study data is stored locally on your device by default.
- Data persists until you delete it through the App or your device OS.

## Cloud Data
- When cloud sync is enabled, data is retained in Firestore and Cloud Storage until you delete your account or disable sync.
- Tombstone records are retained for up to 30 days to support conflict resolution, then pruned automatically.

## AI / OCR Data
- AI request logs are retained for quota enforcement and are pruned automatically.
- OCR outputs are stored in Cloud Storage under your user ID and may be deleted via the App or manual storage rules.

## Deletion
- "Delete Account and All Data" in Settings attempts to remove local data and Firestore / Storage documents associated with your user ID.
- Backups are stored where you choose; we do not manage external backup copies.
