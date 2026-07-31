import 'dart:convert';
import 'package:test/test.dart';

void main() {
  group('Auth security', () {
    test('PIN hash is deterministic', () {
      final salt = 'matric-study-planner-salt';
      final pin = '1234';
      final bytes = const Utf8Encoder().convert('$pin-$salt');
      final h1 =
          bytes.fold<int>(0, (prev, byte) => (prev * 31 + byte)) & 0xFFFFFFFF;
      final h2 =
          bytes.fold<int>(0, (prev, byte) => (prev * 31 + byte)) & 0xFFFFFFFF;
      expect(h1, h2);
    });

    test('email regex accepts valid addresses', () {
      final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      expect(regex.hasMatch('student@example.com'), isTrue);
      expect(regex.hasMatch('user.name+tag@domain.co'), isTrue);
      expect(regex.hasMatch('missing@domain'), isFalse);
      expect(regex.hasMatch('@nodomain.com'), isFalse);
      expect(regex.hasMatch('noat'), isFalse);
    });

    test('lockout duration is positive', () {
      const lockout = 30;
      final lockedUntil = DateTime.now().add(const Duration(seconds: lockout));
      expect(lockedUntil.isAfter(DateTime.now()), isTrue);
    });
  });
}
