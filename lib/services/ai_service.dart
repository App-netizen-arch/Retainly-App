import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'connectivity_service.dart';
import '../core/utils/ai_utils.dart';

class AIService {
  static const String _consentKey = 'ai_consent';
  static const String _costWarningKey = 'ai_cost_warning_accepted';
  static const String _usageQuotaKey = 'ai_daily_usage';
  static const String _quotaDateKey = 'ai_quota_date';
  static const String _providerKey = 'ai_provider';
  static const String _sourceCitationKey = 'ai_source_citations';
  static const String _hallucinationReportKey = 'ai_hallucination_reports';
  static const String _aiPolicyKey = 'ai_policy_accepted';
  static const String _estimatedCostKey = 'ai_estimated_cost';
  static const int _dailyQuota = 10;
  static const double _costPerRequest = 0.002;
  static const String _vercelProxyUrl =
      'https://vercel-pi-weld.vercel.app/api/ai-proxy';
  static const String _defaultModel = 'openrouter/free';
  static const String _aiErrorPrefix = 'AI_ERROR:';
  static const int _maxRetries = 3;
  static const Duration _baseTimeout = Duration(seconds: 15);

  final ConnectivityService _connectivity = ConnectivityService();
  Completer<void>? _quotaLock;
  Completer<void>? _costLock;

  Future<T> _withQuotaLock<T>(Future<T> Function() action) async {
    while (_quotaLock != null) {
      await _quotaLock!.future;
    }
    final completer = Completer<void>();
    _quotaLock = completer;
    try {
      return await action();
    } finally {
      completer.complete();
      _quotaLock = null;
    }
  }

  Future<T> _withCostLock<T>(Future<T> Function() action) async {
    while (_costLock != null) {
      await _costLock!.future;
    }
    final completer = Completer<void>();
    _costLock = completer;
    try {
      return await action();
    } finally {
      completer.complete();
      _costLock = null;
    }
  }

  Future<String?> generateTaskBreakdown(String userId, String taskTitle) async {
    return callAiProxy(
      userId: userId,
      model: _defaultModel,
      systemPrompt:
          'You are a helpful study assistant for Pakistani Matric students. Break study tasks into 3-5 actionable 15-minute sub-tasks.',
      userPrompt:
          'Break this Matric study task into 3-5 15-minute sub-tasks: $taskTitle',
    );
  }

  Future<String?> generateRevisionDraft(
    String userId,
    String chapterTitle,
  ) async {
    return callAiProxy(
      userId: userId,
      model: _defaultModel,
      systemPrompt:
          'You are a helpful study assistant for Pakistani Matric students. Create concise revision plans with 3 spaced-repetition review slots.',
      userPrompt:
          'Create a revision plan for: $chapterTitle. Include 3 spaced-repetition review slots.',
    );
  }

  Future<String?> generateFlashcards(String userId, String sourceText) async {
    return callAiProxy(
      userId: userId,
      model: _defaultModel,
      systemPrompt:
          'You are a helpful study assistant for Pakistani Matric students. Generate clear flashcards in Question / Answer format.',
      userPrompt:
          'Generate 5 flashcards from this text. Format: Question / Answer.\n\n$sourceText',
    );
  }

  Future<String?> generateQuizDraft(
    String userId,
    String chapterTitle,
    int questionCount,
  ) async {
    return callAiProxy(
      userId: userId,
      model: _defaultModel,
      systemPrompt:
          'You are a helpful study assistant for Pakistani Matric students. Create multiple-choice quizzes with answers and brief explanations.',
      userPrompt:
          'Generate $questionCount multiple-choice questions for: $chapterTitle. Include answers and brief explanations.',
    );
  }

