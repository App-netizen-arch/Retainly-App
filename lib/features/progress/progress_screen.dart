import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/database_provider.dart';
import '../../data/models/app_models.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressMetricsProvider);
    final weeklyAsync = ref.watch(weeklyAnalyticsProvider);
    final analyticsAsync = ref.watch(analyticsDetailProvider);
    final recallTrendsAsync = ref.watch(recallTrendsProvider);
    final decayAsync = ref.watch(subjectConfidenceDecayProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          progressAsync.when(
            data: (data) {
              final totalMinutes = data['totalMinutes'] ?? 0;
              final completedChapters = data['completedChapters'] ?? 0;
              final totalChapters = data['totalChapters'] ?? 0;

              return Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.timer, size: 48, color: Colors.blue),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Study Time',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '$totalMinutes min',
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 48,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chapters Completed',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '$completedChapters / $totalChapters',
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Something went wrong. Please try again.')),
          ),
          const SizedBox(height: 24),
          weeklyAsync.when(
            data: (data) {
              final weekMinutes = data['weekMinutes'] ?? 0;
              final plannedMinutes = data['plannedMinutes'] ?? 0;
              final actualMinutes = data['actualMinutes'] ?? 0;
              final revisionBacklog = data['revisionBacklog'] ?? 0;
               final subjectMinutes =
                   data['subjectMinutes'] as Map<int, int>? ?? {};
               final subjectNames =
                   data['subjectNames'] as Map<int, String>? ?? {};
               final sessionCount = data['sessionCount'] ?? 0;

              return Column(
                children: [
                  Text(
                    'This Week',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.assessment_outlined,
                            size: 36,
                            color: Colors.purple,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Study Time',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '$weekMinutes min',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'Plan',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '$plannedMinutes min',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Column(
                            children: [
                              Text(
                                'Actual',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '$actualMinutes min',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if ((data['nextAction'] as String? ?? '').isNotEmpty)
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.tips_and_updates,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(data['nextAction'] as String)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text(
                                  'Sessions',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  '$sessionCount',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text(
                                  'Revision backlog',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  '$revisionBacklog',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (subjectMinutes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Subject Breakdown',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                             ...subjectMinutes.entries.map(
                               (e) => Padding(
                                 padding: const EdgeInsets.symmetric(
                                   vertical: 2,
                                 ),
                                 child: Row(
                                   children: [
                                     Expanded(
                                       child: Text(
                                         subjectNames[e.key] ?? 'Subject ${e.key}',
                                       ),
                                     ),
                                     Text('${e.value} min'),
                                   ],
                                 ),
                               ),
                             ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Something went wrong. Please try again.')),
          ),
          const SizedBox(height: 24),
          analyticsAsync.when(
            data: (data) {
              final accuracy =
                  data['taskAccuracy'] as List<Map<String, dynamic>>? ?? [];
              final productive =
                  data['productiveTime'] as List<Map<String, dynamic>>? ?? [];
              final missed =
                  data['missedPatterns'] as List<Map<String, dynamic>>? ?? [];
              final weakTopics = data['weakTopics'] as List? ?? [];
              final pastPaperTotal = data['pastPaperTotal'] as int? ?? 0;
              final pastPaperCompleted =
                  data['pastPaperCompleted'] as int? ?? 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advanced Insights',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (pastPaperTotal >
                      0) // ignore: curly_braces_in_flow_control_structures
                    _buildPastPaperCard(
                      context,
                      pastPaperCompleted,
                      pastPaperTotal,
                    ),
                  if (accuracy.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimate Accuracy',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ...accuracy.take(5).map((row) {
                              final estimated =
                                  row['estimated_minutes'] as int? ?? 0;
                              final actual = row['actual_minutes'] as int? ?? 0;
                              final diff = actual - estimated;
                              final pct =
                                  estimated > 0
                                      ? ((actual / estimated) * 100).round()
                                      : 0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        row['task_title'] as String? ?? 'Task',
                                      ),
                                    ),
                                    Semantics(
                                      label:
                                          '$pct percent completion for ${row['task_title']}',
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              diff > 10
                                                  ? Colors.red.withValues(
                                                    alpha: 0.1,
                                                  )
                                                  : (diff < -5
                                                      ? Colors.green.withValues(
                                                        alpha: 0.1,
                                                      )
                                                      : Colors.orange
                                                          .withValues(
                                                            alpha: 0.1,
                                                          )),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          '$pct%',
                                          style: TextStyle(
                                            color:
                                                diff > 10
                                                    ? Colors.red
                                                    : (diff < -5
                                                        ? Colors.green
                                                        : Colors.orange),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (weakTopics.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Weak Topics',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...weakTopics.map((topic) {
                              if (topic is! ChapterModel) {
                                return const SizedBox.shrink();
                              }
                              final c = topic;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.bookmark,
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(c.title)),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (productive.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Productive Hours',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ...productive.take(3).map((row) {
                              final hour =
                                  int.tryParse(
                                    row['hour_of_day'] as String? ?? '0',
                                  ) ??
                                  0;
                              final mins = row['total_minutes'] as int? ?? 0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${hour.toString().padLeft(2, '0')}:00',
                                      ),
                                    ),
                                    Text('$mins min'),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (missed.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Missed Session Patterns',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ...missed.take(5).map((row) {
                              final planDate =
                                  row['plan_date'] as String? ?? '';
                              final planned =
                                  (row['planned_count'] as int?) ?? 0;
                              final done = (row['done_count'] as int?) ?? 0;
                              if (planned == 0) return const SizedBox.shrink();
                              final ratio =
                                  planned > 0
                                      ? (done / planned * 100).round()
                                      : 0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(planDate)),
                                    Text('$done/$planned ($ratio%)'),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Something went wrong. Please try again.')),
          ),
          const SizedBox(height: 24),
          recallTrendsAsync.when(
            data: (trends) {
              if (trends.isEmpty) {
                return const SizedBox.shrink();
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recall Trends',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      ...trends.take(30).map((row) {
                        final date = row['review_date'] as String? ?? '';
                        final subject =
                            row['subject_name'] as String? ?? 'Unknown';
                        final avgConf =
                            (row['avg_confidence'] as num?)?.toDouble() ?? 0.0;
                        final count = (row['review_count'] as int?) ?? 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(child: Text('$date • $subject')),
                              Container(
                                width: 80,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (avgConf / 100).clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          avgConf >= 70
                                              ? Colors.green
                                              : (avgConf >= 40
                                                  ? Colors.orange
                                                  : Colors.red),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${avgConf.toStringAsFixed(0)}% ($count)'),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Something went wrong. Please try again.')),
          ),
          const SizedBox(height: 24),
          decayAsync.when(
            data: (decay) {
              if (decay.isEmpty) {
                return const SizedBox.shrink();
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subject Confidence Decay',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      ...decay.map((row) {
                        final subject =
                            row['subject_name'] as String? ?? 'Unknown';
                        final avgConf =
                            (row['avg_confidence'] as num?)?.toDouble() ?? 0.0;
                        final totalReviews =
                            (row['total_reviews'] as int?) ?? 0;
                        final lowCount =
                            (row['low_confidence_count'] as int?) ?? 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(child: Text(subject)),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: (avgConf / 100).clamp(0.0, 1.0),
                                        backgroundColor: Colors.grey.withValues(
                                          alpha: 0.2,
                                        ),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              avgConf >= 70
                                                  ? Colors.green
                                                  : (avgConf >= 40
                                                      ? Colors.orange
                                                      : Colors.red),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('${avgConf.toStringAsFixed(0)}%'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('($totalReviews reviews, $lowCount low)'),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Something went wrong. Please try again.')),
          ),
        ],
      ),
    );
  }

  Widget _buildPastPaperCard(BuildContext context, int completed, int total) {
    final ratio = total > 0 ? ((completed / total) * 100).round() : 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment, size: 36, color: Colors.teal),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Past Papers',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '$completed / $total completed',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  '$ratio%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
