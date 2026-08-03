import 'dart:async';
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../providers/database_provider.dart';
import '../../data/models/app_models.dart';

const _focusShieldChannel = MethodChannel('focus_shield');

class FocusScreen extends ConsumerStatefulWidget {
  final int? taskId;
  const FocusScreen({super.key, this.taskId});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen>
    with WidgetsBindingObserver {
  int _seconds = 0;
  bool _running = false;
  int _plannedMinutes = 25;
  Timer? _timer;
  int? _sessionId;
  final _notesController = TextEditingController();
  final _parkingLotController = TextEditingController();
  String? _reflectionStatus;
  bool _breakMode = false;
  int _breakSeconds = 0;
  int _breakDurationMinutes = 5;
  bool _focusShieldEnabled = false;
  FlutterLocalNotificationsPlugin? _focusNotifications;
  static const _focusShieldChannelId = 'focus_shield';
  static const _focusShieldNotificationId = 2001;

  @override
  void initState() {
    super.initState();
    _plannedMinutes = 25;
    WidgetsBinding.instance.addObserver(this);
    _restoreSession();
    _checkFocusShield();
  }

  Future<void> _checkFocusShield() async {
    _focusNotifications ??= FlutterLocalNotificationsPlugin();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    try {
      await _focusNotifications!.initialize(
        settings: settings,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    if (_running && _sessionId != null) {
      final db = ref.read(databaseRepositoryProvider).value;
      if (db != null) {
        db.updateFocusSession(_sessionId!, {
          'status': 'discarded',
          'ended_at': DateTime.now().toIso8601String(),
        }).catchError((_) {
          return 0;
        });
      }
      _clearSavedSession().catchError((_) {});
    }
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _notesController.dispose();
    _parkingLotController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _running && _sessionId != null) {
      _saveSession();
    }
    if (state == AppLifecycleState.resumed) {
      _restoreSession();
    }
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('focus_session_id', _sessionId ?? 0);
    await prefs.setInt('focus_seconds', _seconds);
    await prefs.setBool('focus_running', _running);
    await prefs.setInt('focus_planned_minutes', _plannedMinutes);
    if (_running && !_breakMode) {
      await prefs.setInt(
        'focus_started_at',
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getInt('focus_session_id');
    if (savedId != null && savedId != 0) {
      _sessionId = savedId;
      _seconds = prefs.getInt('focus_seconds') ?? 0;
      _running = prefs.getBool('focus_running') ?? false;
      _plannedMinutes = prefs.getInt('focus_planned_minutes') ?? 25;
      if (_running && _sessionId != null) {
        final startedAtMs = prefs.getInt('focus_started_at');
        if (startedAtMs != null) {
          final elapsed =
              DateTime.now()
                  .difference(DateTime.fromMillisecondsSinceEpoch(startedAtMs))
                  .inSeconds;
          _seconds += elapsed > 0 ? elapsed : 0;
          await prefs.setInt(
            'focus_started_at',
            DateTime.now().millisecondsSinceEpoch,
          );
        }
        final db = ref.read(databaseRepositoryProvider).value;
        if (db != null) {
          final session = await db.getActiveFocusSession();
          if (session != null && session.id == _sessionId) {
            _timer?.cancel();
            _timer = Timer.periodic(const Duration(seconds: 1), (_) {
              if (mounted) setState(() => _seconds++);
            });
          } else {
            await _clearSavedSession();
            _sessionId = null;
            _running = false;
            _seconds = 0;
          }
        } else {
          await _clearSavedSession();
          _sessionId = null;
          _running = false;
          _seconds = 0;
        }
      }
    }
  }

  Future<void> _clearSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('focus_session_id');
    await prefs.remove('focus_seconds');
    await prefs.remove('focus_running');
    await prefs.remove('focus_planned_minutes');
    await prefs.remove('focus_started_at');
  }

  Future<void> _toggleTimer() async {
    if (!_running && _sessionId == null) {
      final db = ref.read(databaseRepositoryProvider).value;
      if (db == null) return;
      final active = await db.getActiveFocusSession();
      if (active != null) {
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Finish the active focus session first.'),
            ),
          );
        }
        return;
      }
      final now = DateTime.now();
      final newSessionId = await db.insertFocusSession(
        FocusSessionModel(
          taskId: widget.taskId,
          startedAt: now.toIso8601String(),
          plannedMinutes: _plannedMinutes,
          status: 'running',
          createdAt: now.toIso8601String(),
        ),
      );
_sessionId = newSessionId;
       _saveSession();
     }
    setState(() => _running = !_running);
    if (_running) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _seconds++);
      });
    } else {
      _timer?.cancel();
      _saveSession();
    }
  }

  void _selectDuration(int minutes) {
    setState(() => _plannedMinutes = minutes);
  }

  String get _timeString {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _finishSession() async {
    _timer?.cancel();
    _running = false;
    final completedMinutes = _seconds ~/ 60;
    final endedAt = DateTime.now();
    final db = ref.read(databaseRepositoryProvider).value;
    bool success = false;
    if (db != null && _sessionId != null) {
      try {
        await db.updateFocusSession(_sessionId!, {
          'ended_at': endedAt.toIso8601String(),
          'completed_minutes': completedMinutes,
          'status': _seconds >= 60 ? 'completed' : 'discarded',
          'notes':
              _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
          'reflection_status': _reflectionStatus,
          'parking_lot_notes':
              _parkingLotController.text.trim().isEmpty
                  ? null
                  : _parkingLotController.text.trim(),
        });
        if (widget.taskId != null && completedMinutes > 0) {
          final task = await db.getTaskById(widget.taskId!);
          if (task != null) {
            final newCompleted = task.completedMinutes + completedMinutes;
            await db.updateTask(widget.taskId!, {
              'completed_minutes': newCompleted,
              'status': task.status,
              'updated_at': endedAt.toIso8601String(),
            });
            ref.invalidate(todayTasksProvider);
            ref.invalidate(allPendingTasksProvider);
          }
        }
        success = true;
      } catch (e) {
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Failed to save session. Please try again.'),
            ),
          );
        }
      }
    }
    if (success) {
      _sessionId = null;
      await _clearSavedSession();
    }
    if (!mounted) return;
      if (completedMinutes >= 60) {
        _startBreak();
      } else {
        setState(() {
          _seconds = 0;
          _notesController.clear();
          _parkingLotController.clear();
          _reflectionStatus = null;
        });
        if (GoRouter.of(context).canPop()) {
          GoRouter.of(context).pop();
        }
      }
    }

  void _startBreak() {
    setState(() {
      _breakMode = true;
      _breakSeconds = _breakDurationMinutes * 60;
      _running = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _breakSeconds--;
        _seconds = _breakSeconds;
      });
      if (_breakSeconds <= 0) {
        _endBreak();
      }
    });
  }

  void _endBreak() {
    _timer?.cancel();
    setState(() {
      _breakMode = false;
      _breakSeconds = 0;
      _seconds = 0;
      _running = false;
      _notesController.clear();
      _parkingLotController.clear();
      _reflectionStatus = null;
    });
    if (mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Break is over. Ready to focus again?'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _skipBreak() {
    _timer?.cancel();
    setState(() {
      _breakMode = false;
      _breakSeconds = 0;
      _seconds = 0;
      _running = false;
      _notesController.clear();
      _parkingLotController.clear();
      _reflectionStatus = null;
    });
  }

  Future<void> _showFocusShieldNotification() async {
    _focusNotifications ??= FlutterLocalNotificationsPlugin();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    try {
      await _focusNotifications!.initialize(
        settings: settings,
      );
    } catch (_) {}
    const androidDetails = AndroidNotificationDetails(
      _focusShieldChannelId,
      'Focus Shield',
      channelDescription: 'Silences distractions during focus sessions',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: true,
      silent: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentSound: false,
      presentBadge: false,
      presentAlert: false,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    try {
      await _focusNotifications!.show(
        id: _focusShieldNotificationId,
        title: 'Focus Session Active',
        body: 'Tap to return to your session',
        notificationDetails: details,
        payload: 'focus_session',
      );
    } catch (_) {}
  }

  Future<void> _cancelFocusShieldNotification() async {
    try {
      await _focusNotifications?.cancel(id: _focusShieldNotificationId);
    } catch (_) {}
  }

  Future<void> _toggleFocusShield(bool value) async {
    setState(() => _focusShieldEnabled = value);
    if (value) {
      if (Platform.isAndroid) {
        try {
          final success = await _focusShieldChannel.invokeMethod<bool>(
            'toggleFocusShield',
            {'enable': true},
          );
          if (success == true) {
            if (mounted) {
              final messenger = ScaffoldMessenger.of(context);
              messenger.hideCurrentSnackBar();
              messenger.showSnackBar(
                const SnackBar(content: Text('Focus Shield enabled')),
              );
            }
            return;
          }
        } on PlatformException catch (_) {
          // native toggle unavailable, fall through to notification
        }
      }
      if (Platform.isIOS) {
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Enable Focus Mode manually in Settings > Focus to silence notifications.',
              ),
            ),
          );
        }
        return;
      }
      await _showFocusShieldNotification();
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Focus Shield active. Grant notification access for best results.',
            ),
          ),
        );
      }
    } else {
      await _cancelFocusShieldNotification();
      if (Platform.isAndroid) {
        try {
          await _focusShieldChannel.invokeMethod<bool>(
            'toggleFocusShield',
            {'enable': false},
          );
        } on PlatformException catch (_) {}
      }
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(content: Text('Focus Shield disabled')),
        );
      }
    }
  }

  Future<void> _showReflectionDialog() async {
    if (_seconds < 60) {
      await _finishSession();
      return;
    }
    if (!mounted) return;
    String? selected = _reflectionStatus;
    final result = await showDialog<String>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setDialogState) {
              return AlertDialog(
                title: const Text('How did this session go?'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Radio<String>(
                        value: 'understood',
                        groupValue: selected,
                        onChanged: (v) => setDialogState(() => selected = v),
                      ),
                      title: const Text('Understood it'),
                      onTap:
                          () => setDialogState(() => selected = 'understood'),
                    ),
                    ListTile(
                      leading: Radio<String>(
                        value: 'need_practice',
                        groupValue: selected,
                        onChanged: (v) => setDialogState(() => selected = v),
                      ),
                      title: const Text('Need more practice'),
                      onTap:
                          () =>
                              setDialogState(() => selected = 'need_practice'),
                    ),
                    ListTile(
                      leading: Radio<String>(
                        value: 'could_not_finish',
                        groupValue: selected,
                        onChanged: (v) => setDialogState(() => selected = v),
                      ),
                      title: const Text('Could not finish'),
                      onTap:
                          () => setDialogState(
                            () => selected = 'could_not_finish',
                          ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed:
                        selected == null
                            ? null
                            : () {
                              _reflectionStatus = selected;
                              Navigator.pop(ctx, selected);
                            },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          ),
    );
    if (result != null) {
      await _finishSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_running,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _running) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('End focus session?'),
              content: const Text(
                'Your current focus session will be discarded if you leave now.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('End Session'),
                ),
              ],
            ),
          );
          if (confirmed == true && mounted) {
            await _finishSession();
          }
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: _breakMode ? 'Break Time' : 'Focus Session',
          child: Text(_breakMode ? 'Break Time' : 'Focus Session'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                label: 'Timer $_timeString',
                child: Text(
                  _timeString,
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_breakMode)
                Text(
                  'Take a breather. Come back refreshed.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              if (_breakMode) const SizedBox(height: 24),
              if (!_breakMode) ...[
                if (Platform.isAndroid || Platform.isIOS)
                  SwitchListTile(
                    secondary: const Icon(
                      Icons.do_not_disturb_on_total_silence,
                    ),
                    title: const Text('Focus Shield'),
                    subtitle: const Text('Reduce distractions during session'),
                    value: _focusShieldEnabled,
                    onChanged: _toggleFocusShield,
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Session notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: _parkingLotController,
                    decoration: const InputDecoration(
                      labelText: 'Parking lot (distractions)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 16),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 25, label: Text('25 min')),
                    ButtonSegment(value: 45, label: Text('45 min')),
                  ],
                  onSelectionChanged: (Set<int> selection) {
                    _selectDuration(selection.first);
                  },
                  selected: {_plannedMinutes},
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Semantics(
                      button: true,
                      label:
                          _running
                              ? 'Pause focus session'
                              : 'Start focus session',
                      child: ElevatedButton(
                        onPressed: _toggleTimer,
                        child: Text(_running ? 'Pause' : 'Start'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Semantics(
                      button: true,
                      label: 'Finish focus session',
                      child: ElevatedButton(
                        onPressed: _showReflectionDialog,
                        child: const Text('Finish'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 5, label: Text('5 min')),
                    ButtonSegment(value: 10, label: Text('10 min')),
                  ],
                  onSelectionChanged: (Set<int> selection) {
                    if (!_running) {
                      setState(() => _breakDurationMinutes = selection.first);
                    }
                  },
                  selected: {_breakDurationMinutes},
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed:
                          _breakMode && _breakSeconds <= 0 ? null : _skipBreak,
                      child: const Text('Skip Break'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed:
                          _breakMode && _breakSeconds <= 0
                              ? () {
                                _endBreak();
                                if (mounted && GoRouter.of(context).canPop()) {
                                  GoRouter.of(context).pop();
                                }
                              }
                              : null,
                     child: const Text('Done'),
                  ),
                ],
              ),
            ],
          ],
        ),
        ),
      ),
      ),
    );
  }
}
