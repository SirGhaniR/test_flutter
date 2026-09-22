import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dialogs/confirm_dialog.dart';
import '../logic/todo_filter.dart';
import '../models/todo.dart';
import '../widgets/archive_item.dart';
import '../widgets/search_input.dart';

class ArchiveScreen extends StatefulWidget {
  final List<Todo> todos;
  final Function(List<Todo>) onSave;

  const ArchiveScreen({super.key, required this.todos, required this.onSave});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  late List<Todo> _todos;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Todo> get _archived => TodoFilter.filterArchived(_todos, _searchQuery);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final list = _archived;

    return Scaffold(
      appBar: AppBar(title: const Text('Archive')),
      body: Container(
        margin: const EdgeInsets.only(top: 12),
        child: Column(
          spacing: 8,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              child: SearchInput(
                controller: _searchController,
                query: _searchQuery,
                onClear: () {
                  _searchController.clear();
                },
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Column(
                        spacing: 16,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.archive_outlined,
                            size: 64,
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                          ),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Nothing archived yet.'
                                : 'No archived tasks match.',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final todo = list[i];
                        return ArchiveItem(
                          todo: todo,
                          onRestore: () => _restore(todo),
                          onDelete: () => _deletePermanently(todo),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _todos = List<Todo>.from(widget.todos);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _deletePermanently(Todo todo) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete permanently?',
      message: '"${todo.title}" will be gone forever.',
      confirmLabel: 'Delete',
      confirmColor: Colors.red,
      icon: Icons.warning_amber_rounded,
    );

    if (!mounted) return;
    if (!confirmed) return;

    HapticFeedback.mediumImpact();
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index < 0) return;

    final removed = _todos[index];
    setState(() {
      _todos.removeAt(index);
    });
    widget.onSave(_todos);

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        persist: false,
        content: const Text('Deleted permanently'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _todos.insert(index.clamp(0, _todos.length), removed);
            });
            widget.onSave(_todos);
          },
        ),
      ),
    );
  }

  void _restore(Todo todo) {
    HapticFeedback.selectionClick();
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index < 0) return;

    setState(() {
      _todos[index] = todo.copyWith(clearArchivedAt: true);
    });
    widget.onSave(_todos);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        persist: false,
        content: Text('Restored "${todo.title}"'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            final restoreIndex = _todos.indexWhere((t) => t.id == todo.id);
            if (restoreIndex < 0) return;
            setState(() {
              _todos[restoreIndex] = _todos[restoreIndex].copyWith(
                archivedAt: todo.archivedAt,
              );
            });
            widget.onSave(_todos);
          },
        ),
      ),
    );
  }
}
