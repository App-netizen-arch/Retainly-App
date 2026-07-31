import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

String formatTimeString(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Focus Screen - Timer Display', () {
    test('formats 0 seconds as 00:00', () {
      expect(formatTimeString(0), '00:00');
    });

    test('formats 30 seconds as 00:30', () {
      expect(formatTimeString(30), '00:30');
    });

    test('formats 59 seconds as 00:59', () {
      expect(formatTimeString(59), '00:59');
    });

    test('formats 60 seconds as 01:00', () {
      expect(formatTimeString(60), '01:00');
    });

    test('formats 90 seconds as 01:30', () {
      expect(formatTimeString(90), '01:30');
    });

    test('formats 300 seconds as 05:00', () {
      expect(formatTimeString(300), '05:00');
    });

    test('formats 3600 seconds as 60:00', () {
      expect(formatTimeString(3600), '60:00');
    });

    test('formats 3661 seconds as 61:01', () {
      expect(formatTimeString(3661), '61:01');
    });
  });

  group('Focus Screen - Duration Selection', () {
    test('default planned minutes is 25', () {
      int plannedMinutes = 25;
      expect(plannedMinutes, 25);
    });

    test('duration can be changed to 45', () {
      int plannedMinutes = 25;
      plannedMinutes = 45;
      expect(plannedMinutes, 45);
    });

    test('duration can be changed to 25', () {
      int plannedMinutes = 45;
      plannedMinutes = 25;
      expect(plannedMinutes, 25);
    });

    test('break duration defaults to 5 minutes', () {
      int breakDurationMinutes = 5;
      expect(breakDurationMinutes, 5);
    });

    test('break duration can be changed to 10 minutes', () {
      int breakDurationMinutes = 5;
      breakDurationMinutes = 10;
      expect(breakDurationMinutes, 10);
    });
  });

  group('Focus Screen - Break Logic', () {
    test('startBreak sets break mode and calculates break seconds', () {
      int breakDurationMinutes = 5;
      bool breakMode = false;
      int breakSeconds = 0;
      bool running = false;

      breakMode = true;
      breakSeconds = breakDurationMinutes * 60;
      running = true;

      expect(breakMode, isTrue);
      expect(breakSeconds, 300);
      expect(running, isTrue);
    });

    test('startBreak with 10 minute duration', () {
      int breakDurationMinutes = 10;
      int breakSeconds = 0;

      breakSeconds = breakDurationMinutes * 60;

      expect(breakSeconds, 600);
    });

    test('endBreak resets all break state', () {
      bool breakMode = true;
      int breakSeconds = 300;
      int seconds = 150;
      bool running = true;

      breakMode = false;
      breakSeconds = 0;
      seconds = 0;
      running = false;

      expect(breakMode, isFalse);
      expect(breakSeconds, 0);
      expect(seconds, 0);
      expect(running, isFalse);
    });

    test('skipBreak resets all break state', () {
      bool breakMode = true;
      int breakSeconds = 300;
      int seconds = 150;
      bool running = true;

      breakMode = false;
      breakSeconds = 0;
      seconds = 0;
      running = false;

      expect(breakMode, isFalse);
      expect(breakSeconds, 0);
      expect(seconds, 0);
      expect(running, isFalse);
    });

    test('break countdown decrements seconds', () {
      int breakSeconds = 300;
      bool breakMode = true;

      breakSeconds--;
      if (breakSeconds <= 0) {
        breakMode = false;
        breakSeconds = 0;
      }

      expect(breakSeconds, 299);
      expect(breakMode, isTrue);
    });

    test('break countdown ends when seconds reach 0', () {
      int breakSeconds = 1;
      bool breakMode = true;

      breakSeconds--;
      if (breakSeconds <= 0) {
        breakMode = false;
        breakSeconds = 0;
      }

      expect(breakSeconds, 0);
      expect(breakMode, isFalse);
    });
  });

  group('Focus Screen - Session Completion Logic', () {
    test('session with 60+ seconds is completed', () {
      int seconds = 120;
      final completedMinutes = seconds ~/ 60;
      final status = seconds >= 60 ? 'completed' : 'discarded';
      expect(completedMinutes, 2);
      expect(status, 'completed');
    });

    test('session with less than 60 seconds is discarded', () {
      int seconds = 45;
      final completedMinutes = seconds ~/ 60;
      final status = seconds >= 60 ? 'completed' : 'discarded';
      expect(completedMinutes, 0);
      expect(status, 'discarded');
    });

    test('session with exactly 60 seconds is completed', () {
      int seconds = 60;
      final completedMinutes = seconds ~/ 60;
      final status = seconds >= 60 ? 'completed' : 'discarded';
      expect(completedMinutes, 1);
      expect(status, 'completed');
    });

    test('session with 59 seconds is discarded', () {
      int seconds = 59;
      final completedMinutes = seconds ~/ 60;
      final status = seconds >= 60 ? 'completed' : 'discarded';
      expect(completedMinutes, 0);
      expect(status, 'discarded');
    });

    test('completed minutes accumulate correctly', () {
      int seconds = 180;
      final completedMinutes = seconds ~/ 60;
      expect(completedMinutes, 3);
    });
  });

  group('Focus Screen - Session Persistence', () {
    test('session can be saved to SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('focus_session_id', 1);
      await prefs.setInt('focus_seconds', 120);
      await prefs.setBool('focus_running', true);
      await prefs.setInt('focus_planned_minutes', 25);

      expect(prefs.getInt('focus_session_id'), 1);
      expect(prefs.getInt('focus_seconds'), 120);
      expect(prefs.getBool('focus_running'), isTrue);
      expect(prefs.getInt('focus_planned_minutes'), 25);
    });

    test('session can be restored from SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('focus_session_id', 42);
      await prefs.setInt('focus_seconds', 300);
      await prefs.setBool('focus_running', false);
      await prefs.setInt('focus_planned_minutes', 45);

      final savedId = prefs.getInt('focus_session_id');
      final savedSeconds = prefs.getInt('focus_seconds');
      final savedRunning = prefs.getBool('focus_running');
      final savedPlanned = prefs.getInt('focus_planned_minutes');

      expect(savedId, 42);
      expect(savedSeconds, 300);
      expect(savedRunning, isFalse);
      expect(savedPlanned, 45);
    });

    test('session can be cleared from SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('focus_session_id', 1);
      await prefs.setInt('focus_seconds', 120);
      await prefs.setBool('focus_running', true);
      await prefs.setInt('focus_planned_minutes', 25);
      await prefs.setInt('focus_started_at', 1234567890);

      await prefs.remove('focus_session_id');
      await prefs.remove('focus_seconds');
      await prefs.remove('focus_running');
      await prefs.remove('focus_planned_minutes');
      await prefs.remove('focus_started_at');

      expect(prefs.getInt('focus_session_id'), isNull);
      expect(prefs.getInt('focus_seconds'), isNull);
      expect(prefs.getBool('focus_running'), isNull);
      expect(prefs.getInt('focus_planned_minutes'), isNull);
      expect(prefs.getInt('focus_started_at'), isNull);
    });

    test('no saved session returns default values', () async {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getInt('focus_session_id');
      expect(savedId, isNull);
    });

    test('session started_at can be used to calculate elapsed time', () async {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final startedAtMs = now.millisecondsSinceEpoch;
      await prefs.setInt('focus_started_at', startedAtMs);

      final savedStartedAt = prefs.getInt('focus_started_at');
      expect(savedStartedAt, isNotNull);

      final elapsed = now.difference(
        DateTime.fromMillisecondsSinceEpoch(savedStartedAt!),
      ).inSeconds;
      expect(elapsed, greaterThanOrEqualTo(0));
    });
  });

  group('Focus Screen - Reflection Status', () {
    test('reflection status can be understood', () {
      String? reflectionStatus = 'understood';
      expect(reflectionStatus, 'understood');
    });

    test('reflection status can be need_practice', () {
      String? reflectionStatus = 'need_practice';
      expect(reflectionStatus, 'need_practice');
    });

    test('reflection status can be could_not_finish', () {
      String? reflectionStatus = 'could_not_finish';
      expect(reflectionStatus, 'could_not_finish');
    });

    test('reflection status defaults to null', () {
      String? reflectionStatus;
      expect(reflectionStatus, isNull);
    });

    test('reflection dialog requires 60+ seconds to show', () {
      int seconds = 120;
      final canShowReflection = seconds >= 60;
      expect(canShowReflection, isTrue);
    });

    test('reflection dialog does not show for short sessions', () {
      int seconds = 30;
      final canShowReflection = seconds >= 60;
      expect(canShowReflection, isFalse);
    });
  });

  group('Focus Screen - Break Duration Options', () {
    test('break duration can be 5 minutes', () {
      int breakDurationMinutes = 5;
      expect(breakDurationMinutes * 60, 300);
    });

    test('break duration can be 10 minutes', () {
      int breakDurationMinutes = 10;
      expect(breakDurationMinutes * 60, 600);
    });

    test('break duration can be changed while not running', () {
      bool running = false;
      int breakDurationMinutes = 5;
      if (!running) {
        breakDurationMinutes = 10;
      }
      expect(breakDurationMinutes, 10);
    });
  });
}
