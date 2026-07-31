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

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) async {
      final dbAsync = ref.read(dbFutureProvider);
      final profileAsync = ref.read(userProfileProvider);
      final isOnboarding = state.uri.path == '/onboarding';

      if (dbAsync.isLoading) return null;
      if (isOnboarding) return null;

      final dbReady = dbAsync.value != null;
      if (!dbReady) return null;

      if (profileAsync.isLoading) return null;
      final hasProfile = profileAsync.value != null;
      if (!hasProfile) return '/onboarding';
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
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) return const SizedBox.shrink();
              return SubjectsChapterScreen(subjectId: id);
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
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => const OnboardingScreen(),
          ),
        ],
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
        builder: (context, state) {
          final documentKey =
              state.pathParameters['documentKey'] ?? 'privacy_policy';
          return LegalScreen(documentKey: documentKey);
        },
      ),
    ],
  );
});