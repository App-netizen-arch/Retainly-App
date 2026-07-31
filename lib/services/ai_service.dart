// Copyright 2026 CodeSym
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';

class AIService {
  static const String _consentKey = 'ai_consent';
  static const String _ocrConsentKey = 'ocr_consent';
  static const String _costWarningKey = 'ai_cost_warning_accepted';
  static const String _usageQuotaKey = 'ai_daily_usage';
  static const String _quotaDateKey = 'ai_quota_date';
  static const String _providerKey = 'ai_provider';
  static const String _sourceCitationKey = 'ai_source_citations';
  static const String _hallucinationReportKey = 'ai_hallucination_reports';
  static const String _aiPolicyKey = 'ai_policy_accepted';
  static const String _estimatedCostKey = 'ai_estimated_cost';
  static const int _dailyQuota = 50;
  static const double _costPerRequest = 0.002;

  FirebaseFirestore? _firestore;
  FirebaseFunctions? _functions;
  FirebaseStorage? _storage;
  final ConnectivityService _connectivity = ConnectivityService();

  Future<void> _ensureFirebase() async {
    if (_firestore != null) return;
    try {
      _firestore = FirebaseFirestore.instance;
      _functions = FirebaseFunctions.instance;
      _storage = FirebaseStorage.instance;
    } catch (_) {}
  }

