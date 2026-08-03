# Security Review

## Summary
This review documents fixes for security/quality gaps and notes remaining risks.

## Fixed
1. **sync worker data loss**: Fixed outbox processing to apply mutations before marking synced.
2. **PIN brute-force protection**: Implemented rate-limiting in `auth_screen.dart` - 5 failed attempts trigger 30-second lockout using `SharedPreferences`. Lockout counter resets on successful authentication.
3. **Account deletion re-authentication**: Added PIN verification requirement before account deletion in `settings_screen.dart`.
4. **Email validation**: Added format validation in auth screens to prevent invalid email patterns.
5. **Local encrypted backup**: Replaced plain-text JSON backup with AES-256 encrypted local backup system. Backup is OFF by default, user-controlled, and never auto-uploads to cloud. Encryption keys are stored in platform secure storage (Android Keystore).

## Remaining
- **Local DB unencrypted**: Drift/SQLite local database lacks OS-level encryption; sensitive app data is readable if the device is compromised.
- **Offline PIN lockout**: Lockout timing uses `SharedPreferences` which could be reset by clearing app data.

## Recommended Next Steps
- Enable SQLCipher or platform-backed encrypted storage for the local database.
- Add rate-limit rules and app verification for external API calls.
- Consider server-side PIN attempt tracking for more robust brute-force protection.
