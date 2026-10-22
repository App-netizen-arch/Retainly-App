import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/local_ai_repository.dart';

class ExamSimulatorScreen extends StatefulWidget {
  const ExamSimulatorScreen({super.key});

  @override
  State<ExamSimulatorScreen> createState() => _ExamSimulatorScreenState();
}

class _ExamSimulatorScreenState extends State<ExamSimulatorScreen> {
  final LocalAiRepository _repository = LocalAiRepository();
  List<Map<String, Object?>> _books = [];
  int? _selectedBookId;
  int _questionCount = 10;
  int _durationMinutes = 20;
  bool _loading = true;
  bool _starting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _repository.getTextbooks();
      if (!mounted) return;
      setState(() {
        _books = books;
        _selectedBookId ??= books.isEmpty ? null : books.first['id'] as int?;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load your local textbook library.';
      });
    }
  }

  Map<String, Object?>? get _selectedBook {
    for (final book in _books) {
      if (book['id'] == _selectedBookId) return book;
    }
    return null;
  }

  Future<void> _startExam() async {
    final book = _selectedBook;
    final id = _selectedBookId;
    if (book == null || id == null || _starting) return;
    setState(() {
      _starting = true;
      _error = null;
    });

    try {
      final sourceText = await _repository.buildTextbookContextForBook(
        id,
        limit: 14,
      );
      if (sourceText.trim().isEmpty) {
        if (mounted) {
          setState(() {
            _error = 'This book has no indexed text yet. Import it from OCR & Book Import first.';
            _starting = false;
          });
        }
        return;
      }
      final title = '${book['subject'] ?? 'General'} • ${book['title'] ?? 'Textbook'}';
      if (!mounted) return;
      setState(() => _starting = false);
      await context.push(
        '/ai/quiz',
        extra: <String, dynamic>{
          'sourceText': sourceText,
          'sourceTitle': title,
          'questionCount': _questionCount,
          'durationMinutes': _durationMinutes,
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _starting = false;
        _error = 'Could not prepare the exam from this book. Try re-indexing it.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final book = _selectedBook;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam-day simulator'),
        actions: [
          IconButton(
            tooltip: 'Import a textbook',
            onPressed: () => context.push('/ocr'),
            icon: const Icon(Icons.document_scanner_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.timer_outlined, size: 34, color: colors.primary),
                        const SizedBox(height: 8),
                        Text('Practice under exam conditions', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        const Text(
                          'Retainly will build a multiple-choice practice exam from the text indexed for your selected textbook. It runs a countdown and scores submitted answers. AI-generated questions are practice drafts, not official board papers.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (_books.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.menu_book_outlined, size: 36),
                          const SizedBox(height: 8),
                          const Text(
                            'Import a textbook and complete text extraction or OCR before creating a book-grounded exam.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => context.push('/ocr'),
                            icon: const Icon(Icons.add),
                            label: const Text('Import textbook'),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  DropdownButtonFormField<int>(
                    initialValue: _selectedBookId,
                    decoration: const InputDecoration(labelText: 'Textbook', border: OutlineInputBorder()),
                    items: _books.map((row) {
                      final id = row['id'] as int;
                      final title = row['title'] as String? ?? 'Untitled textbook';
                      final subject = row['subject'] as String? ?? 'General';
                      return DropdownMenuItem(
                        value: id,
                        child: Text('$subject — $title', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: _starting
                        ? null
                        : (value) {
                            if (value != null) setState(() => _selectedBookId = value);
                          },
                  ),
                  if (book != null) ...[
                    const SizedBox(height: 10),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.menu_book_outlined),
                        title: Text(book['title'] as String? ?? 'Textbook'),
                        subtitle: Text(
                          '${book['board'] ?? 'Board not set'} • Class ${book['class_level'] ?? '?'} • ${book['subject'] ?? 'Subject not set'}\n${book['page_count'] ?? '?'} pages • ${book['processing_state'] ?? 'imported'}',
                        ),
                        isThreeLine: true,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    initialValue: _questionCount,
                    decoration: const InputDecoration(labelText: 'Question count', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5 questions')),
                      DropdownMenuItem(value: 10, child: Text('10 questions')),
                      DropdownMenuItem(value: 20, child: Text('20 questions')),
                      DropdownMenuItem(value: 30, child: Text('30 questions')),
                    ],
                    onChanged: _starting ? null : (value) {
                      if (value != null) setState(() => _questionCount = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    initialValue: _durationMinutes,
                    decoration: const InputDecoration(labelText: 'Time limit', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 10, child: Text('10 minutes')),
                      DropdownMenuItem(value: 20, child: Text('20 minutes')),
                      DropdownMenuItem(value: 30, child: Text('30 minutes')),
                      DropdownMenuItem(value: 45, child: Text('45 minutes')),
                    ],
                    onChanged: _starting ? null : (value) {
                      if (value != null) setState(() => _durationMinutes = value);
                    },
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _starting ? null : _startExam,
                    icon: _starting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.play_arrow_rounded),
                    label: Text(_starting ? 'Preparing questions…' : 'Start timed exam'),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Card(
                    color: colors.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(_error!, style: TextStyle(color: colors.onErrorContainer)),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Text(
                  'Privacy: selecting a book reads its indexed text locally. If you start the exam with Online AI enabled, the selected text is sent to Groq to generate questions. The original PDF is not uploaded by OCR.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}
