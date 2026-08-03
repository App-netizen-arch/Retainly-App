import 'package:test/test.dart';
import 'package:retainly/data/models/app_models.dart';
import 'package:retainly/data/repositories/database_repository.dart';
import 'package:retainly/data/database_helper.dart';

void main() {
  group('SyllabusTemplateModel', () {
    test('round-trips through toMap/fromMap', () {
      final original = SyllabusTemplateModel(
        templateVersion: 2,
        exportedAt: '2026-07-28T12:00:00Z',
        sourceApp: 'retainly',
        sourceAttribution: 'Retainly v1.0',
        importedAt: '2026-07-28T12:05:00Z',
        content: '{"subjects": []}',
      );
      final restored = SyllabusTemplateModel.fromMap(original.toMap());
      expect(restored.templateVersion, original.templateVersion);
      expect(restored.exportedAt, original.exportedAt);
      expect(restored.sourceAttribution, original.sourceAttribution);
      expect(restored.content, original.content);
    });

    test('defaults templateVersion to 1', () {
      final model = SyllabusTemplateModel(
        exportedAt: '2026-07-28T12:00:00Z',
        content: '{"subjects": []}',
      );
      expect(model.templateVersion, 1);
      expect(model.sourceApp, 'retainly');
    });
  });

  group('Anki CSV export', () {
    test('exports Front,Back,Tags header and rows', () {
      final db = DatabaseRepository(DatabaseHelper.instance);
      final subjects = [
        SubjectModel(
          id: 1,
          name: 'Physics',
          color: 0xFF4CAF50,
          sortOrder: 0,
          createdAt: '2026-01-01',
        ),
      ];
      final chapters = [
        ChapterModel(
          subjectId: 1,
          title: 'Mechanics',
          status: 'not_started',
          priority: 2,
          estimatedMinutes: 30,
          revisionDates: '[]',
          createdAt: '2026-01-01',
        ),
        ChapterModel(
          subjectId: 1,
          title: 'Thermodynamics',
          status: 'not_started',
          priority: 2,
          estimatedMinutes: 30,
          revisionDates: '[]',
          createdAt: '2026-01-02',
        ),
      ];
      final csv = db.exportAnkiCsv(subjects, chapters);
      final lines = csv.split('\n');
      expect(lines.first, 'Front,Back,Tags');
      expect(lines.where((l) => l.isNotEmpty).length, 3);
      expect(lines[1], contains('Mechanics'));
      expect(lines[1], contains('Physics'));
      expect(lines[2], contains('matric'));
    });
  });

  group('Anki CSV import', () {
    test('parses Front,Back,Tags columns into resource maps', () {
      final db = DatabaseRepository(DatabaseHelper.instance);
      final csv =
          'Front,Back,Tags\n"Mechanics","Physics","matric,Physics,Mechanics"\n"Thermodynamics","Physics","matric,Physics,Thermodynamics"\n';
      final resources = db.importAnkiCsv(csv, 1);
      expect(resources.length, 2);
      expect(resources[0]['subject_id'], 1);
      expect(resources[0]['type'], 'flashcard');
      expect(resources[0]['title'], 'Mechanics');
    });

    test('handles empty CSV gracefully', () {
      final db = DatabaseRepository(DatabaseHelper.instance);
      final resources = db.importAnkiCsv('Front,Back,Tags\n', 1);
      expect(resources.length, 0);
    });
  });
}
