import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/database_provider.dart';
import '../../data/models/app_models.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _searching = false;
  String _filter = 'all';
  String _subjectFilter = 'all';
  final String _statusFilter = 'all';
  List<SubjectModel> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final db = ref.read(databaseRepositoryProvider).value;
    if (db == null) return;
    final subjects = await db.getSubjects();
    if (mounted) {
      setState(() => _subjects = subjects);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    final db = ref.read(databaseRepositoryProvider).value;
    if (db == null) return;
    setState(() => _searching = true);
    final results = await db.search(query);
    setState(() {
      _searching = false;
      _results = _applyFilters(results);
    });
  }

  List<dynamic> _applyFilters(List<dynamic> results) {
    var filtered = results;
    if (_filter != 'all') {
      filtered =
          filtered.where((item) {
            if (_filter == 'tasks') return item is TaskModel;
            if (_filter == 'subjects') return item is SubjectModel;
            if (_filter == 'chapters') return item is ChapterModel;
            if (_filter == 'resources') return item is ResourceModel;
            if (_filter == 'practicals') return item is PracticalRecordModel;
            return true;
          }).toList();
    }
    if (_subjectFilter != 'all') {
      final subjectId = int.tryParse(_subjectFilter);
      if (subjectId != null) {
        filtered =
            filtered.where((item) {
              if (item is TaskModel) return item.subjectId == subjectId;
              if (item is ChapterModel) return item.subjectId == subjectId;
              if (item is ResourceModel) return item.subjectId == subjectId;
              if (item is PracticalRecordModel) {
                return item.subjectId == subjectId;
              }
              return true;
            }).toList();
      }
    }
    if (_statusFilter != 'all') {
      filtered =
          filtered.where((item) {
            if (item is TaskModel) return item.status == _statusFilter;
            if (item is ChapterModel) return item.status == _statusFilter;
            return true;
          }).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search tasks, subjects, chapters, resources...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _performSearch(_controller.text),
                ),
              ),
              onChanged: _performSearch,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == 'all',
                  onTap:
                      () => setState(() {
                        _filter = 'all';
                        _performSearch(_controller.text);
                      }),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Tasks',
                  selected: _filter == 'tasks',
                  onTap:
                      () => setState(() {
                        _filter = 'tasks';
                        _performSearch(_controller.text);
                      }),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Subjects',
                  selected: _filter == 'subjects',
                  onTap:
                      () => setState(() {
                        _filter = 'subjects';
                        _performSearch(_controller.text);
                      }),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Chapters',
                  selected: _filter == 'chapters',
                  onTap:
                      () => setState(() {
                        _filter = 'chapters';
                        _performSearch(_controller.text);
                      }),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Resources',
                  selected: _filter == 'resources',
                  onTap:
                      () => setState(() {
                        _filter = 'resources';
                        _performSearch(_controller.text);
                      }),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Practicals',
                  selected: _filter == 'practicals',
                  onTap:
                      () => setState(() {
                        _filter = 'practicals';
                        _performSearch(_controller.text);
                      }),
                ),
              ],
            ),
          ),
                 const SizedBox(height: 8),
                 if (_subjects.isNotEmpty)
                   DropdownButtonFormField<String>(
                     decoration: const InputDecoration(
                       labelText: 'Subject',
                       border: OutlineInputBorder(),
                       isDense: true,
                       contentPadding: EdgeInsets.symmetric(
                         horizontal: 12,
                         vertical: 8,
                       ),
                       hintStyle: TextStyle(fontSize: 13),
                     ),
                     initialValue: _subjectFilter,
                     hint: const Text('All subjects'),
                     items: [
                       const DropdownMenuItem(
                         value: 'all',
                         child: Text('All subjects'),
                       ),
                       ..._subjects.map((s) {
                         return DropdownMenuItem(
                           value: s.id?.toString() ?? 'all',
                           child: Text(s.name),
                         );
                       }),
                     ],
                     onChanged: (v) {
                       setState(() => _subjectFilter = v ?? 'all');
                       _performSearch(_controller.text);
                     },
                   ),
          if (_searching)
            const Expanded(child: Center(child: CircularProgressIndicator())),
          Expanded(
            child:
                _results.isEmpty && _controller.text.isNotEmpty && !_searching
                    ? const Center(child: Text('No results found'))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        if (item is TaskModel) {
                          return Card(
                            child: ListTile(
                              title: Text(item.title),
                              subtitle: Text(
                                'Task • ${item.estimatedMinutes} min',
                              ),
                              onTap:
                                  () => GoRouter.of(
                                    context,
                                  ).push('/focus', extra: {'taskId': item.id}),
                            ),
                          );
                        } else if (item is SubjectModel) {
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(item.color),
                                child: const Icon(Icons.book),
                              ),
                              title: Text(item.name),
                              onTap: () {
                                if (item.id == null) return;
                                GoRouter.of(
                                  context,
                                ).push('/subjects/${item.id}');
                              },
                            ),
                          );
                        } else if (item is ChapterModel) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.menu_book),
                              title: Text(item.title),
                              subtitle: Text('Chapter • ${item.status}'),
                              onTap: () {
                                final subjectId = item.subjectId;
                                GoRouter.of(
                                  context,
                                ).push('/subjects/$subjectId');
                              },
                            ),
                          );
                        } else if (item is ResourceModel) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.picture_as_pdf),
                              title: Text(item.title),
                              subtitle: Text('Resource • ${item.type}'),
                              onTap: () {
                                if (!item.localPath.startsWith('/')) return;
                                GoRouter.of(context).push(
                                  '/pdf',
                                  extra: {
                                    'path': item.localPath,
                                    'title': item.title,
                                  },
                                );
                              },
                            ),
                          );
                        } else if (item is PracticalRecordModel) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.science),
                              title: Text(item.title),
                              subtitle: Text('Practical • ${item.status}'),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