  Future<String> getAiProvider() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_providerKey) ?? 'openai';
  }

  Future<void> setAiProvider(String provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_providerKey, provider);
  }

  Future<bool> hasAiConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  Future<void> setAiConsent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, value);
  }

  Future<bool> hasOcrConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_ocrConsentKey) ?? false;
  }

  Future<void> setOcrConsent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ocrConsentKey, value);
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

  Future<void> ensureConsentRecord(String userId) async {
    await _ensureFirebase();
    if (_firestore == null) return;
    try {
      final consent = await hasAiConsent();
      await _firestore!.collection('ai_consents').doc(userId).set({
        'userId': userId,
        'aiAssistance': consent,
        'ocrScanning': await hasOcrConsent(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (_) {}
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
    final remaining = await getAiUsageQuota(userId);
    if (remaining <= 0) {
      return 'Daily AI quota reached. Try again tomorrow.';
    }
    if (!await _connectivity.isOnline) {
      return 'No internet connection. Connect to use AI features.';
    }
    return null;
  }

  Future<String?> generateTaskBreakdown(String userId, String taskTitle) async {
    await _ensureFirebase();
    if (_functions == null) return 'AI is unavailable in local-only mode.';
    final gate = await _checkQuotaAndGate(userId);
    if (gate != null) return gate;
    try {
      final callable = _functions!.httpsCallable('aiProxy');
      final result = await callable.call(<String, dynamic>{
        'prompt':
            'Break this Matric study task into 3-5 15-minute sub-tasks: $taskTitle',
        'model': 'task-breakdown',
      });
      await recordAiUsage(userId);
      await estimateCost(userId, result.data);
      return result.data['output'] as String?;
    } on FirebaseFunctionsException catch (e) {
      return 'AI request failed: ${e.message ?? "unknown error"}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> generateRevisionDraft(
    String userId,
    String chapterTitle,
  ) async {
    await _ensureFirebase();
    if (_functions == null) return 'AI is unavailable in local-only mode.';
    final gate = await _checkQuotaAndGate(userId);
    if (gate != null) return gate;
    try {
      final callable = _functions!.httpsCallable('aiProxy');
      final result = await callable.call(<String, dynamic>{
        'prompt':
            'Create a revision plan for: $chapterTitle. Include 3 spaced-repetition review slots.',
        'model': 'revision-draft',
      });
      await recordAiUsage(userId);
      await estimateCost(userId, result.data);
      return result.data['output'] as String?;
    } on FirebaseFunctionsException catch (e) {
      return 'AI request failed: ${e.message ?? "unknown error"}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> generateFlashcards(String userId, String sourceText) async {
    await _ensureFirebase();
    if (_functions == null) return 'AI is unavailable in local-only mode.';
    final gate = await _checkQuotaAndGate(userId);
    if (gate != null) return gate;
    try {
      final callable = _functions!.httpsCallable('aiProxy');
      final result = await callable.call(<String, dynamic>{
        'prompt':
            'Generate 5 flashcards from this text. Format: Question / Answer.\n\n$sourceText',
        'model': 'flashcards',
      });
      await recordAiUsage(userId);
      await estimateCost(userId, result.data);
      return result.data['output'] as String?;
    } on FirebaseFunctionsException catch (e) {
      return 'AI request failed: ${e.message ?? "unknown error"}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> generateQuizDraft(
    String userId,
    String chapterTitle,
    int questionCount,
  ) async {
    await _ensureFirebase();
    if (_functions == null) return 'AI is unavailable in local-only mode.';
    final gate = await _checkQuotaAndGate(userId);
    if (gate != null) return gate;
    try {
      final callable = _functions!.httpsCallable('aiProxy');
      final result = await callable.call(<String, dynamic>{
        'prompt':
            'Generate $questionCount MCQs for $chapterTitle. Include answers and brief explanations.',
        'model': 'quiz-draft',
      });
      await recordAiUsage(userId);
      await estimateCost(userId, result.data);
      return result.data['output'] as String?;
    } on FirebaseFunctionsException catch (e) {
      return 'AI request failed: ${e.message ?? "unknown error"}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<void> estimateCost(String userId, dynamic resultData) async {
    final output = resultData is Map ? resultData['output'] as String? : null;
    if (output == null) return;
    final estimatedTokens = (output.length / 4).ceil();
    final rawCost = estimatedTokens * _costPerRequest;
    final cost = rawCost > 0.5 ? 0.5 : rawCost;
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getDouble(_estimatedCostKey) ?? 0.0;
    final totalCost = (current + cost > 10.0) ? 10.0 : current + cost;
    await prefs.setDouble(_estimatedCostKey, totalCost);
  }

  Future<double> getEstimatedCost(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_estimatedCostKey) ?? 0.0;
  }

  Future<void> resetEstimatedCost(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_estimatedCostKey);
  }

  Future<String?> uploadPdfToStorage(String userId, String localPath) async {
    await _ensureFirebase();
    if (_storage == null) return null;
    try {
      final file = File(localPath);
      if (!await file.exists()) return null;
      final fileName = file.uri.pathSegments.last;
      final ref = _storage!.ref('ocr_pdfs/$userId/$fileName');
      await ref.putFile(file);
      return ref.fullPath;
    } catch (e) {
      return null;
    }
  }

  Future<String?> startOcrJob(
    String userId,
    String filePath, {
    String language = 'en',
    String? storagePath,
  }) async {
    if (!await hasOcrConsent()) {
      return 'OCR requires explicit consent in Settings.';
    }
    if (!await _connectivity.isOnline) {
      return 'No internet connection. Connect to use OCR.';
    }
    await _ensureFirebase();
    if (_functions == null) return 'OCR is unavailable in local-only mode.';
    try {
      final effectivePath = storagePath ?? filePath;
      final callable = _functions!.httpsCallable('ocrProcess');
      final result = await callable.call(<String, dynamic>{
        'filePath': effectivePath,
        'language': language,
      });
      final data = result.data as Map<String, dynamic>?;
      return data?['jobId'] as String?;
    } on FirebaseFunctionsException catch (e) {
      return 'OCR request failed: ${e.message ?? "unknown error"}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<Map<String, dynamic>?> getOcrResult(
    String userId,
    String jobId,
  ) async {
    await _ensureFirebase();
    if (_firestore == null) return null;
    try {
      final doc = await _firestore!.collection('ocr_jobs').doc(jobId).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      if (data['userId'] != userId) return null;
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<int> getAiUsageQuota(String userId) async {
    await _resetQuotaIfNewDay();
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getInt(_usageQuotaKey) ?? 0;
    return _dailyQuota - used;
  }

  Future<void> recordAiUsage(String userId) async {
    await _resetQuotaIfNewDay();
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getInt(_usageQuotaKey) ?? 0;
    await prefs.setInt(_usageQuotaKey, used + 1);
  }

  Future<void> attachSourceCitation(
    String userId,
    String contentId,
    String textbookRef,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final citationsJson = prefs.getString(_sourceCitationKey) ?? '{}';
    final citations = Map<String, dynamic>.from(() {
      try {
        return Map<String, dynamic>.from(
          RegExp(r'^\{.*\}$').hasMatch(citationsJson)
              ? Map<String, dynamic>.from(
                Map<String, dynamic>.from(
                  const JsonDecoder().convert(citationsJson),
                ),
              )
              : <String, dynamic>{},
        );
      } catch (_) {
        return <String, dynamic>{};
      }
    }());
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
      return Map<String, dynamic>.from(
        const JsonDecoder().convert(citationsJson),
      );
    } catch (_) {
      return {};
    }
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
    await _ensureFirebase();
    if (_firestore == null) return;
    try {
      await _firestore!.collection('ai_hallucination_reports').add({
        'userId': userId,
        'contentId': contentId,
        'feedback': feedback,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (_) {}
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

  Future<String?> askAiAboutSubject(
    String userId,
    String question, {
    String? subjectContext,
  }) async {
    await _ensureFirebase();
    if (_functions == null) return 'AI is unavailable in local-only mode.';
    final gate = await _checkQuotaAndGate(userId);
    if (gate != null) return gate;
    final prompt =
        'System Prompt: Matric Study Planner AI Assistant\n'
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
        '$question\n'
        'Student subjects and chapters context:\n'
        '$subjectContext\n'
        'Now answer directly, following the rules above.';
    try {
      final callable = _functions!.httpsCallable('aiProxy');
      final result = await callable.call(<String, dynamic>{
        'prompt': prompt,
        'model': 'subject-qna',
      });
      await recordAiUsage(userId);
      await estimateCost(userId, result.data);
      return result.data['output'] as String?;
    } on FirebaseFunctionsException catch (e) {
      return 'AI request failed: ${e.message ?? "unknown error"}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }
}
