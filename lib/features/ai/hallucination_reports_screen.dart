import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ai_service.dart';

class HallucinationReportsScreen extends ConsumerStatefulWidget {
  const HallucinationReportsScreen({super.key});

  @override
  ConsumerState<HallucinationReportsScreen> createState() =>
      _HallucinationReportsScreenState();
}

class _HallucinationReportsScreenState
    extends ConsumerState<HallucinationReportsScreen> {
  late Future<List<dynamic>> _reportsFuture;
  bool _isDeletingAll = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    final service = AIService();
    _reportsFuture = service.getHallucinationReports('local_user');
  }

  Future<void> _deleteReport(int index) async {
    final service = AIService();
    await service.deleteHallucinationReport('local_user', index);
    setState(() => _loadReports());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report deleted')),
    );
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Clear all reports?'),
            content: const Text(
              'This will permanently delete all local hallucination reports. '
              'This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Clear All'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    setState(() => _isDeletingAll = true);
    final service = AIService();
    await service.clearHallucinationReports('local_user');
    setState(() {
      _isDeletingAll = false;
      _loadReports();
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All reports cleared')),
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Unknown date';
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/'
          '${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Hallucination Reports'),
        actions: [
          if (_isDeletingAll)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
          IconButton(
            onPressed: _isDeletingAll ? null : _clearAll,
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear all reports',
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading reports: ${snapshot.error}',
                style: TextStyle(color: Colors.red.shade700),
              ),
            );
          }
          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.report_off, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hallucination reports yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _loadReports());
            },
            child: ListView.separated(
              itemCount: reports.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final report = reports[index];
                final contentId =
                    report is Map ? report['contentId'] as String? ?? 'Unknown' : 'Unknown';
                final feedback =
                    report is Map ? report['feedback'] as String? ?? '' : '';
                final reportedAt =
                    report is Map ? report['reportedAt'] as String? ?? report['createdAt'] as String? ?? '' : '';
                return Dismissible(
                  key: Key('report_$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _deleteReport(index),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text('Delete report?'),
                                content: const Text(
                                  'Remove this hallucination report from local storage?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                        ) ??
                        false;
                  },
                  child: ListTile(
                    leading: const Icon(Icons.warning_amber_rounded),
                    title: Text(contentId),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (feedback.isNotEmpty)
                          Text(
                            feedback,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          _formatDate(reportedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    isThreeLine: feedback.isNotEmpty,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text('Report Details'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Content ID: $contentId',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(feedback.isEmpty
                                        ? 'No feedback provided.'
                                        : 'Feedback: $feedback'),
                                    const SizedBox(height: 8),
                                    Text('Reported: ${_formatDate(reportedAt)}'),
                                  ],
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
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
