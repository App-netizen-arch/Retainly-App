import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/ai_service.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  final String sourceText;
  final String sourceTitle;

  const FlashcardScreen({
    super.key,
    required this.sourceText,
    required this.sourceTitle,
  });

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  List<Flashcard> _flashcards = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _knownCount = 0;
  int _unknownCount = 0;
  bool _loading = false;
  String? _error;
  String _sourceRef = '';
  final TextEditingController _sourceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateFlashcards();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _generateFlashcards() async {
    final service = AIService();
    final gate = await service.checkAiGate('local_user');
    if (gate != null) {
      setState(() => _error = gate);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final userId = 'local_user';
    try {
      final result = await service.generateFlashcards(
        userId,
        widget.sourceText,
      );
      if (!mounted) return;
      if (result == null || result.startsWith('AI_ERROR:')) {
        final message = result != null && result.startsWith('AI_ERROR:')
            ? result.substring('AI_ERROR:'.length).trim()
            : result;
        setState(() {
          _error = message ?? 'Failed to generate flashcards.';
          _loading = false;
        });
        return;
      }
      final cards = _parseFlashcards(result);
      setState(() {
        _flashcards = cards;
        _currentIndex = 0;
        _isFlipped = false;
        _knownCount = 0;
        _unknownCount = 0;
        _loading = false;
      });
    } on Exception catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Generation failed. Please try again.';
        _loading = false;
      });
    }
  }

  List<Flashcard> _parseFlashcards(String result) {
    final cards = <Flashcard>[];
    final lines = result.split('\n').where((l) => l.trim().isNotEmpty).toList();
    String? currentQuestion;
    String? currentAnswer;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final withoutNumber = trimmed.replaceAll(RegExp(r'^\d+[\.\)]\s*'), '');
      final parts = withoutNumber.split('/');
      if (parts.length >= 2) {
        currentQuestion = parts[0].trim();
        currentAnswer = parts.sublist(1).join('/').trim();
        cards.add(Flashcard(question: currentQuestion, answer: currentAnswer));
        currentQuestion = null;
        currentAnswer = null;
      } else if (withoutNumber.toLowerCase().startsWith('q:') ||
          withoutNumber.toLowerCase().startsWith('question:')) {
        currentQuestion =
            withoutNumber.replaceFirst(RegExp(r'^[Qq]?:?\s*'), '').trim();
      } else if (withoutNumber.toLowerCase().startsWith('a:') ||
          withoutNumber.toLowerCase().startsWith('answer:')) {
        currentAnswer =
            withoutNumber.replaceFirst(RegExp(r'^[Aa]?:?\s*'), '').trim();
        if (currentQuestion != null) {
          final question = currentQuestion;
          cards.add(Flashcard(question: question, answer: currentAnswer));
          currentQuestion = null;
          currentAnswer = null;
        }
      } else if (currentQuestion != null && currentAnswer == null) {
        currentAnswer = trimmed;
        cards.add(Flashcard(question: currentQuestion, answer: currentAnswer));
        currentQuestion = null;
        currentAnswer = null;
      }
    }

    if (cards.isEmpty) {
      cards.add(Flashcard(question: result, answer: ''));
    }
    return cards;
  }

  void _flipCard() {
    setState(() => _isFlipped = !_isFlipped);
  }

  void _markKnown() {
    setState(() {
      _knownCount++;
      _isFlipped = false;
      if (_currentIndex < _flashcards.length - 1) {
        _currentIndex++;
      }
    });
  }

  void _markUnknown() {
    setState(() {
      _unknownCount++;
      _isFlipped = false;
      if (_currentIndex < _flashcards.length - 1) {
        _currentIndex++;
      }
    });
  }

  Future<void> _saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getString('flashcard_results') ?? '[]';
    List<dynamic> existing = [];
    try {
      existing = const JsonDecoder().convert(existingJson) as List<dynamic>;
    } catch (_) {}
    existing.add({
      'sourceTitle': widget.sourceTitle,
      'totalCards': _flashcards.length,
      'knownCount': _knownCount,
      'unknownCount': _unknownCount,
      'completedAt': DateTime.now().toIso8601String(),
      'sourceRef': _sourceRef,
    });
    await prefs.setString(
      'flashcard_results',
      const JsonEncoder().convert(existing),
    );
  }

  Future<void> _attachSource() async {
    _sourceController.clear();
    final ref = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Attach Source'),
            content: TextField(
              controller: _sourceController,
              decoration: const InputDecoration(
                hintText: 'Textbook reference, page, etc.',
              ),
              onSubmitted: (v) => Navigator.pop(ctx, v),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx, _sourceController.text.trim());
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
    if (ref != null && mounted) {
      setState(() => _sourceRef = ref);
    }
  }

  Future<void> _reportError() async {
    final service = AIService();
    await service.reportHallucination(
      'local_user',
      'flashcard_${widget.sourceTitle}',
      'User reported incorrect flashcard content',
    );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report submitted')));
    }
  }

  Future<void> _showReviewHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getString('flashcard_results') ?? '[]';
    List<dynamic> existing = [];
    try {
      existing = const JsonDecoder().convert(existingJson) as List<dynamic>;
    } catch (_) {}
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Review History'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child:
                  existing.isEmpty
                      ? const Center(child: Text('No history yet'))
                      : ListView.builder(
                        itemCount: existing.length,
                        itemBuilder: (context, index) {
                          final item = existing[index] as Map<String, dynamic>;
                          final completedAt =
                              item['completedAt'] as String? ?? '';
                          final known = item['knownCount'] as int? ?? 0;
                          final total = item['totalCards'] as int? ?? 0;
                          final score =
                              total > 0
                                  ? '${((known / total) * 100).round()}%'
                                  : 'N/A';
                          return ListTile(
                            title: Text(
                              item['sourceTitle'] as String? ?? 'Unknown',
                            ),
                            subtitle: Text(
                              'Score: $score ($known/$total known)\n'
                              'Completed: ${completedAt.substring(0, completedAt.length < 16 ? completedAt.length : 16)}',
                              style: const TextStyle(fontSize: 12),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcards - ${widget.sourceTitle}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Review History',
            onPressed: _showReviewHistory,
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _generateFlashcards,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _flashcards.isEmpty
              ? const Center(child: Text('No flashcards generated'))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_currentIndex + 1} / ${_flashcards.length}'),
                        Text('Known: $_knownCount | Unknown: $_unknownCount'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _flipCard,
                      child: Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!_isFlipped) ...[
                                Text(
                                  'Question',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _flashcards[_currentIndex].question,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ] else ...[
                                Text(
                                  'Answer',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _flashcards[_currentIndex].answer,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                              const SizedBox(height: 16),
                               Text(
                                 _isFlipped
                                     ? 'Tap to flip'
                                     : 'Tap to reveal answer',
                                 style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                               ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _flipCard,
                            icon: const Icon(Icons.flip),
                            label: const Text('Flip'),
                          ),
                        ),
                        const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _markKnown,
                              icon: const Icon(Icons.check),
                              label: const Text('Known'),
style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _markUnknown,
                              icon: const Icon(Icons.close),
                              label: const Text('Unknown'),
style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.error,
                              foregroundColor: Theme.of(context).colorScheme.onError,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_flashcards.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _attachSource,
                            icon: const Icon(Icons.link),
                            tooltip: 'Attach source',
                          ),
                          if (_sourceRef.isNotEmpty)
                            Expanded(
                              child: Text(
                                'Source: $_sourceRef',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          const Spacer(),
                          IconButton(
                            onPressed: _reportError,
                            icon: const Icon(Icons.report_problem),
                            tooltip: 'Report incorrect',
                          ),
                          IconButton(
                            onPressed: _saveResults,
                            icon: const Icon(Icons.save),
                            tooltip: 'Save results',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
    );
  }
}

class Flashcard {
  final String question;
  final String answer;

  Flashcard({required this.question, required this.answer});
}
