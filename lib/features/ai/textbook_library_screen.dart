import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../data/repositories/local_ai_repository.dart';

class TextbookLibraryScreen extends StatefulWidget {
  const TextbookLibraryScreen({super.key});

  @override
  State<TextbookLibraryScreen> createState() => _TextbookLibraryScreenState();
}

class _TextbookLibraryScreenState extends State<TextbookLibraryScreen> {
  final LocalAiRepository _repository = LocalAiRepository();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, Object?>> _books = [];
  List<Map<String, Object?>> _matches = [];
  bool _loading = true;
  bool _searching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    try {
      final rows = await _repository.getTextbooks();
      if (!mounted) return;
      setState(() {
        _books = rows;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load the local textbook index.';
      });
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _matches = [];
          _searching = false;
        });
      }
      return;
    }
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final results = await _repository.searchTextbookPassages(query, limit: 30);
      if (!mounted) return;
      setState(() {
        _matches = results;
        _searching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _error = 'Search failed. Try a shorter phrase.';
      });
    }
  }

  Future<void> _openOriginal(Map<String, Object?> book) async {
    final path = book['local_path'] as String? ?? '';
    final title = book['title'] as String? ?? 'Textbook';
    if (path.isEmpty || !await File(path).exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The stored source file is no longer available.')),
        );
      }
      return;
    }
    if (p.extension(path).toLowerCase() == '.pdf') {
      if (mounted) context.push('/pdf', extra: {'path': path, 'title': title});
      return;
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Flexible(
                child: InteractiveViewer(
                  child: Image.file(
                    File(path),
                    errorBuilder: (_, __, ___) => const Text('Could not open this image.'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteBook(Map<String, Object?> book) async {
    final id = book['id'] as int;
    final title = book['title'] as String? ?? 'this textbook';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove textbook?'),
        content: Text('This removes "$title", its local text index and the copy retained inside Retainly. Your original file outside Retainly is not changed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _repository.deleteTextbook(id);
    if (_searchController.text.trim().isNotEmpty) {
      await _search(_searchController.text);
    }
    await _reload();
  }

  Future<void> _openMatch(Map<String, Object?> match) async {
    final id = match['textbook_id'];
    Map<String, Object?>? book;
    for (final candidate in _books) {
      if (candidate['id'] == id) {
        book = candidate;
        break;
      }
    }
    if (book != null) await _openOriginal(book);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My textbook library'),
        actions: [
          IconButton(
            tooltip: 'Import or scan a book',
            onPressed: () => context.push('/ocr'),
            icon: const Icon(Icons.document_scanner_outlined),
          ),
          IconButton(
            tooltip: 'Ask Retainly AI',
            onPressed: () => context.push('/ai/chat'),
            icon: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _books.isEmpty
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: _search,
                      decoration: InputDecoration(
                        labelText: 'Search indexed textbook text',
                        hintText: 'Try a chapter term or concept',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            _search('');
                          },
                          icon: const Icon(Icons.close),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Search runs on this device. It may miss equations or words that OCR misread.',
                      style: TextStyle(fontSize: 12),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: TextStyle(color: colors.error)),
                    ],
                    if (_searching) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(),
                    ],
                    if (_searchController.text.trim().isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text('Passage results', style: Theme.of(context).textTheme.titleLarge),
                      if (_matches.isEmpty && !_searching)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Text('No matching passages. Try another term or confirm that OCR completed.'),
                        ),
                      for (final match in _matches)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.menu_book_outlined),
                            title: Text(
                              '${match['textbook_title'] ?? 'Textbook'} · page ${match['page_number'] ?? '?'}',
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                match['content'] as String? ?? '',
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () => _openMatch(match),
                          ),
                        ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Imported books', style: Theme.of(context).textTheme.titleLarge),
                        ),
                        Text('${_books.length}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_books.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Icon(Icons.menu_book_outlined, size: 36),
                              const SizedBox(height: 8),
                              const Text('Your local library is empty.'),
                              const SizedBox(height: 10),
                              FilledButton.icon(
                                onPressed: () => context.push('/ocr'),
                                icon: const Icon(Icons.add),
                                label: const Text('Import a textbook'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    for (final book in _books)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.menu_book_outlined),
                          title: Text(book['title'] as String? ?? 'Untitled book'),
                          subtitle: Text(
                            '${book['board'] ?? 'Board not set'} • Class ${book['class_level'] ?? '?'} • ${book['subject'] ?? 'Subject not set'}\n${book['page_count'] ?? '?'} pages • ${book['processing_state'] ?? 'imported'}',
                          ),
                          isThreeLine: true,
                          onTap: () => _openOriginal(book),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) {
                              if (action == 'open') _openOriginal(book);
                              if (action == 'remove') _deleteBook(book);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'open', child: Text('Open original')),
                              PopupMenuItem(value: 'remove', child: Text('Remove from Retainly')),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
    );
  }
}
