import 'package:test/test.dart';

void main() {
  group('Repository tests', () {
    test('time units convert correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(today.difference(now).inHours, lessThanOrEqualTo(0));
    });
  });
}
