import 'package:flutter/material.dart';

import '../../data/repositories/local_ai_repository.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final LocalAiRepository _repository = LocalAiRepository();
  List<Map<String, Object?>> _memories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final rows = await _repository.getMemories(includeInactive: true);
    if (!mounted) return;
    setState(() {
      _memories = rows;
      _loading = false;
    });
  }

  Future<void> _editMemory({Map<String, Object?>? existing}) async {
    final controller = TextEditingController(
      text: existing?['content'] as String? ?? '',
    );
    var category = existing?['category'] as String? ?? 'preference';
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Add a memory' : 'Edit memory'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'What should Retainly remember?',
                    hintText: 'I prefer step-by-step explanations in Urdu.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: const {'preference', 'goal', 'learning note', 'study context'}.contains(category)
                      ? category
                      : 'preference',
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'preference', child: Text('Preference')),
                    DropdownMenuItem(value: 'goal', child: Text('Study goal')),
                    DropdownMenuItem(value: 'learning note', child: Text('Learning note')),
                    DropdownMenuItem(value: 'study context', child: Text('Study context')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => category = value);
                    }
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'Memories stay in the app database on this device. If you use online AI, a relevant memory may be included with that question.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    final content = controller.text.trim();
    controller.dispose();
    if (saved == true && content.isNotEmpty) {
      if (existing == null) {
        await _repository.saveMemory(content: content, category: category);
      } else {
        await _repository.updateMemory(
          existing['id'] as int,
          content,
          category: category,
        );
      }
    } else {
      return;
    }
    await _reload();
  }

  Future<void> _clearAllMemories() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all memories?'),
        content: const Text(
          'This permanently deletes every saved memory on this device. Your conversations and textbook library will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _repository.clearAllMemories();
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All saved memories were deleted from this device.')),
    );
  }

  Future<void> _deleteMemory(Map<String, Object?> memory) async {
    final id = memory['id'] as int;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this memory?'),
        content: const Text('This cannot be undone. It only deletes this saved memory, not your chat history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _repository.deleteMemory(id);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _memories.where((row) => row['is_active'] == 1).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My local memory'),
        actions: [
          IconButton(
            tooltip: 'Clear all memories',
            onPressed: _memories.isEmpty ? null : _clearAllMemories,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
          IconButton(
            tooltip: 'Add memory',
            onPressed: () => _editMemory(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editMemory(),
        icon: const Icon(Icons.add),
        label: const Text('Add memory'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.phonelink_lock_outlined, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$activeCount active memories', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                const Text(
                                  'These are saved in Retainly’s local database, not a Retainly cloud account. You can review, edit, disable or delete each one. Relevant memories can be sent to Groq only as part of an online AI request when Online AI is enabled.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _memories.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(28),
                            child: Text(
                              'No saved memories yet. Add learning preferences or use Remember on an AI response to save something deliberately.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                          itemCount: _memories.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final row = _memories[index];
                            final isActive = row['is_active'] == 1;
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  isActive ? Icons.psychology_alt_outlined : Icons.psychology_alt,
                                  color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                                ),
                                title: Text(row['content'] as String? ?? ''),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text('${row['category'] ?? 'preference'} • ${isActive ? 'Used when relevant' : 'Disabled'}'),
                                ),
                                isThreeLine: true,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (action) async {
                                    if (action == 'edit') {
                                      await _editMemory(existing: row);
                                    } else if (action == 'toggle') {
                                      await _repository.setMemoryActive(row['id'] as int, !isActive);
                                      await _reload();
                                    } else if (action == 'delete') {
                                      await _deleteMemory(row);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                    PopupMenuItem(value: 'toggle', child: Text(isActive ? 'Disable' : 'Enable')),
                                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