  Future<String?> callAiProxy({
    required String userId,
    required String model,
    required String systemPrompt,
    required String userPrompt,
    http.Client? client,
  }) async {
    String? lastError;
    final random = Random();
    final actualClient = client ?? http.Client();
    final shouldClose = client == null;

    try {
      for (var attempt = 0; attempt <= _maxRetries; attempt++) {
        final gate = await _checkQuotaAndGate(userId);
        if (gate != null) return '$_aiErrorPrefix $gate';

        try {
          final response = await actualClient
              .post(
                Uri.parse(_vercelProxyUrl),
                headers: <String, String>{'Content-Type': 'application/json'},
                body: jsonEncode(<String, dynamic>{
                  'model': model,
                  'messages': [
                    <String, dynamic>{'role': 'system', 'content': systemPrompt},
                    <String, dynamic>{'role': 'user', 'content': userPrompt},
                  ],
                }),
              )
              .timeout(_baseTimeout);

          if (_isRetryableStatus(response.statusCode)) {
            lastError = _statusErrorMessage(response.statusCode);
            if (attempt < _maxRetries) {
              await _backoff(attempt, random);
              continue;
            }
            return '$_aiErrorPrefix $lastError';
          }

          if (response.statusCode != 200) {
            return '$_aiErrorPrefix ${_statusErrorMessage(response.statusCode)}';
          }

          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final output = data['output'] as String?;
          if (output == null || output.isEmpty) {
            return '$_aiErrorPrefix AI returned an empty response.';
          }

          final sanitized = AiTextSanitizer.sanitize(output);
          if (sanitized.isEmpty) {
            return '$_aiErrorPrefix AI returned an empty response.';
          }

          await estimateCostFromOutput(sanitized);
          await recordAiUsage(userId);
          return sanitized;
        } on TimeoutException {
          lastError = 'The AI service is taking longer than expected. Please retry.';
          if (attempt < _maxRetries) {
            await _backoff(attempt, random);
            continue;
          }
          return '$_aiErrorPrefix $lastError';
        } on SocketException {
          lastError = 'No internet connection. Connect to use AI features.';
          if (attempt < _maxRetries) {
            await _backoff(attempt, random);
            continue;
          }
          return '$_aiErrorPrefix $lastError';
        } on HttpException {
          lastError = 'AI request failed. Please check your connection and retry.';
          if (attempt < _maxRetries) {
            await _backoff(attempt, random);
            continue;
          }
          return '$_aiErrorPrefix $lastError';
        } on FormatException {
          lastError = 'AI returned an invalid response. Please retry.';
          if (attempt < _maxRetries) {
            await _backoff(attempt, random);
            continue;
          }
          return '$_aiErrorPrefix $lastError';
        } catch (e) {
          lastError = 'Unexpected AI error. Please retry.';
          if (attempt < _maxRetries) {
            await _backoff(attempt, random);
            continue;
          }
          return '$_aiErrorPrefix $lastError';
        }
      }
      return '$_aiErrorPrefix Unexpected AI error. Please retry.';
    } finally {
      if (shouldClose) actualClient.close();
    }
  }

  static bool _isRetryableStatus(int statusCode) {
    return statusCode == 429 ||
        statusCode == 500 ||
        statusCode == 502 ||
        statusCode == 503;
  }

  static String _statusErrorMessage(int statusCode) {
    switch (statusCode) {
      case 429:
        return 'AI rate limit reached. Please try again shortly.';
      default:
        return 'AI request failed with status $statusCode. Please retry.';
    }
  }

  static Future<void> _backoff(int attempt, Random random) async {
    final baseDelay = Duration(seconds: pow(2, attempt).toInt());
    final jitter = Duration(milliseconds: random.nextInt(500));
    final total = baseDelay + jitter;
    final capped = total > const Duration(seconds: 4)
        ? const Duration(seconds: 4)
        : total;
    await Future.delayed(capped);
  }

  Future<String?> checkAiGate(String userId) async {
    return _checkQuotaAndGate(userId);
  }

