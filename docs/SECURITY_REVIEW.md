# Security Review

## Summary
This review documents fixes for security/quality gaps and notes remaining risks.

## Fixed
1. **sync worker data loss**: `syncWorker` only marked outbox rows as synced without applying changes to Firestore. Now reads `entity`, `entityId`, `operation`, and `data` from each outbox item and applies the mutation to the target collection before marking synced.
2. **PIN brute-force protection**: Implemented rate-limiting in `auth_screen.dart` - 5 failed attempts trigger 30-second lockout using `SharedPreferences`. Lockout counter resets on successful authentication.
3. **Account deletion re-authentication**: Added PIN verification requirement before account deletion in `settings_screen.dart`.
4. **Email validation**: Added format validation in `firebase_auth_screen.dart` to prevent invalid email patterns.
5. **Auth context validation**: Replaced hardcoded `'local_user'` UIDs with `FirebaseAuth.instance.currentUser?.uid` in 6 files to ensure proper authentication context.
6. **Firestore rules hardening**: Added strict owner-based CRUD rules on all collections to ensure users can only read/write their own data.
7. **OCR duplicate suppression**: Added server-side duplicate detection in Cloud Functions to prevent redundant OCR processing.
  8. **Platform guards**: `firebase_options.dart` now throws `UnsupportedError` for web platforms to prevent runtime failures.
  9. **Local encrypted backup**: Replaced plain-text JSON backup with AES-256 encrypted local backup system. Backup is OFF by default, user-controlled, and never auto-uploads to cloud. Encryption keys are stored in platform secure storage (Android Keystore).

## Remaining
- **Local DB unencrypted**: Drift/SQLite local database lacks OS-level encryption; sensitive app data is readable if the device is compromised.
- **Offline PIN lockout**: Lockout timing uses `SharedPreferences` which could be reset by clearing app data.

## Recommended Next Steps
- Enable SQLCipher or platform-backed encrypted storage for the local database.
- Add Firestore rate-limit rules and App Check enforcement.
- Consider server-side PIN attempt tracking for more robust brute-force protection.
