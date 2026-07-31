import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/backup_models.dart';
import '../../domain/repositories/backup_scheduler.dart';

class LocalBackupScheduler implements BackupScheduler {
  static const _keyLastBackup = 'local_backup_last_timestamp';
  static const _keyFrequency = 'local_backup_frequency';
  static const _keyLastBackupPath = 'local_backup_last_path';
  static const _keyAutoBackupEnabled = 'local_backup_auto_enabled';
  static const _channelId = 'backup_reminders';
  static const _channelName = 'Backup Reminders';
  static const _channelDescription =
      'Notifications for scheduled backup reminders';
  final FlutterLocalNotificationsPlugin _notifications;
  bool _initialized = false;

  LocalBackupScheduler({FlutterLocalNotificationsPlugin? notifications})
    : _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      const androidInit = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      );
      await _notifications.initialize(
        settings: initSettings,
      );
      _initialized = true;
    } catch (_) {
      // Notification initialization may fail on some platforms; continue without it
      _initialized = true;
    }
  }

  @override
  Future<BackupFrequency> getFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    final index =
        prefs.getInt(_keyFrequency) ?? BackupFrequency.manualOnly.index;
    return BackupFrequency.values[index];
  }

  @override
  Future<void> setFrequency(BackupFrequency frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFrequency, frequency.index);
  }

  @override
  Future<bool> isAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoBackupEnabled) ?? false;
  }

  @override
  Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoBackupEnabled, enabled);
  }

  @override
  Future<DateTime?> getLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getString(_keyLastBackup);
    if (ts == null) return null;
    return DateTime.tryParse(ts);
  }

  @override
  Future<void> recordBackup(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastBackup, DateTime.now().toIso8601String());
    await prefs.setString(_keyLastBackupPath, path);
  }

  @override
  Future<String?> getLastBackupPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastBackupPath);
  }

  @override
  Future<bool> isBackupDue() async {
    final last = await getLastBackupTime();
    if (last == null) return false;
    final freq = await getFrequency();
    final now = DateTime.now();
    switch (freq) {
      case BackupFrequency.manualOnly:
        return false;
      case BackupFrequency.daily:
        return now.difference(last).inHours >= 24;
      case BackupFrequency.weekly:
        return now.difference(last).inDays >= 7;
      case BackupFrequency.monthly:
        return now.difference(last).inDays >= 30;
    }
  }

  @override
  Future<void> checkAndNotify() async {
    if (!await isAutoBackupEnabled()) return;
    if (!await isBackupDue()) return;
    await initialize();
    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.defaultImportance,
        icon: '@mipmap/ic_launcher',
      );
      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );
      await _notifications.show(
        id: 0,
        title: 'Backup Due',
        body: 'Your scheduled backup is due. Tap to create a backup now.',
        notificationDetails: details,
      );
    } catch (_) {
      // Notification may fail on some platforms; ignore
    }
  }

  @override
  Future<void> cancelScheduledNotifications() async {
    await initialize();
    try {
      await _notifications.cancel(id: 0);
      await _notifications.cancelAll();
    } catch (_) {
      // Ignore cancellation failures
    }
  }
}
