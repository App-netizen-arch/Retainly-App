import 'package:test/test.dart';
import 'package:retainly/core/utils/ai_utils.dart';

void main() {
  group('AiTextSanitizer', () {
    test('sanitize returns empty string for null input', () {
      expect(AiTextSanitizer.sanitize(null), '');
    });

    test('sanitize returns empty string for empty input', () {
      expect(AiTextSanitizer.sanitize(''), '');
    });

    test('sanitize preserves indentation inside fenced code blocks', () {
      final input = 'Some text\n```dart\n  foo();\n  bar();\n```\nMore text';
      final result = AiTextSanitizer.sanitize(input);
      expect(result, contains('```dart'));
      expect(result, contains('  foo();'));
      expect(result, contains('  bar();'));
    });

    test('sanitize strips Draft Response and Review meta-tags', () {
      final input = '**Draft Response**\n**Review needed**\nReal answer here';
      final result = AiTextSanitizer.sanitize(input);
      expect(result, contains('Real answer here'));
      expect(result, isNot(contains('Draft Response')));
      expect(result, isNot(contains('Review needed')));
    });

    test('sanitize preserves markdown bold inside table cells', () {
      final input = '| **Bold** | Normal |';
      final result = AiTextSanitizer.sanitize(input);
      expect(result, contains('Bold'));
      expect(result, contains('Normal'));
    });

    test('sanitize collapses multiple spaces outside code blocks', () {
      final input = 'Hello    world\n```\nkeep   spaces\n```';
      final result = AiTextSanitizer.sanitize(input);
      expect(result, contains('Hello world'));
      expect(result, contains('keep   spaces'));
    });
  });

  group('SubTaskCleaner', () {
    test('clean returns empty string for null input', () {
      expect(SubTaskCleaner.clean(null), '');
    });

    test('clean returns empty string for empty input', () {
      expect(SubTaskCleaner.clean(''), '');
    });

    test('clean preserves pipes in non-table lines', () {
      final input = 'Compare A | B and C';
      final result = SubTaskCleaner.clean(input);
      expect(result, contains('|'));
    });

    test('clean strips pipes in table divider lines', () {
      final input = '| --- | --- |';
      final result = SubTaskCleaner.clean(input);
      expect(result, isNot(contains('|')));
    });

    test('clean strips all heading levels', () {
      expect(SubTaskCleaner.clean('# Heading'), 'Heading');
      expect(SubTaskCleaner.clean('## Heading'), 'Heading');
      expect(SubTaskCleaner.clean('### Heading'), 'Heading');
    });

    test('clean strips number prefixes', () {
      expect(SubTaskCleaner.clean('1. Do task'), 'Do task');
      expect(SubTaskCleaner.clean('2) Do task'), 'Do task');
    });

    test('clean strips bullet prefixes', () {
      expect(SubTaskCleaner.clean('- Do task'), 'Do task');
      expect(SubTaskCleaner.clean('* Do task'), 'Do task');
      expect(SubTaskCleaner.clean('+ Do task'), 'Do task');
    });

    test('clean strips markdown bold', () {
      expect(SubTaskCleaner.clean('**bold text**'), 'bold text');
      expect(SubTaskCleaner.clean('*italic*'), 'italic');
    });

    test('clean collapses multiple spaces', () {
      expect(SubTaskCleaner.clean('hello    world'), 'hello world');
    });
  });
}
