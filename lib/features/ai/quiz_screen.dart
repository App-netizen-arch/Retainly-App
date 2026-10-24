import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/ai_service.dart';
import '../../data/repositories/local_ai_repository.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String sourceText;
  final String sourceTitle;
  final int questionCount;
  final int? durationMinutes;

  const QuizScreen({
    super.key,
    required this.sourceText,
    required this.sourceTitle,
    this.questionCount = 5,
    this.durationMinutes,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _selectedAnswer = -1;
  int _correctCount = 0;
  int _answeredCount = 0;
  bool _showResults = false;
  bool _loading = false;
  String? _error;
  String _sourceRef = '';
  final TextEditingController _sourceController = TextEditingController();
  Timer? _examTimer;
  int _remainingSeconds = 0;
  bool _timeExpired = false;

  bool get _isTimedExam => widget.durationMinutes != null;

  String get _remainingTimeLabel {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _examTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateQuiz() async {
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
      final sourceText = widget.sourceText.trim().isNotEmpty
          ? widget.sourceText
          : await LocalAiRepository().buildTextbookContext(widget.sourceTitle);
      final result = await service.generateQuizDraft(
        userId,
        widget.sourceTitle,
        widget.questionCount,
        sourceText: sourceText,
      );
      if (!mounted) return;
      if (result == null || result.startsWith('AI_ERROR:')) {
        final message = result != null && result.startsWith('AI_ERROR:')
            ? result.substring('AI_ERROR:'.length).trim()
            : result;
        setState(() {
          _error = message ?? 'Failed to generate quiz.';
          _loading = false;
        });
        return;
      }
      final questions = _parseQuiz(result);
      setState(() {
        _questions = questions;
        _currentIndex = 0;
        _selectedAnswer = -1;
        _correctCount = 0;
        _answeredCount = 0;
        _showResults = false;
        _loading = false;
      });
      if (_isTimedExam) {
        _startExamTimer();
      }
    } on Exception catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Generation failed. Please try again.';
        _loading = false;
      });
    }
  }

  void _startExamTimer() {
    _examTimer?.cancel();
    _remainingSeconds = (widget.durationMinutes ?? 0) * 60;
    _timeExpired = false;
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _showResults) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _timeExpired = true;
          _showResults = true;
          _selectedAnswer = -1;
        });
        _saveQuizResults();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  List<QuizQuestion> _parseQuiz(String result) {
    final questions = <QuizQuestion>[];
    final lines = result.split('\n').where((l) => l.trim().isNotEmpty).toList();
    String? currentQuestion;
    final currentOptions = <String>[];
    String? currentAnswer;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final withoutNumber = trimmed.replaceAll(RegExp(r'^\d+[\.\)]\s*'), '');

      if (withoutNumber.toLowerCase().startsWith('q:') ||
          withoutNumber.toLowerCase().startsWith('question:')) {
        currentQuestion = withoutNumber
            .replaceFirst(
              RegExp(r'^(?:question|q)[:\s]*', caseSensitive: false),
              '',
            )
            .trim();
        currentOptions.clear();
        currentAnswer = null;
      } else if (withoutNumber.toLowerCase().startsWith('a:') ||
          withoutNumber.toLowerCase().startsWith('answer:')) {
        currentAnswer = withoutNumber
            .replaceFirst(
              RegExp(r'^(?:answer|a)[:\s]*', caseSensitive: false),
              '',
            )
            .trim();
        if (currentQuestion != null) {
          questions.add(
            QuizQuestion(
              question: currentQuestion,
              options: currentOptions.isEmpty
                  ? ['A', 'B', 'C', 'D']
                  : currentOptions,
              correctAnswer: currentAnswer,
            ),
          );
          currentQuestion = null;
          currentOptions.clear();
          currentAnswer = null;
        }
      } else if (withoutNumber.toLowerCase().startsWith('option') ||
          RegExp(
            r'^[A-D][).:]\s*',
            caseSensitive: false,
          ).hasMatch(withoutNumber) ||
          withoutNumber.startsWith('-') ||
          withoutNumber.startsWith('*')) {
        final optionText = withoutNumber
            .replaceFirst(
              RegExp(
                r'^(?:option\s*[A-D0-9]?\s*[:.)-]?|[A-D][).:])\s*',
                caseSensitive: false,
              ),
              '',
            )
            .replaceFirst(RegExp(r'^[-*]\s*'), '')
            .trim();
        currentOptions.add(optionText);
      } else if (currentQuestion != null && currentOptions.length < 4) {
        currentOptions.add(withoutNumber);
      } else if (currentQuestion != null &&
          currentAnswer == null &&
          withoutNumber.toLowerCase().contains('answer')) {
        currentAnswer = withoutNumber
            .replaceFirst(
              RegExp(r'^(?:answer|a)[:\s]*', caseSensitive: false),
              '',
            )
            .trim();
        questions.add(
          QuizQuestion(
            question: currentQuestion,
            options: currentOptions.isEmpty
                ? ['A', 'B', 'C', 'D']
                : currentOptions,
            correctAnswer: currentAnswer,
          ),
        );
        currentQuestion = null;
        currentOptions.clear();
        currentAnswer = null;
      }
    }

    if (questions.isEmpty) {
      questions.add(
        QuizQuestion(
          question: result,
          options: ['A', 'B', 'C', 'D'],
          correctAnswer: '',
        ),
      );
    }
    return questions;
  }

  void _selectAnswer(int index) {
    setState(() => _selectedAnswer = index);
  }

  void _submitAnswer() {
    if (_selectedAnswer < 0 || _questions.isEmpty) return;
    _answeredCount++;
    final q = _questions[_currentIndex];
    final selected = q.options[_selectedAnswer].trim();
    final answer = q.correctAnswer.trim();
    final exactAnswerIndex = q.options.indexWhere(
      (option) => option.trim().toLowerCase() == answer.toLowerCase(),
    );
    final answerLetter = RegExp(
      r'^(?:option\s*)?([A-D])(?:[).:]|\s|$)',
      caseSensitive: false,
    ).firstMatch(answer)?.group(1)?.toUpperCase();
    final correctIndex = exactAnswerIndex >= 0
        ? exactAnswerIndex
        : answerLetter == null
        ? -1
        : answerLetter.codeUnitAt(0) - 'A'.codeUnitAt(0);
    if (selected.isNotEmpty && correctIndex == _selectedAnswer) {
      _correctCount++;
    }
    setState(() => _selectedAnswer = -1);
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _examTimer?.cancel();
      setState(() => _showResults = true);
      _saveQuizResults();
    }
  }

  Future<void> _saveQuizResults() async {
    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getString('quiz_results') ?? '[]';
    List<dynamic> existing = [];
    try {
      existing = const JsonDecoder().convert(existingJson) as List<dynamic>;
    } catch (_) {}
    existing.add({
      'sourceTitle': widget.sourceTitle,
      'totalQuestions': _questions.length,
      'correctCount': _correctCount,
      'answeredCount': _answeredCount,
      'score': _questions.isNotEmpty
          ? (_correctCount / _questions.length * 100).round()
          : 0,
      'completedAt': DateTime.now().toIso8601String(),
      'sourceRef': _sourceRef,
    });
    await prefs.setString(
      'quiz_results',
      const JsonEncoder().convert(existing),
    );
  }

  Future<void> _showReviewHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getString('quiz_results') ?? '[]';
    List<dynamic> existing = [];
    try {
      existing = const JsonDecoder().convert(existingJson) as List<dynamic>;
    } catch (_) {}
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Review History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: existing.isEmpty
              ? const Center(child: Text('No history yet'))
              : ListView.builder(
                  itemCount: existing.length,
                  itemBuilder: (context, index) {
                    final item = existing[index] as Map<String, dynamic>;
                    final score = item['score'] as int? ?? 0;
                    final correct = item['correctCount'] as int? ?? 0;
                    final total = item['totalQuestions'] as int? ?? 0;
                    final completedAt = item['completedAt'] as String? ?? '';
                    return ListTile(
                      title: Text(item['sourceTitle'] as String? ?? 'Unknown'),
                      subtitle: Text(
                        'Score: $score% ($correct/$total correct)\n'
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

  Future<void> _attachSource() async {
    _sourceController.clear();
    final ref = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
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
      'quiz_${widget.sourceTitle}',
      'User reported incorrect quiz question',
    );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report submitted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz - ${widget.sourceTitle}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Review History',
            onPressed: _showReviewHistory,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _generateQuiz,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _questions.isEmpty
          ? const Center(child: Text('No quiz questions generated'))
          : _showResults
          ? _buildResults()
          : _buildQuiz(),
    );
  }

  Widget _buildQuiz() {
    final q = _questions[_currentIndex];
    return Column(
      children: [
        if (_isTimedExam)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: _remainingSeconds <= 60
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Time left: $_remainingTimeLabel',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _remainingSeconds <= 60
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Question ${_currentIndex + 1} / ${_questions.length}'),
              Text('Score: $_correctCount / $_answeredCount'),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                RadioGroup<int>(
                  groupValue: _selectedAnswer,
                  onChanged: (value) {
                    if (value != null) _selectAnswer(value);
                  },
                  child: Column(
                    children: [
                      ...q.options.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final option = entry.value;
                        return RadioListTile<int>(
                          title: Text(option),
                          value: idx,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedAnswer < 0 ? null : _submitAnswer,
                  child: const Text('Submit'),
                ),
              ),
              const SizedBox(width: 8),
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
              IconButton(
                onPressed: _reportError,
                icon: const Icon(Icons.report_problem),
                tooltip: 'Report incorrect',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    _examTimer?.cancel();
    final score = _questions.isNotEmpty
        ? (_correctCount / _questions.length * 100).round()
        : 0;
    Color scoreColor;
    if (score >= 70) {
      scoreColor = Theme.of(context).colorScheme.tertiary;
    } else if (score >= 40) {
      scoreColor = Theme.of(context).colorScheme.primary;
    } else {
      scoreColor = Theme.of(context).colorScheme.error;
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_timeExpired)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Time is up. Unanswered questions remain unanswered.',
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('Score', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '$score%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('$_correctCount / ${_questions.length} correct'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final q = _questions[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q${index + 1}: ${q.question}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Answer: ${q.correctAnswer}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _generateQuiz,
                    child: const Text('Retake'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _attachSource,
                  icon: const Icon(Icons.link),
                  tooltip: 'Attach source',
                ),
                IconButton(
                  onPressed: _reportError,
                  icon: const Icon(Icons.report_problem),
                  tooltip: 'Report incorrect',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}