  Future<String?> getAiProvider() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_providerKey) ?? 'openrouter';
  }

  Future<void> setAiProvider(String provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_providerKey, provider);
  }

  Future<bool> hasOcrConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('ocr_consent') ?? false;
  }

  Future<void> setOcrConsent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ocr_consent', value);
  }

  Future<String?> uploadPdfToStorage(
    String userId,
    String filePath, {
    String? destination,
  }) async {
    return 'PDF upload is not available in this offline-first release build.';
  }

  Future<void> ensureConsentRecord(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'ai_consent_record_$userId',
      DateTime.now().toIso8601String(),
    );
  }

  Future<bool> hasAiConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  Future<void> setAiConsent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, value);
  }

  Future<bool> hasAcceptedCostWarning() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_costWarningKey) ?? false;
  }

  Future<void> acceptCostWarning() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_costWarningKey, true);
  }

  Future<bool> hasAcceptedAiPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_aiPolicyKey) ?? false;
  }

  Future<void> acceptAiPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_aiPolicyKey, true);
  }

  Future<void> _resetQuotaIfNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final lastQuotaDate = prefs.getString(_quotaDateKey);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastQuotaDate != today) {
      await prefs.setInt(_usageQuotaKey, 0);
      await prefs.setString(_quotaDateKey, today);
    }
  }

  Future<String?> _checkQuotaAndGate(String userId) async {
    await _resetQuotaIfNewDay();
    if (!await hasAiConsent()) {
      return 'AI assistance requires consent in Settings.';
    }
    if (!await hasAcceptedCostWarning()) {
      return 'Accept the AI cost warning before using this feature.';
    }
    if (!await hasAcceptedAiPolicy()) {
      return 'Please accept the AI policy before using this feature.';
    }
    final remaining = await getAiUsageQuota(userId);
    if (remaining <= 0) {
      return 'Daily AI quota reached. Try again tomorrow.';
    }
    if (!await _connectivity.isOnline) {
      return 'No internet connection. Connect to use AI features.';
    }
    return null;
  }

  Future<void> estimateCost(String userId, dynamic resultData) async {
    final raw = resultData is Map ? resultData['output'] as String? : null;
    if (raw == null) return;
    final output = AiTextSanitizer.sanitize(raw);
    if (output.isEmpty) return;
    await estimateCostFromOutput(output);
  }

  Future<void> estimateCostFromOutput(String output) async {
    await _withCostLock(() async {
      final estimatedTokens = (output.length / 4).ceil();
      final rawCost = estimatedTokens * _costPerRequest;
      final cost = rawCost > 0.5 ? 0.5 : rawCost;
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getDouble(_estimatedCostKey) ?? 0.0;
      final totalCost = (current + cost > 10.0) ? 10.0 : current + cost;
      await prefs.setDouble(_estimatedCostKey, totalCost);
      return null;
    });
  }

  Future<double> getEstimatedCost(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_estimatedCostKey) ?? 0.0;
  }

  Future<void> resetEstimatedCost(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_estimatedCostKey);
  }

  Future<String?> startOcrJob(
    String userId,
    String filePath, {
    String language = 'en',
    String? storagePath,
  }) async {
    return 'OCR is disabled in this release build. Use the online AI assistant instead.';
  }

  Future<Map<String, dynamic>?> getOcrResult(
    String userId,
    String jobId,
  ) async {
    return <String, dynamic>{
      'status': 'disabled',
      'extractedText':
          'OCR is disabled in this release build. Use the online AI assistant instead.',
      'jobId': jobId,
    };
  }

  Future<int> getAiUsageQuota(String userId) async {
    await _resetQuotaIfNewDay();
    return _withQuotaLock(() async {
      final prefs = await SharedPreferences.getInstance();
      final used = prefs.getInt(_usageQuotaKey) ?? 0;
      return _dailyQuota - used;
    });
  }

  Future<void> recordAiUsage(String userId) async {
    await _resetQuotaIfNewDay();
    await _withQuotaLock(() async {
      final prefs = await SharedPreferences.getInstance();
      final used = prefs.getInt(_usageQuotaKey) ?? 0;
      await prefs.setInt(_usageQuotaKey, used + 1);
      return null;
    });
  }

  Future<void> attachSourceCitation(
    String userId,
    String contentId,
    String textbookRef,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final citationsJson = prefs.getString(_sourceCitationKey) ?? '{}';
    final citations = <String, dynamic>{};
    try {
      final decoded = const JsonDecoder().convert(citationsJson);
      if (decoded is Map) {
        citations.addAll(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      citations.clear();
    }
    citations[contentId] = {
      'textbookRef': textbookRef,
      'attachedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_sourceCitationKey, JsonEncoder().convert(citations));
  }

  Future<Map<String, dynamic>> getSourceCitations(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final citationsJson = prefs.getString(_sourceCitationKey) ?? '{}';
    try {
      final decoded = const JsonDecoder().convert(citationsJson);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  Future<void> reportHallucination(
    String userId,
    String contentId,
    String feedback,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = prefs.getString(_hallucinationReportKey) ?? '[]';
    List<dynamic> reports = [];
    try {
      reports = const JsonDecoder().convert(reportsJson) as List<dynamic>;
    } catch (_) {
      reports = [];
    }
    reports.add({
      'contentId': contentId,
      'feedback': feedback,
      'reportedAt': DateTime.now().toIso8601String(),
    });
    await prefs.setString(
      _hallucinationReportKey,
      const JsonEncoder().convert(reports),
    );
  }

  Future<List<dynamic>> getHallucinationReports(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = prefs.getString(_hallucinationReportKey) ?? '[]';
    try {
      return const JsonDecoder().convert(reportsJson) as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteHallucinationReport(String userId, int index) async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = prefs.getString(_hallucinationReportKey) ?? '[]';
    List<dynamic> reports = [];
    try {
      reports = const JsonDecoder().convert(reportsJson) as List<dynamic>;
    } catch (_) {
      reports = [];
    }
    if (index < 0 || index >= reports.length) return;
    reports.removeAt(index);
    await prefs.setString(
      _hallucinationReportKey,
      const JsonEncoder().convert(reports),
    );
  }

  Future<void> clearHallucinationReports(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hallucinationReportKey, '[]');
  }

  static String _sanitizeAiInput(String input) {
    if (input.isEmpty) return input;
    final stripped = input.replaceAll(RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f]'), '');
    if (stripped.length > 2000) {
      return stripped.substring(0, 2000);
    }
    return stripped;
  }

  Future<String?> askAiAboutSubject(
    String userId,
    String question, {
    String? subjectContext,
  }) async {
    final safeQuestion = _sanitizeAiInput(question);
    final safeContext =
        subjectContext != null ? _sanitizeAiInput(subjectContext) : '';
    final systemPrompt =
        'Matric Study Planner AI Assistant\n'
        'Role & Identity\n'
        'You are the built-in AI Study Assistant for the Matric Study Planner app, tailored specifically for Pakistani Class 9 and Class 10 (Matric) students. Your role is to help students break down complex topics, draft revision plans, generate practice quizzes/flashcards, and answer questions grounded directly in their provided study materials.\n'
        'Your tone must remain calm, clear, encouraging, and supportive—never inducing stress, guilt, or fear regarding exam preparation. You communicate effectively in both clear English and simple Urdu (or Roman Urdu if requested by the user).\n'
        'Core Operational Principles & Output Rules\n'
        '1. Draft-Only Output Standard\n'
        'Always Drafts, Never Final Statements: Every task breakdown, flashcard set, quiz item, or revision schedule you generate is strictly a draft.\n'
        'No Direct Plan Mutation: Inform the user that they must preview, edit, and confirm any generated content before adding it to their study plan. Never imply that an action has been directly written to their database.\n'
        '2. Source-Grounded Q&A and Citations\n'
        'Document Grounding: When answering questions based on user-provided notes, text, or PDFs, ground your answers directly in the provided source text and reference specific page numbers or sections whenever applicable.\n'
        'Explicit Uncertainty: If the user\'s uploaded material does not contain enough information to answer a question, explicitly state: "This material does not provide enough information to confirm this answer with certainty."\n'
        'No Unverified Claims: Never present unverified assertions or general model assumptions as absolute facts.\n'
        '3. Estimates vs. Predictions\n'
        'Frame as Estimates: Any readiness score, study time estimate, or syllabus coverage breakdown is an estimate, never a board exam score prediction.\n'
        'Explain the Logic: Always show the inputs or reasoning behind a recommended study estimate or task breakdown.\n'
        '4. Pedagogical & Syllabus Scope\n'
        'Align content with the Pakistani Matric (Class 9-10) board syllabus (e.g., Physics, Chemistry, Biology, Mathematics, Computer Science, English, Urdu, Islamiat, Pak Studies).\n'
        'Adapt suggestions to match realistic daily workloads and respect non-study time (e.g., school hours, prayer/family commitments).\n'
        'Key Task Templates & Instructions\n'
        'A. Task Breakdown & Revision Plan Drafts\n'
        'Break chapters down into logical sub-topics, estimated completion times (in minutes), and actionable steps.\n'
        'Provide a Minimum Viable Plan option if the user indicates they are short on time or feeling overwhelmed.\n'
        'B. Quiz & Flashcard Generation\n'
        'Support multiple choice (MCQs), True/False, and short-answer formats.\n'
        'Provide clear answer explanations citing the text provided.\n'
        'Include an error warning note: "Please review these questions carefully against your textbook or board guidelines."\n'
        'C. PDF Summarization & OCR Review\n'
        'Extract key concepts, definitions, formulas, and practical record steps.\n'
        'Highlight any text extracted via OCR that appears ambiguous or unclear for user verification.\n'
        'Safety, Ethics, and Guardrails\n'
        'No Personal Data Harvesting: Do not ask for or store sensitive personal information.\n'
        'No Hallucination Masking: Always display an error/uncertainty disclaimer when information is partial or incomplete.\n'
        'Academic Integrity: Provide explanations and guided learning paths rather than completing graded assignments or exam questions on behalf of the student.\n'
        'User question:\n'
        '$safeQuestion\n'
        'Student subjects and chapters context:\n'
        '$safeContext\n'
        'Now answer directly, following the rules above.';

    return callAiProxy(
      userId: userId,
      model: _defaultModel,
      systemPrompt: systemPrompt,
      userPrompt: safeQuestion,
    );
  }
}
