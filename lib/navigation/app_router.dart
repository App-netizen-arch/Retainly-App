import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/home_screen.dart';
import '../features/planner/planner_screen.dart';
import '../features/subjects/subjects_screen.dart';
import '../features/subjects/subject_setup_screen.dart';
import '../features/subjects/subjects_chapter_screen.dart';
import '../features/focus/focus_screen.dart';
import '../features/revision/revision_screen.dart';
import '../features/resources/resources_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/tasks/add_task_screen.dart';
import '../features/tasks/search_screen.dart';
import '../features/planner/reschedule_screen.dart';
import '../features/resources/pdf_viewer_screen.dart';
import '../features/resources/practical_records_screen.dart';
import '../features/ai/ocr_scan_screen.dart';
import '../features/ai/hallucination_reports_screen.dart';
import '../features/ai/flashcard_screen.dart';
import '../features/ai/quiz_screen.dart';
import '../features/legal/legal_screen.dart';
import '../features/backup/presentation/backup_manager_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import './app_shell.dart';
import '../../providers/database_provider.dart';
import '../../data/models/app_models.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(
      dbFutureProvider,
      (_, _) => notifyListeners(),
      fireImmediately: true,
    );
    ref.listen(
      userProfileProvider,
      (_, _) => notifyListeners(),
      fireImmediately: true,
    );
  }
}

class DatabaseErrorScreen extends ConsumerWidget {
  const DatabaseErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 24),
              Text(
                'Unable to load local storage',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'The app could not initialize its local database. Please check your device storage and try again.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(dbFutureProvider);
                  ref.invalidate(databaseRepositoryProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) async {
      final dbAsync = ref.read(dbFutureProvider);
      final profileAsync = ref.read(userProfileProvider);
      final path = state.uri.path;
      final isOnboarding = path == '/onboarding';
      final isDbError = path == '/db-error';
      final isLoading = path == '/loading';

      if (dbAsync.isLoading) {
        if (isLoading) return null;
        return '/loading';
      }

      if (dbAsync.hasError) {
        if (isDbError) return null;
        return '/db-error';
      }

      if (dbAsync.value == null) {
        if (isLoading) return null;
        return '/loading';
      }

      if (profileAsync.isLoading) {
        if (isLoading) return null;
        return '/loading';
      }

      final hasProfile = profileAsync.value != null;
      if (!hasProfile) {
        if (isOnboarding) return null;
        return '/onboarding';
      }

      if (isDbError || isLoading) return '/';

      return null;
    },
    routes: [
      ShellRoute(
        builder:
            (context, state, child) => AppShell(state: state, child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/planner',
            builder: (context, state) => const PlannerScreen(),
          ),
          GoRoute(
            path: '/notes',
            builder: (context, state) => const NotesScreen(),
          ),
          GoRoute(
            path: '/subjects/:id',
            redirect: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) return '/';
              return null;
            },
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              return SubjectsChapterScreen(subjectId: id!);
            },
          ),
          GoRoute(
            path: '/subjects/setup',
            builder: (context, state) => const SubjectSetupScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/backup',
            builder: (context, state) => const BackupManagerScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/focus',
        builder: (context, state) {
          final extra = state.extra;
          final taskId =
              extra is Map && extra['taskId'] is int
                  ? extra['taskId'] as int
                  : null;
          return FocusScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/revision',
        builder: (context, state) => const RevisionScreen(),
      ),
      GoRoute(
        path: '/resources',
        builder: (context, state) => const ResourcesScreen(),
      ),
      GoRoute(path: '/ocr', builder: (context, state) => const OcrScanScreen()),
      GoRoute(
        path: '/ai/hallucination-reports',
        builder: (context, state) => const HallucinationReportsScreen(),
      ),
      GoRoute(
        path: '/ai/flashcards',
        builder: (context, state) {
          final extra = state.extra;
          final sourceText =
              extra is Map && extra['sourceText'] is String
                  ? extra['sourceText'] as String
                  : '';
          final sourceTitle =
              extra is Map && extra['sourceTitle'] is String
                  ? extra['sourceTitle'] as String
                  : 'Flashcards';
          return FlashcardScreen(sourceText: sourceText, sourceTitle: sourceTitle);
        },
      ),
      GoRoute(
        path: '/ai/quiz',
        builder: (context, state) {
          final extra = state.extra;
          final sourceText =
              extra is Map && extra['sourceText'] is String
                  ? extra['sourceText'] as String
                  : '';
          final sourceTitle =
              extra is Map && extra['sourceTitle'] is String
                  ? extra['sourceTitle'] as String
                  : 'Quiz';
          return QuizScreen(sourceText: sourceText, sourceTitle: sourceTitle);
        },
      ),
      GoRoute(
        path: '/pdf',
        builder: (context, state) {
          final extra =
              state.extra is Map<String, dynamic>
                  ? state.extra as Map<String, dynamic>
                  : const {};
          final path = extra['path'] is String ? extra['path'] as String : '';
          final title =
              extra['title'] is String ? extra['title'] as String : '';
          return PdfViewerScreen(path: path, title: title);
        },
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/tasks/add',
        builder: (context, state) => const AddTaskScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/practicals',
        builder: (context, state) => const PracticalRecordsScreen(),
      ),
      GoRoute(
        path: '/reschedule',
        builder: (context, state) {
          final extra = state.extra;
          final tasks =
              extra is List
                  ? extra.whereType<TaskModel>().toList()
                  : const <TaskModel>[];
          return RescheduleScreen(tasks: tasks);
        },
      ),
      GoRoute(
        path: '/legal/:documentKey',
        redirect: (context, state) {
          final key = state.pathParameters['documentKey'] ?? '';
          const validKeys = <String>{
            'privacy_policy',
            'terms_of_service',
            'data_retention_policy',
            'age_minor_policy',
            'threat_model',
          };
          if (!validKeys.contains(key)) return '/';
          return null;
        },
        builder: (context, state) {
          final documentKey =
              state.pathParameters['documentKey'] ?? 'privacy_policy';
          return LegalScreen(documentKey: documentKey);
        },
      ),
      GoRoute(
        path: '/db-error',
        builder: (context, state) => const DatabaseErrorScreen(),
      ),
      GoRoute(
        path: '/loading',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
    ],
  );
});
