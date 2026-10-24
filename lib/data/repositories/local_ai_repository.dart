import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';

/// Local-only persistence for chat history, user-approved memories, and
/// page-aware textbook text. No network access is performed by this class.
class LocalAiRepository {
  LocalAiRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<Database> get _db => _databaseHelper.database;

  Future<int> createConversation({String title = 'New chat'}) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    return db.insert('chat_conversations', {
      'title': _cleanTitle(title),
      'created_at': now,
      'updated_at': now,
      'is_archived': 0,
    });
  }

  Future<List<Map<String, Object?>>> getConversations({
    String search = '',
    int limit = 100,
  }) async {
    final db = await _db;
    final normalized = search.trim();
    return db.query(
      'chat_conversations',
      where: normalized.isEmpty
          ? 'is_archived = 0'
          : 'is_archived = 0 AND title LIKE ?',
      whereArgs: normalized.isEmpty ? null : ['%$normalized%'],
      orderBy: 'updated_at DESC, id DESC',
      limit: limit,
    );
  }

  Future<Map<String, Object?>?> getConversation(int id) async {
    final db = await _db;
    final rows = await db.query(
      'chat_conversations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> renameConversation(int id, String title) async {
    final db = await _db;
    await db.update(
      'chat_conversations',
      {
        'title': _cleanTitle(title),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteConversation(int id) async {
    final db = await _db;
    await db.delete('chat_conversations', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> getMessages(int conversationId) async {
    final db = await _db;
    return db.query(
      'chat_messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'id ASC',
    );
  }

  Future<int> addMessage({
    required int conversationId,
    required String role,
    required String content,
    List<Map<String, Object?>> citations = const [],
  }) async {
    if (!const {'user', 'assistant', 'system'}.contains(role)) {
      throw ArgumentError.value(role, 'role', 'Unsupported chat role.');
    }
    if (content.trim().isEmpty) {
      throw ArgumentError.value(content, 'content', 'Message cannot be empty.');
    }

    final db = await _db;
    final now = DateTime.now().toIso8601String();
    return db.transaction((txn) async {
      final id = await txn.insert('chat_messages', {
        'conversation_id': conversationId,
        'role': role,
        'content': content.trim(),
        'created_at': now,
        'citations_json': citations.isEmpty ? null : jsonEncode(citations),
      });

      final conversationRows = await txn.query(
        'chat_conversations',
        columns: ['title'],
        where: 'id = ?',
        whereArgs: [conversationId],
        limit: 1,
      );
      if (conversationRows.isNotEmpty) {
        final currentTitle =
            conversationRows.first['title'] as String? ?? 'New chat';
        final nextTitle = currentTitle == 'New chat' && role == 'user'
            ? _cleanTitle(content)
            : currentTitle;
        await txn.update(
          'chat_conversations',
          {'title': nextTitle, 'updated_at': now},
          where: 'id = ?',
          whereArgs: [conversationId],
        );
      }
      return id;
    });
  }

  Future<List<Map<String, Object?>>> searchMessages(
    String query, {
    int limit = 100,
  }) async {
    final db = await _db;
    final q = query.trim();
    if (q.isEmpty) return const [];
    return db.rawQuery(
      '''
      SELECT m.id, m.conversation_id, m.role, m.content, m.created_at,
             c.title AS conversation_title
      FROM chat_messages m
      JOIN chat_conversations c ON c.id = m.conversation_id
      WHERE m.content LIKE ? OR c.title LIKE ?
      ORDER BY m.id DESC
      LIMIT ?
      ''',
      ['%$q%', '%$q%', limit],
    );
  }

  Future<String> buildConversationMemoryContext(
    String query, {
    required int excludeConversationId,
    int limit = 4,
  }) async {
    final db = await _db;
    final terms = _terms(query);
    if (terms.isEmpty) return '';

    final predicates = terms
        .take(8)
        .map((_) => 'lower(m.content) LIKE ?')
        .join(' OR ');
    final args = <Object?>[
      ...terms.take(8).map((term) => '%$term%'),
      excludeConversationId,
    ];
    final rows = await db.rawQuery('''
      SELECT m.id, m.conversation_id, m.role, m.content, m.created_at,
             c.title AS conversation_title
      FROM chat_messages m
      JOIN chat_conversations c ON c.id = m.conversation_id
      WHERE ($predicates)
        AND m.conversation_id != ?
        AND m.role IN ('user', 'assistant')
      ORDER BY m.id DESC
      LIMIT 150
      ''', args);

    rows.sort(
      (a, b) => _score(
        b['content'] as String? ?? '',
        terms,
      ).compareTo(_score(a['content'] as String? ?? '', terms)),
    );

    final selected = <Map<String, Object?>>[];
    final seen = <int>{};
    for (final row in rows) {
      final score = _score(row['content'] as String? ?? '', terms);
      if (score == 0) continue;
      final id = row['id'] as int;
      if (!seen.add(id)) continue;
      selected.add(row);
      if (selected.length >= limit) break;
    }
    if (selected.isEmpty) return '';

    final out = StringBuffer();
    for (final row in selected) {
      var content = (row['content'] as String? ?? '').trim();
      if (content.length > 700) content = '${content.substring(0, 700)}…';
      out
        ..writeln(
          'Prior conversation: ${row['conversation_title'] ?? 'Saved chat'}; role: ${row['role']}; date: ${row['created_at'] ?? 'unknown'}.',
        )
        ..writeln(content)
        ..writeln('---');
    }
    return out.toString();
  }

  Future<int> saveMemory({
    required String content,
    String category = 'preference',
    int? sourceConversationId,
  }) async {
    final cleaned = content.trim();
    if (cleaned.isEmpty) {
      throw ArgumentError.value(content, 'content', 'Memory cannot be empty.');
    }
    final now = DateTime.now().toIso8601String();
    final db = await _db;
    return db.insert('user_memories', {
      'content': cleaned,
      'category': _cleanTitle(category),
      'source_conversation_id': sourceConversationId,
      'created_at': now,
      'updated_at': now,
      'last_used_at': null,
      'is_active': 1,
    });
  }

  Future<List<Map<String, Object?>>> getMemories({
    bool includeInactive = false,
  }) async {
    final db = await _db;
    return db.query(
      'user_memories',
      where: includeInactive ? null : 'is_active = 1',
      orderBy: 'updated_at DESC, id DESC',
    );
  }

  Future<void> updateMemory(int id, String content, {String? category}) async {
    final cleaned = content.trim();
    if (cleaned.isEmpty) {
      throw ArgumentError.value(content, 'content', 'Memory cannot be empty.');
    }
    final db = await _db;
    await db.update(
      'user_memories',
      {
        'content': cleaned,
        'updated_at': DateTime.now().toIso8601String(),
        if (category != null) 'category': _cleanTitle(category),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearAllMemories() async {
    final db = await _db;
    return db.delete('user_memories');
  }

  Future<void> deleteMemory(int id) async {
    final db = await _db;
    await db.delete('user_memories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setMemoryActive(int id, bool active) async {
    final db = await _db;
    await db.update(
      'user_memories',
      {
        'is_active': active ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, Object?>>> retrieveRelevantMemories(
    String query, {
    int limit = 6,
  }) async {
    final db = await _db;
    if (limit <= 0) return const [];
    final terms = _terms(query);

    if (terms.isEmpty) {
      return db.query(
        'user_memories',
        where: 'is_active = 1',
        orderBy: 'updated_at DESC, id DESC',
        limit: limit,
      );
    }

    // Learning preferences and ongoing study context should still be available
    // when the user's question doesn't repeat the exact words stored in memory.
    final pinnedLimit = limit < 2 ? limit : 2;
    final pinned = await db.query(
      'user_memories',
      where: "is_active = 1 AND category IN ('preference', 'study context')",
      orderBy: 'updated_at DESC, id DESC',
      limit: pinnedLimit,
    );
    final pinnedIds = pinned.map((row) => row['id']).toSet();

    final where = terms.map((_) => 'lower(content) LIKE ?').join(' OR ');
    final args = terms.map((term) => '%$term%').toList();
    final matches = await db.query(
      'user_memories',
      where: 'is_active = 1 AND ($where)',
      whereArgs: args,
      limit: 100,
    );
    matches.sort(
      (a, b) => _score(
        b['content'] as String? ?? '',
        terms,
      ).compareTo(_score(a['content'] as String? ?? '', terms)),
    );

    final selected = <Map<String, Object?>>[...pinned];
    for (final row in matches) {
      if (pinnedIds.contains(row['id'])) continue;
      selected.add(row);
      if (selected.length >= limit) break;
    }

    final ids = selected.map((row) => row['id'] as int).toList();
    if (ids.isNotEmpty) {
      final now = DateTime.now().toIso8601String();
      await db.rawUpdate(
        'UPDATE user_memories SET last_used_at = ? WHERE id IN (${List.filled(ids.length, '?').join(',')})',
        [now, ...ids],
      );
    }
    return selected;
  }

  Future<int> addTextbook({
    required String title,
    required String localPath,
    String? board,
    String? classLevel,
    String? subject,
    String? edition,
    String language = 'unknown',
    String? checksum,
    int? pageCount,
  }) async {
    final db = await _db;
    return db.insert('textbooks', {
      'title': title.trim(),
      'local_path': localPath,
      'board': board,
      'class_level': classLevel,
      'subject': subject,
      'edition': edition,
      'language': language,
      'checksum': checksum,
      'imported_at': DateTime.now().toIso8601String(),
      'processing_state': 'imported',
      'page_count': pageCount,
    });
  }

  Future<void> updateTextbookState(
    int id,
    String state, {
    int? pageCount,
  }) async {
    final db = await _db;
    await db.update(
      'textbooks',
      {
        'processing_state': state,
        if (pageCount != null) 'page_count': pageCount,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, Object?>>> getTextbooks() async {
    final db = await _db;
    return db.query('textbooks', orderBy: 'title COLLATE NOCASE ASC');
  }

  Future<bool> deleteAllTextbooksAndFiles() async {
    final books = await getTextbooks();
    var allFilesRemoved = true;
    for (final book in books) {
      final id = book['id'];
      if (id is int) {
        try {
          await deleteTextbook(id);
        } catch (_) {
          allFilesRemoved = false;
        }
      }
    }
    return allFilesRemoved;
  }

  Future<void> deleteTextbook(int id) async {
    final db = await _db;
    final rows = await db.query(
      'textbooks',
      columns: ['local_path'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    await db.delete('textbooks', where: 'id = ?', whereArgs: [id]);

    if (rows.isEmpty || rows.first['local_path'] is! String) return;
    final storedPath = p.normalize(
      p.absolute(rows.first['local_path'] as String),
    );
    final appDirectory = await getApplicationDocumentsDirectory();
    final libraryPath = p.normalize(
      p.absolute(p.join(appDirectory.path, 'textbooks')),
    );
    if (p.isWithin(libraryPath, storedPath)) {
      final file = File(storedPath);
      if (await file.exists()) await file.delete();
    }
  }

  Future<void> replaceTextbookChunks(
    int textbookId,
    List<TextbookChunkDraft> chunks,
  ) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(
        'textbook_chunks',
        where: 'textbook_id = ?',
        whereArgs: [textbookId],
      );
      final now = DateTime.now().toIso8601String();
      for (final chunk in chunks) {
        if (chunk.content.trim().isEmpty) continue;
        await txn.insert('textbook_chunks', {
          'textbook_id': textbookId,
          'page_number': chunk.pageNumber,
          'chapter_title': chunk.chapterTitle,
          'heading': chunk.heading,
          'content': chunk.content.trim(),
          'language': chunk.language,
          'extraction_method': chunk.extractionMethod,
          'confidence': chunk.confidence,
          'created_at': now,
        });
      }
      await txn.update(
        'textbooks',
        {'processing_state': 'indexed'},
        where: 'id = ?',
        whereArgs: [textbookId],
      );
    });
  }

  /// Lightweight lexical retrieval. It never uploads book text.
  /// A later iteration can add an on-device semantic embedding index.
  Future<List<Map<String, Object?>>> searchTextbookPassages(
    String query, {
    int limit = 5,
    int? textbookId,
  }) async {
    final db = await _db;
    final terms = _terms(query);
    if (terms.isEmpty) return const [];
    final termsToSearch = terms.take(8).toList();
    final filters = termsToSearch
        .map((_) => 'lower(tc.content) LIKE ?')
        .toList();
    final args = termsToSearch
        .map((term) => '%$term%')
        .cast<Object?>()
        .toList();
    final where = StringBuffer('(${filters.join(' OR ')})');
    if (textbookId != null) {
      where.write(' AND tc.textbook_id = ?');
      args.add(textbookId);
    }
    final rows = await db.rawQuery('''
      SELECT tc.id, tc.textbook_id, tc.page_number, tc.chapter_title,
             tc.heading, tc.content, tc.language, tc.confidence,
             t.title AS textbook_title, t.board, t.class_level, t.subject,
             t.edition
      FROM textbook_chunks tc
      JOIN textbooks t ON t.id = tc.textbook_id
      WHERE $where
      LIMIT 250
      ''', args);
    rows.sort(
      (a, b) => _score(
        b['content'] as String? ?? '',
        terms,
      ).compareTo(_score(a['content'] as String? ?? '', terms)),
    );
    return rows.take(limit).toList();
  }

  Future<String> buildTextbookContextForBook(
    int textbookId, {
    int limit = 12,
    String? focusQuery,
  }) async {
    List<Map<String, Object?>> rows = const [];
    if (focusQuery?.trim().isNotEmpty == true) {
      rows = await searchTextbookPassages(
        focusQuery!,
        limit: limit,
        textbookId: textbookId,
      );
    }

    if (rows.isEmpty) {
      final db = await _db;
      rows = await db.rawQuery(
        '''
        SELECT tc.page_number, tc.chapter_title, tc.heading, tc.content,
               tc.language, t.title AS textbook_title, t.board, t.class_level,
               t.subject, t.edition
        FROM textbook_chunks tc
        JOIN textbooks t ON t.id = tc.textbook_id
        WHERE tc.textbook_id = ?
        ORDER BY tc.page_number ASC, tc.id ASC
        LIMIT ?
        ''',
        [textbookId, limit],
      );
    }
    if (rows.isEmpty) return '';

    final out = StringBuffer();
    if (focusQuery?.trim().isNotEmpty == true) {
      out
        ..writeln('Requested focus topics: ${focusQuery!.trim()}')
        ..writeln(
          'Prefer these topics when writing practice questions, but only use facts supported by the passages below.',
        )
        ..writeln();
    }
    for (final row in rows) {
      final title = row['textbook_title'] ?? 'Untitled textbook';
      final subject = row['subject'] ?? 'Unknown subject';
      final chapter =
          row['chapter_title'] ?? row['heading'] ?? 'Unlabelled section';
      final page = row['page_number'] ?? '?';
      out
        ..writeln(
          'Source: $title; board: ${row['board'] ?? 'not specified'}; class: ${row['class_level'] ?? 'not specified'}; subject: $subject; chapter/section: $chapter; page: $page.',
        )
        ..writeln(row['content'])
        ..writeln('---');
    }
    return out.toString();
  }

  Future<String> buildTextbookContext(String query, {int limit = 5}) async {
    final passages = await searchTextbookPassages(query, limit: limit);
    if (passages.isEmpty) return '';
    final out = StringBuffer();
    for (final passage in passages) {
      final title = passage['textbook_title'] ?? 'Untitled textbook';
      final subject = passage['subject'] ?? 'Unknown subject';
      final chapter =
          passage['chapter_title'] ??
          passage['heading'] ??
          'Unlabelled section';
      final page = passage['page_number'] ?? '?';
      out
        ..writeln(
          'Source: $title; subject: $subject; chapter/section: $chapter; page: $page.',
        )
        ..writeln(passage['content'])
        ..writeln('---');
    }
    return out.toString();
  }

  static String _cleanTitle(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) return 'New chat';
    return normalized.length > 90 ? normalized.substring(0, 90) : normalized;
  }

  static List<String> _terms(String query) {
    return query
        .toLowerCase()
        .replaceAll(
          RegExp(
            r'[^a-z0-9\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\u0A00-\u0A7F\s]',
          ),
          ' ',
        )
        .split(RegExp(r'\s+'))
        .where((term) => term.length >= 3)
        .toSet()
        .toList();
  }

  static int _score(String text, List<String> terms) {
    final lower = text.toLowerCase();
    var score = 0;
    for (final term in terms) {
      if (lower.contains(term)) score += 1;
    }
    return score;
  }
}

class TextbookChunkDraft {
  const TextbookChunkDraft({
    required this.pageNumber,
    required this.content,
    this.chapterTitle,
    this.heading,
    this.language = 'unknown',
    this.extractionMethod = 'pdf_text',
    this.confidence,
  });

  final int pageNumber;
  final String content;
  final String? chapterTitle;
  final String? heading;
  final String language;
  final String extractionMethod;
  final double? confidence;
}
