import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:file_picker/file_picker.dart';

import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:retainly/core/feature_flags.dart';
import '../../providers/database_provider.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/database_repository.dart';
import '../../data/database_helper.dart';
import '../../services/ai_service.dart';
import '../../services/analytics_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final ValueNotifier<bool> _notificationsEnabled = ValueNotifier(false);

  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _institutionController = TextEditingController();
  final _dailyMinutesController = TextEditingController(text: '120');
  String _selectedLocale = 'en';
  bool _reducedMotion = false;
  bool _dynamicType = false;
  bool _highContrast = false;
  bool _aiAssistance = false;
  bool _ocrScanning = false;
  bool _costWarningAccepted = false;
  int _aiRemainingQuota = 50;
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadLocale();
    _loadAccessibility();
    _loadAiSettings();
    _loadNotificationState();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _selectedLocale = prefs.getString('app_locale') ?? 'en');
  }

  Future<void> _changeLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', locale);
    setState(() => _selectedLocale = locale);
    ref.read(localeProvider.notifier).setLocale(Locale(locale));
  }

  Future<void> _loadAccessibility() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reducedMotion = prefs.getBool('reduced_motion') ?? false;
      _dynamicType = prefs.getBool('dynamic_type') ?? false;
      _highContrast = prefs.getBool('high_contrast') ?? false;
    });
  }

  Future<void> _setReducedMotion(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduced_motion', value);
    setState(() => _reducedMotion = value);
  }

  Future<void> _setDynamicType(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dynamic_type', value);
    setState(() => _dynamicType = value);
  }

  Future<void> _setHighContrast(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast', value);
    setState(() => _highContrast = value);
  }

  Future<void> _loadAiSettings() async {
    final service = AIService();
    final ai = await service.hasAiConsent();
    final ocr = await service.hasOcrConsent();
    final cost = await service.hasAcceptedCostWarning();
    final quota = await service.getAiUsageQuota('local_user');
    if (mounted) {
      setState(() {
        _aiAssistance = ai;
        _ocrScanning = ocr;
        _costWarningAccepted = cost;
        _aiRemainingQuota = quota;
      });
    }
  }

  Future<void> _loadNotificationState() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? false;
    _notificationsEnabled.value = enabled;
  }


  Future<void> _setAiAssistance(bool value) async {
    final service = AIService();
    await service.setAiConsent(value);
    if (mounted) {
      setState(() => _aiAssistance = value);
    }
  }

  Future<void> _setOcrScanning(bool value) async {
    final service = AIService();
    await service.setOcrConsent(value);
    if (mounted) {
      setState(() => _ocrScanning = value);
    }
  }

  Future<void> _acceptCostWarning() async {
    final service = AIService();
    await service.acceptCostWarning();
    if (mounted) {
      setState(() => _costWarningAccepted = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _institutionController.dispose();
    _dailyMinutesController.dispose();
    super.dispose();
  }

  Future<void> _reportProblem() async {
    final controller = TextEditingController();
    if (mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Report a problem'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Describe the issue',
                ),
                maxLines: 4,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Send'),
                ),
              ],
            ),
      );
      if (confirmed == true && controller.text.isNotEmpty) {
        await DatabaseHelper.instance.insertBackupRecord({
          'created_at': DateTime.now().toIso8601String(),
          'destination': 'support:problem',
          'status': controller.text,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted. Thank you.')),
          );
        }
      }
    }
  }

  Future<void> _reportOutdatedContent() async {
    final controller = TextEditingController();
    if (mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Report outdated content'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'What looks wrong?',
                ),
                maxLines: 4,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Send'),
                ),
              ],
            ),
      );
      if (confirmed == true && controller.text.isNotEmpty) {
        await DatabaseHelper.instance.insertBackupRecord({
          'created_at': DateTime.now().toIso8601String(),
          'destination': 'content:report',
          'status': controller.text,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Content report submitted.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      key: _messengerKey,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Account / Student Profile',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _institutionController,
              decoration: const InputDecoration(
                labelText: 'Institution',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _dailyMinutesController,
              decoration: const InputDecoration(
                labelText: 'Default study session duration (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text('Save Profile'),
            ),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.backup_rounded),
            title: const Text('Backup Manager'),
            subtitle: const Text('Local encrypted backup settings and history'),
            onTap: () {
              GoRouter.of(context).push('/backup');
            },
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Appearance & Accessibility',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.brightness_6),
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: isDark,
            onChanged: (v) async {
              final messenger = ScaffoldMessenger.of(context);
              final db = ref.read(databaseRepositoryProvider).value;
              if (db == null) return;
              final profile = await db.getUserProfile();
              if (profile == null || profile.id == null) return;
              final newTheme = v ? 'dark' : 'light';
              final updated = UserModel(
                id: profile.id,
                studentName: profile.studentName,
                studentId: profile.studentId,
                institution: profile.institution,
                classLevel: profile.classLevel,
                board: profile.board,
                examDate: profile.examDate,
                dailyStudyMinutes: profile.dailyStudyMinutes,
                theme: newTheme,
                createdAt: profile.createdAt,
                updatedAt: DateTime.now().toIso8601String(),
              );
              await db.updateUserProfile(updated);
              ref.invalidate(userProfileProvider);
              ref.invalidate(themeModeProvider);
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      v ? 'Dark mode enabled' : 'Light mode enabled',
                    ),
                  ),
                );
              }
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.motion_photos_off),
            title: const Text('Reduced Motion'),
            subtitle: const Text('Minimise animations'),
            value: _reducedMotion,
            onChanged: (v) async {
              await _setReducedMotion(v);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.text_fields),
            title: const Text('Dynamic Type'),
            subtitle: const Text('Scale text for readability'),
            value: _dynamicType,
            onChanged: (v) async {
              await _setDynamicType(v);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.contrast),
            title: const Text('High Contrast'),
            subtitle: const Text('Improve visibility with stronger colours'),
            value: _highContrast,
            onChanged: (v) async {
              await _setHighContrast(v);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(_selectedLocale == 'ur' ? 'Urdu' : 'English'),
            trailing: DropdownButton<String>(
              value: _selectedLocale,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ur', child: Text('Urdu')),
              ],
              onChanged: (v) async {
                if (v == null) return;
                await _changeLocale(v);
              },
            ),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'General Study Preferences',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _notificationsEnabled,
            builder:
                (context, enabled, _) => SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Allow local reminders'),
                  value: enabled,
                  onChanged: (v) async {
                    final messenger = ScaffoldMessenger.of(context);
                    if (!Platform.isAndroid) {
                      if (mounted) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Notifications are not supported on this platform.',
                            ),
                          ),
                        );
                      }
                      return;
                    }
                    if (v) {
                      final status = await Permission.notification.status;
                      if (status.isPermanentlyDenied) {
                        await openAppSettings();
                        return;
                      }
                      final granted = await Permission.notification.request();
                      if (granted.isGranted) {
                        await _notifications.initialize(
                          settings: const InitializationSettings(
                            android: AndroidInitializationSettings(
                              '@mipmap/ic_launcher',
                            ),
                          ),
                        );
                        await _notifications.zonedSchedule(
                          id: 0,
                          title: 'Study Reminder',
                          body: 'Time to focus!',
                          scheduledDate: _nextInstanceOfTenAM(),
                          notificationDetails: const NotificationDetails(
                            android: AndroidNotificationDetails(
                              'study_reminders',
                              'Study Reminders',
                              importance: Importance.max,
                            ),
                          ),
                          androidScheduleMode:
                              AndroidScheduleMode.exactAllowWhileIdle,
                        );
                        _notificationsEnabled.value = true;
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('notifications_enabled', true);
                      }
                    } else {
                      await _notifications.cancel(id: 0);
                      _notificationsEnabled.value = false;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('notifications_enabled', false);
                    }
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            v
                                ? 'Notifications enabled'
                                : 'Notifications disabled',
                          ),
                        ),
                      );
                    }
                  },
                ),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'AI & OCR',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome),
            title: const Text('AI Assistance'),
            subtitle: const Text(
              'Enable AI task breakdown, quizzes, and flashcards',
            ),
            value: _aiAssistance,
            onChanged: (v) async {
              await _setAiAssistance(v);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.document_scanner),
            title: const Text('OCR Scanning'),
            subtitle: const Text('Extract text from PDF documents'),
            value: _ocrScanning,
            onChanged: (v) async {
              await _setOcrScanning(v);
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber_rounded),
            title: const Text('AI Cost Warning'),
            subtitle: Text(_costWarningAccepted ? 'Accepted' : 'Not accepted'),
            trailing:
                !_costWarningAccepted
                    ? ElevatedButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text('AI Usage Costs'),
                                content: const Text(
                                  'AI features use external APIs that may incur costs. '
                                  'Quota: 50 requests per day. Verify AI responses with your textbook.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('I Understand'),
                                  ),
                                ],
                              ),
                        );
                        if (confirmed == true) {
                          await _acceptCostWarning();
                        }
                      },
                      child: const Text('Accept'),
                    )
                    : null,
          ),
          ListTile(
            leading: const Icon(Icons.speed),
            title: const Text('AI Quota Remaining'),
            subtitle: Text('$_aiRemainingQuota / 50 requests today'),
          ),
          ListTile(
            leading: const Icon(Icons.report_problem),
            title: const Text('Hallucination Reports'),
            subtitle: const Text('View and manage AI accuracy reports'),
            onTap: () => GoRouter.of(context).push('/ai/hallucination-reports'),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Performance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
SwitchListTile(
             secondary: const Icon(Icons.speed),
             title: const Text('Performance Monitoring'),
             subtitle: const Text(
               'Track app startup time, render frames, and network requests',
             ),
             value: FeatureFlags.performanceMonitoring,
             onChanged: (v) async {
               await AnalyticsService.instance.setPerformanceCollectionEnabled(
                 v,
               );
               if (mounted) setState(() {});
             },
           ),
           const Divider(height: 32),
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16),
             child: Text(
               'Data Management',
               style: Theme.of(context).textTheme.titleMedium,
             ),
           ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Export to CSV'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final db = ref.read(databaseRepositoryProvider).value;
              if (db == null) return;
              final consent = await _requestThirdPartyExportConsent();
              if (!consent) return;
              final message = await _exportCsv(db);
              if (message == null) return;
              if (mounted) {
                messenger.showSnackBar(SnackBar(content: Text(message)));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export Syllabus Template'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final db = ref.read(databaseRepositoryProvider).value;
              if (db == null) return;
              final message = await _exportSyllabusTemplateWithMetadata(db);
              if (message == null) return;
              if (mounted) {
                messenger.showSnackBar(SnackBar(content: Text(message)));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Import Syllabus Template'),
            onTap: () async {
              final db = ref.read(databaseRepositoryProvider).value;
              if (db == null) return;
              await _importSyllabusTemplateWithMetadata(db);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Template History'),
            subtitle: const Text('View imported templates'),
            onTap: _showTemplateHistory,
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Anki CSV'),
            subtitle: const Text('Anki-compatible flashcard export'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final db = ref.read(databaseRepositoryProvider).value;
              if (db == null) return;
              final message = await _exportAnkiCsv(db);
              if (message == null) return;
              if (mounted) {
                messenger.showSnackBar(SnackBar(content: Text(message)));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Import Anki CSV'),
            subtitle: const Text('Import flashcards from Anki-compatible CSV'),
            onTap: () async {
              final db = ref.read(databaseRepositoryProvider).value;
              if (db == null) return;
              final messenger = ScaffoldMessenger.of(context);
              final message = await _importAnkiCsv(db);
              if (message == null) return;
              if (mounted) {
                messenger.showSnackBar(SnackBar(content: Text(message)));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Import Document'),
            subtitle: const Text('PDF, TXT, MD, DOC, DOCX'),
            onTap: _importDocument,
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Support & Trust',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Report a problem'),
            subtitle: const Text('Send diagnostic info to help fix issues'),
            onTap: _reportProblem,
          ),
          ListTile(
            leading: const Icon(Icons.report_problem),
            title: const Text('Report outdated content'),
            onTap: _reportOutdatedContent,
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.science),
            title: const Text('Practical Records'),
            onTap: () => GoRouter.of(context).push('/practicals'),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap:
                () => showAboutDialog(
                  context: context,
                  applicationName: 'Retainly',
                ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () => GoRouter.of(context).go('/legal/privacy_policy'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            onTap: () => GoRouter.of(context).go('/legal/terms_of_service'),
          ),
          ListTile(
            leading: const Icon(Icons.lock_clock),
            title: const Text('Data Retention Policy'),
            onTap:
                () => GoRouter.of(context).go('/legal/data_retention_policy'),
          ),
          ListTile(
            leading: const Icon(Icons.child_care),
            title: const Text('Age & Minor Policy'),
            onTap: () => GoRouter.of(context).go('/legal/age_minor_policy'),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Threat Model'),
            onTap: () => GoRouter.of(context).go('/legal/threat_model'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete All Local Data',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text(
              'Permanently remove all study data on this device',
            ),
            onTap: _deleteAllData,
          ),
        ],
      ),
    );
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<bool> _requestThirdPartyExportConsent() async {
    if (!FeatureFlags.thirdPartyIntegrations) return false;
    final prefs = await SharedPreferences.getInstance();
    final consent = prefs.getBool('third_party_export_consent') ?? false;
    if (consent) return true;
    if (!mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Third-Party Export Consent'),
            content: const Text(
              'Exporting data to a third-party format means your study data will leave this app and could be opened by external applications. Do you consent to proceed?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('I Understand'),
              ),
            ],
          ),
    );
    if (result == true) {
      await prefs.setBool('third_party_export_consent', true);
      return true;
    }
    return false;
  }

  Future<String?> _exportAnkiCsv(DatabaseRepository db) async {
    final consent = await _requestThirdPartyExportConsent();
    if (!consent) return null;
    final subjects = await db.getSubjects();
    const allChapters = <ChapterModel>[];
    for (final s in subjects) {
      final chapters = await db.getChaptersBySubject(s.id ?? 0);
      allChapters.addAll(chapters);
    }
    final csv = db.exportAnkiCsv(subjects, allChapters);
    final csvBytes = utf8.encode(csv);
    final saveResult = await FilePicker.saveFile(
      dialogTitle: 'Save Anki-compatible CSV',
      fileName: 'anki_export_${DateTime.now().millisecondsSinceEpoch}.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
      bytes: csvBytes,
    );
    if (saveResult == null) return null;
    await File(saveResult).writeAsBytes(csvBytes);
    return 'Exported Anki CSV to $saveResult';
  }

  Future<String?> _importAnkiCsv(DatabaseRepository db) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.isEmpty) return null;
    final file = File(result.files.first.path ?? '');
    if (!await file.exists()) return null;
    final subjects = await db.getSubjects();
    final subjectId = subjects.isNotEmpty ? subjects.first.id ?? 1 : 1;
    final content = await file.readAsString();
    final resources = db.importAnkiCsv(content, subjectId);
    if (resources.isEmpty) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No flashcards found in CSV')),
        );
      }
      return null;
    }
    for (final r in resources) {
      await db.insertResource(ResourceModel.fromMap(r));
    }
    return 'Imported ${resources.length} flashcards from Anki CSV';
  }

  Future<String?> _exportSyllabusTemplateWithMetadata(
    DatabaseRepository db,
  ) async {
    final consent = await _requestThirdPartyExportConsent();
    if (!consent) return null;
    final subjects = await db.getSubjects();
    const allChapters = <ChapterModel>[];
    for (final s in subjects) {
      final chapters = await db.getChaptersBySubject(s.id ?? 0);
      allChapters.addAll(chapters);
    }
    final payload = <String, dynamic>{
      'templateVersion': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'sourceApp': 'retainly',
      'sourceAttribution': 'Retainly',
      'schemaVersion': 1,
      'subjects': subjects.map((s) => s.toMap()).toList(),
      'chapters': allChapters.map((c) => c.toMap()).toList(),
    };
    final payloadBytes = utf8.encode(jsonEncode(payload));
    final saveResult = await FilePicker.saveFile(
      dialogTitle: 'Save syllabus template',
      fileName:
          'syllabus_template_${DateTime.now().millisecondsSinceEpoch}.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: payloadBytes,
    );
    if (saveResult == null) return null;
    await File(saveResult).writeAsBytes(payloadBytes);
    return 'Template exported to $saveResult';
  }

  Future<void> _importSyllabusTemplateWithMetadata(
    DatabaseRepository db,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return;
    final file = File(result.files.first.path ?? '');
    if (!await file.exists()) return;
    final content = await file.readAsString();
    final payload = jsonDecode(content) as Map<String, dynamic>;
    final templateVersion =
        payload['templateVersion'] is int
            ? payload['templateVersion'] as int
            : 1;
    final exportedAt =
        payload['exportedAt'] is String ? payload['exportedAt'] as String : '';
    final sourceApp =
        payload['sourceApp'] is String
            ? payload['sourceApp'] as String
            : 'unknown';
    final sourceAttribution =
        payload['sourceAttribution'] is String
            ? payload['sourceAttribution'] as String
            : '';
    if (templateVersion != 1) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Incompatible template version $templateVersion'),
          ),
        );
      }
      return;
    }
    bool? confirmed;
    if (mounted) {
      confirmed = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Import syllabus template'),
              content: Text(
                'Source: $sourceAttribution\n'
                'App: $sourceApp\n'
                'Exported: $exportedAt\n'
                'Template version: $templateVersion\n\n'
                'This will import subjects and chapters.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Import'),
                ),
              ],
            ),
      );
    }
    if (confirmed != true) return;
    await db.insertSyllabusTemplate(
      SyllabusTemplateModel(
        templateVersion: templateVersion,
        exportedAt: exportedAt,
        sourceApp: sourceApp,
        sourceAttribution: sourceAttribution,
        importedAt: DateTime.now().toIso8601String(),
        content: content,
      ),
    );
    for (final s in payload['subjects'] ?? const []) {
      await db.insertSubject(SubjectModel.fromMap(s));
    }
    for (final c in payload['chapters'] ?? const []) {
      await db.insertChapter(ChapterModel.fromMap(c));
    }
    ref.invalidate(userProfileProvider);
    ref.invalidate(databaseRepositoryProvider);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(allPendingTasksProvider);
    ref.invalidate(dueRevisionsProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(progressMetricsProvider);
    if (mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Syllabus template imported')),
      );
    }
  }

  Future<void> _showTemplateHistory() async {
    final db = ref.read(databaseRepositoryProvider).value;
    if (db == null) return;
    final templates = await db.getSyllabusTemplates();
    if (!mounted) return;
    if (templates.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No imported templates found')),
        );
      }
      return;
    }
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Imported Templates'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: templates.length,
                itemBuilder: (ctx, index) {
                  final t = templates[index];
                  return ListTile(
                    title: Text(
                      t.sourceAttribution.isEmpty
                          ? 'Unknown source'
                          : t.sourceAttribution,
                    ),
                    subtitle: Text(
                      'Version ${t.templateVersion} • Imported ${t.importedAt}',
                    ),
                    isThreeLine: true,
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<String?> _exportCsv(DatabaseRepository db) async {
    final subjects = await db.getSubjects();
    final subjectMap = {for (final s in subjects) s.id!: s.name};
    final tasks = await db.getAllTasks();
    final buffer = StringBuffer();
    buffer.writeln(
      'id,title,subject,type,due_at,scheduled_at,estimated_minutes,completed_minutes,priority,status',
    );
    for (final t in tasks) {
      final subjectName = subjectMap[t.subjectId] ?? '';
      final title = '"${(t.title).replaceAll('"', '""')}"';
      buffer.writeln(
        '${t.id},$subjectName,$title,${t.type},${t.dueAt ?? ''},${t.scheduledAt},${t.estimatedMinutes},${t.completedMinutes},${t.priority},${t.status}',
      );
    }
    final csvBytes = utf8.encode(buffer.toString());
    final saveResult = await FilePicker.saveFile(
      dialogTitle: 'Save exported CSV',
      fileName: 'export.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
      bytes: csvBytes,
    );
    if (saveResult == null) return null;
    await File(saveResult).writeAsBytes(csvBytes);
    return 'Exported CSV to $saveResult';
  }

  Future<String> _getImportDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final importDir = Directory('${dir.path}/retainly_imports');
    if (!await importDir.exists()) {
      await importDir.create(recursive: true);
    }
    return importDir.path;
  }

  Future<void> _importDocument() async {
    final db = ref.read(databaseRepositoryProvider).value;
    if (db == null) return;
    final messenger = ScaffoldMessenger.of(context);

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'md', 'doc', 'docx'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final sourceFile = File(file.path ?? '');
    if (!await sourceFile.exists()) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Source file not found')),
        );
      }
      return;
    }

    const maxFileSizeBytes = 50 * 1024 * 1024;
    final fileSize = await sourceFile.length();
    if (fileSize > maxFileSizeBytes) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'File too large: ${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB. Max allowed is 50 MB.',
            ),
          ),
        );
      }
      return;
    }

    final importDir = await _getImportDirectory();
    final targetPath = p.join(importDir, file.name);
    final targetFile = File(targetPath);
    if (await targetFile.exists()) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('${file.name} already exists. Skipped.')),
        );
      }
      return;
    }

    await sourceFile.copy(targetPath);
    final subjects = await db.getSubjects();
    final subjectId = subjects.isNotEmpty ? subjects.first.id ?? 1 : 1;
    await db.insertResource(
      ResourceModel(
        subjectId: subjectId,
        type: file.extension ?? 'file',
        title: file.name,
        localPath: targetPath,
        createdAt: DateTime.now().toIso8601String(),
        folder: 'Custom Notes',
      ),
    );
    if (mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text('Imported to $targetPath')),
      );
    }
  }

  Future<void> _deleteAllData() async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete all data?'),
            content: const Text(
              'This will permanently delete your profile, tasks, chapters, focus sessions, revisions, resources, and practical records. This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;

    try {
      await _deleteCloudData();
    } on Exception catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cloud deletion failed. Please try again.'),
          ),
        );
      }
      return;
    }

    final rawDb = await DatabaseHelper.instance.database;
    await rawDb.delete('backup_records');
    await rawDb.delete('practical_records');
    await rawDb.delete('resources');
    await rawDb.delete('focus_sessions');
    await rawDb.delete('revision_items');
    await rawDb.delete('study_tasks');
    await rawDb.delete('chapters');
    await rawDb.delete('subjects');
    await rawDb.delete('user_profiles');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    ref.invalidate(userProfileProvider);
    ref.invalidate(databaseRepositoryProvider);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(allPendingTasksProvider);
    ref.invalidate(dueRevisionsProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(progressMetricsProvider);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All local data deleted')));
      GoRouter.of(context).go('/onboarding');
    }
  }

  Future<void> _deleteCloudData() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final collections = [
        'user_profiles',
        'subjects',
        'chapters',
        'study_tasks',
        'focus_sessions',
        'revision_items',
        'resources',
        'practical_records',
        'sync_outbox',
        'sync_tombstones',
        'sync_conflicts',
        'ai_consents',
        'ocr_jobs',
        'ai_requests',
      ];
      for (final collection in collections) {
        try {
          final snapshot = await firestore.collection(collection).get();
          final batch = firestore.batch();
          for (final doc in snapshot.docs) {
            batch.delete(doc.reference);
          }
          if (snapshot.docs.isNotEmpty) {
            await batch.commit();
          }
        } on FirebaseException catch (_) {
          continue;
        }
      }
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      return;
    }
  }

  Future<void> _loadProfile() async {
    final db = ref.read(databaseRepositoryProvider).value;
    if (db == null) return;
    final profile = await db.getUserProfile();
    if (profile == null) return;
    _nameController.text = profile.studentName;
    _studentIdController.text = profile.studentId;
    _institutionController.text = profile.institution;
    _dailyMinutesController.text = profile.dailyStudyMinutes.toString();
  }

  Future<void> _saveProfile() async {
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(databaseRepositoryProvider).value;
    if (db == null) return;
    final profile = await db.getUserProfile();
    if (profile == null || profile.id == null) return;

    final dailyMinutes = int.tryParse(_dailyMinutesController.text) ?? 120;
    final updated = UserModel(
      id: profile.id,
      studentName: _nameController.text.trim(),
      studentId: _studentIdController.text.trim(),
      institution: _institutionController.text.trim(),
      classLevel: profile.classLevel,
      board: profile.board,
      examDate: profile.examDate,
      dailyStudyMinutes: dailyMinutes,
      theme: profile.theme,
      createdAt: profile.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await db.updateUserProfile(updated);
    ref.invalidate(userProfileProvider);
    ref.invalidate(themeModeProvider);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(allPendingTasksProvider);
    ref.invalidate(dueRevisionsProvider);
    ref.invalidate(dashboardProvider);
    if (mounted) {
      messenger.showSnackBar(const SnackBar(content: Text('Profile saved')));
    }
  }
}
