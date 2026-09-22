import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dialogs/confirm_dialog.dart';
import '../logic/todo_archiver.dart';
import '../logic/todo_filter.dart';
import '../logic/todo_grouping.dart';
import '../models/todo.dart';
import '../services/todo_storage.dart';
import '../widgets/add_todo_bottom_sheet.dart';
import '../widgets/edit_todo_bottom_sheet.dart';
import '../widgets/export_bottom_sheet.dart';
import '../widgets/import_bottom_sheet.dart';
import '../widgets/search_input.dart';
import '../widgets/selection_action_bar.dart';
import '../widgets/sort_dropdown.dart';
import '../widgets/todo_group.dart';
import '../widgets/todo_stats.dart';
import 'archive_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  TodoScreenState createState() => TodoScreenState();
}

class TodoScreenState extends State<TodoScreen> {
  List<Todo> todos = [];
  List<Todo> filteredTodos = [];

  final TextEditingController searchController = TextEditingController();

  String searchQuery = '';
  SortOption currentSort = SortOption.newest;

  final Set<Todo> selectedTodos = {};
  bool isSelectionMode = false;

  int get archivedCount => todos.where((t) => t.isArchived).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupedTodos = TodoGrouper.groupTodos(filteredTodos);

    final activeTodos = todos.where((t) => !t.isArchived).toList();

    int doneCount = activeTodos.where((todo) => todo.isDone).length;
    bool allDone = activeTodos.isNotEmpty && doneCount == activeTodos.length;

    return Scaffold(
      appBar: isSelectionMode
          ? _buildSelectionAppBar()
          : _buildNormalAppBar(allDone),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: isSelectionMode
          ? null
          : Container(
              margin: const EdgeInsets.only(bottom: 60),
              child: FloatingActionButton(
                onPressed: openAddSheet,
                tooltip: 'Add task',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.add),
              ),
            ),
      body: Container(
        margin: const EdgeInsetsGeometry.only(top: 20),
        child: Column(
          spacing: 8,
          children: [
            if (!isSelectionMode)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: SearchInput(
                        controller: searchController,
                        query: searchQuery,
                        onClear: () {
                          searchController.clear();
                        },
                      ),
                    ),
                    SortDropdown(
                      currentSort: currentSort,
                      onSortChanged: (sortOption) {
                        setState(() {
                          currentSort = sortOption;
                          _filterAndSortTodos();
                        });
                      },
                    ),
                  ],
                ),
              ),

            Expanded(
              child: filteredTodos.isEmpty
                  ? Center(
                      child: Column(
                        spacing: 16,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                          ),
                          Text(
                            searchQuery.isEmpty
                                ? 'No tasks yet! Tap + to add one.'
                                : 'No tasks match your search.',
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
                  : RefreshIndicator(
                      onRefresh: _refreshTodos,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: DateGroup.values.length,
                        itemBuilder: (context, groupIndex) {
                          final group = DateGroup.values[groupIndex];
                          final tasks = groupedTodos[group] ?? [];
                          return TodoGroup(
                            group: group,
                            tasks: tasks,
                            isDark: isDark,
                            onToggle: toggleDone,
                            onDelete: deleteTodo,
                            onEdit: editTodo,
                            onLongPress: enterSelectionMode,
                            selectedTodos: selectedTodos,
                            isSelectionMode: isSelectionMode,
                            onSelectionToggle: toggleSelection,
                            onGroupSelectToggle: () =>
                                toggleGroupSelection(tasks),
                            searchQuery: searchQuery,
                            onUpdate: (updatedTodo) {
                              final index = todos.indexWhere(
                                (t) => t.id == updatedTodo.id,
                              );
                              if (index < 0) return;
                              setState(() {
                                todos[index] = updatedTodo;
                              });
                              _saveTodos();
                              _filterAndSortTodos();
                            },
                          );
                        },
                      ),
                    ),
            ),

            if (isSelectionMode)
              SelectionActionBar(
                selectedCount: selectedTodos.length,
                onCopy: openExportSheet,
                onToggleDone: bulkToggleDone,
                onArchive: bulkArchive,
                onDelete: bulkDelete,
                onCancel: exitSelectionMode,
              )
            else
              TodoStats(
                total: activeTodos.length,
                left: activeTodos.where((todo) => !todo.isDone).length,
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }

  void bulkArchive() {
    if (selectedTodos.isEmpty) return;
    HapticFeedback.mediumImpact();

    final now = DateTime.now();
    final toArchive = Set<Todo>.from(selectedTodos);

    setState(() {
      for (final todo in toArchive) {
        final index = todos.indexWhere((t) => t.id == todo.id);
        if (index < 0) continue;
        todos[index] = todos[index].copyWith(archivedAt: now);
      }
    });
    _saveTodos();
    _filterAndSortTodos();
    exitSelectionMode();

    _showUndoSnack(
      '${toArchive.length} task${toArchive.length > 1 ? 's' : ''} archived',
      () {
        setState(() {
          for (final todo in toArchive) {
            final index = todos.indexWhere((t) => t.id == todo.id);
            if (index < 0) continue;
            todos[index] = todos[index].copyWith(clearArchivedAt: true);
          }
        });
        _saveTodos();
        _filterAndSortTodos();
      },
    );
  }

  Future<void> bulkDelete() async {
    if (selectedTodos.isEmpty) return;

    if (selectedTodos.length >= 3) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: 'Delete ${selectedTodos.length} tasks?',
        message:
            'This will remove ${selectedTodos.length} tasks. You can undo afterwards.',
        confirmLabel: 'Delete',
        confirmColor: Colors.red,
        icon: Icons.warning_amber_rounded,
      );
      if (!confirmed) return;
    }

    HapticFeedback.mediumImpact();
    final toDelete = Set<Todo>.from(selectedTodos);

    setState(() {
      todos.removeWhere((t) => toDelete.contains(t));
    });
    _saveTodos();
    _filterAndSortTodos();
    exitSelectionMode();

    _showUndoSnack(
      '${toDelete.length} task${toDelete.length > 1 ? 's' : ''} deleted',
      () {
        setState(() {
          todos.addAll(toDelete);
        });
        _saveTodos();
        _filterAndSortTodos();
      },
    );
  }

  void bulkToggleDone() {
    if (selectedTodos.isEmpty) return;
    HapticFeedback.selectionClick();

    final allDone = selectedTodos.every((t) => t.isDone);
    setState(() {
      for (final todo in selectedTodos.toList()) {
        final index = todos.indexOf(todo);
        if (index != -1) {
          todos[index] = todos[index].copyWith(isDone: !allDone);
        }
      }
    });
    _saveTodos();
    _filterAndSortTodos();
    exitSelectionMode();
  }

  Future<void> clearCompleted() async {
    final completed = todos.where((t) => t.isDone && !t.isArchived).toList();
    if (completed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No completed tasks to clear'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final confirmed = await ConfirmDialog.show(
      context,
      title:
          'Clear ${completed.length} completed task${completed.length > 1 ? 's' : ''}?',
      message: 'This will remove all completed tasks. You can undo afterwards.',
      confirmLabel: 'Clear',
      confirmColor: Colors.red,
      icon: Icons.cleaning_services,
    );
    if (!confirmed) return;

    HapticFeedback.mediumImpact();
    final backup = List<Todo>.from(completed);

    setState(() {
      todos.removeWhere((todo) => todo.isDone && !todo.isArchived);
    });
    _saveTodos();
    _filterAndSortTodos();

    _showUndoSnack(
      '${backup.length} completed task${backup.length > 1 ? 's' : ''} cleared',
      () {
        setState(() {
          todos.addAll(backup);
        });
        _saveTodos();
        _filterAndSortTodos();
      },
    );
  }

  void deleteTodo(Todo todo) {
    HapticFeedback.lightImpact();
    final index = todos.indexOf(todo);
    final deleted = todos[index];

    setState(() {
      todos.removeAt(index);
      selectedTodos.remove(todo);
      if (selectedTodos.isEmpty) isSelectionMode = false;
    });
    _saveTodos();
    _filterAndSortTodos();

    _showUndoSnack('Task deleted', () {
      setState(() {
        todos.insert(index.clamp(0, todos.length), deleted);
      });
      _saveTodos();
      _filterAndSortTodos();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> editTodo(Todo todo) async {
    HapticFeedback.selectionClick();
    final updated = await showModalBottomSheet<Todo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (_) => EditTodoBottomSheet(todo: todo),
    );

    if (updated == null) return;

    final index = todos.indexWhere((t) => t.id == updated.id);
    if (index < 0) return;

    setState(() {
      todos[index] = updated;
    });
    _saveTodos();
    _filterAndSortTodos();
  }

  void enterSelectionMode(Todo todo) {
    HapticFeedback.mediumImpact();
    setState(() {
      isSelectionMode = true;
      selectedTodos.add(todo);
    });
  }

  void exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedTodos.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTodos();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
        _filterAndSortTodos();
      });
    });
  }

  Future<void> openAddSheet() async {
    HapticFeedback.selectionClick();
    final newTodo = await showModalBottomSheet<Todo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (_) => const AddTodoBottomSheet(),
    );

    if (newTodo == null) return;

    HapticFeedback.mediumImpact();
    setState(() {
      todos.add(newTodo);
    });
    _saveTodos();
    _filterAndSortTodos();

    _showUndoSnack('Task added', () {
      setState(() {
        todos.removeWhere((t) => t.id == newTodo.id);
      });
      _saveTodos();
      _filterAndSortTodos();
    });
  }

  void openArchiveScreen() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArchiveScreen(
          todos: todos,
          onSave: (updated) {
            setState(() {
              todos = updated;
            });
            _saveTodos();
            _filterAndSortTodos();
          },
        ),
      ),
    );
  }

  void openExportSheet() {
    if (selectedTodos.isEmpty) return;
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (_) => ExportBottomSheet(todos: selectedTodos.toList()),
    );
  }

  void openImportSheet() {
    HapticFeedback.selectionClick();
    final active = todos.where((t) => !t.isArchived).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (_) => ImportBottomSheet(
        existingTitles: active.map((t) => t.title).toSet(),
        onImport: (importedTodos) {
          HapticFeedback.mediumImpact();
          final backup = List<Todo>.from(importedTodos);
          setState(() {
            todos.addAll(importedTodos);
          });
          _saveTodos();
          _filterAndSortTodos();

          _showUndoSnack(
            'Imported ${backup.length} task${backup.length > 1 ? 's' : ''}',
            () {
              setState(() {
                todos.removeWhere((t) => backup.contains(t));
              });
              _saveTodos();
              _filterAndSortTodos();
            },
          );
        },
      ),
    );
  }

  void toggleDone(Todo todo) {
    HapticFeedback.lightImpact();
    final index = todos.indexOf(todo);
    setState(() {
      todos[index] = todos[index].copyWith(isDone: !todos[index].isDone);
    });
    _saveTodos();
    _filterAndSortTodos();
  }

  void toggleGroupSelection(List<Todo> groupTasks) {
    HapticFeedback.selectionClick();
    setState(() {
      final allSelected = groupTasks.every((t) => selectedTodos.contains(t));
      if (allSelected) {
        selectedTodos.removeAll(groupTasks);
      } else {
        selectedTodos.addAll(groupTasks);
      }
      if (selectedTodos.isEmpty) {
        isSelectionMode = false;
      }
    });
  }

  void toggleSelectAll() {
    HapticFeedback.selectionClick();
    final active = todos.where((t) => !t.isArchived).toList();
    setState(() {
      bool allDone = active.every((todo) => todo.isDone);
      for (var todo in active) {
        final index = todos.indexWhere((t) => t.id == todo.id);
        if (index == -1) continue;
        todos[index] = todos[index].copyWith(isDone: !allDone);
      }
    });
    _saveTodos();
    _filterAndSortTodos();
  }

  void toggleSelection(Todo todo) {
    HapticFeedback.selectionClick();
    setState(() {
      if (selectedTodos.contains(todo)) {
        selectedTodos.remove(todo);
      } else {
        selectedTodos.add(todo);
      }
      if (selectedTodos.isEmpty) {
        isSelectionMode = false;
      }
    });
  }

  AppBar _buildNormalAppBar(bool allDone) {
    return AppBar(
      title: const Text('Do Deez'),
      actions: [
        IconButton(
          icon: Badge(
            isLabelVisible: archivedCount > 0,
            label: Text('$archivedCount'),
            child: const Icon(Icons.archive_outlined),
          ),
          onPressed: openArchiveScreen,
          tooltip: 'Archive',
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: openImportSheet,
          tooltip: 'Import tasks',
        ),
        IconButton(
          icon: const Icon(Icons.select_all),
          onPressed: filteredTodos.isEmpty ? null : toggleSelectAll,
          tooltip: allDone ? 'Unselect all' : 'Select all',
        ),
        IconButton(
          icon: const Icon(Icons.cleaning_services),
          onPressed: clearCompleted,
          tooltip: 'Clear completed tasks',
        ),
      ],
    );
  }

  AppBar _buildSelectionAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary
          .withValues(alpha: 0.15),
      automaticallyImplyLeading: false,
      title: const Text('Select tasks'),
      actions: [
        IconButton(
          icon: const Icon(Icons.select_all),
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (selectedTodos.length == filteredTodos.length) {
                selectedTodos.clear();
                isSelectionMode = false;
              } else {
                selectedTodos.addAll(filteredTodos);
              }
            });
          },
          tooltip: 'Select all visible',
        ),
      ],
    );
  }

  void _filterAndSortTodos() {
    setState(() {
      List<Todo> filtered = TodoFilter.filterTodos(todos, searchQuery);
      filteredTodos = _sortTodos(filtered);
    });
  }

  void _loadTodos() async {
    final loaded = await TodoStorage.loadTodos();
    final auto = TodoArchiver.autoArchive(loaded);

    if (auto.any((t) => t.isArchived) && !loaded.any((t) => t.isArchived)) {
      await TodoStorage.saveTodos(auto);
    } else if (!_todosEqual(auto, loaded)) {
      await TodoStorage.saveTodos(auto);
    }

    setState(() {
      todos = auto;
      _filterAndSortTodos();
    });
  }

  Future<void> _refreshTodos() async {
    HapticFeedback.selectionClick();
    _loadTodos();
  }

  void _saveTodos() {
    TodoStorage.saveTodos(todos);
  }

  void _showUndoSnack(String message, VoidCallback onUndo) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        persist: false,
        content: Text(message),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(label: 'UNDO', onPressed: onUndo),
      ),
    );
  }

  List<Todo> _sortTodos(List<Todo> todosToSort) {
    List<Todo> sorted = List.from(todosToSort);

    switch (currentSort) {
      case SortOption.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.oldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.priorityHigh:
        sorted.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case SortOption.priorityLow:
        sorted.sort((a, b) => a.priority.index.compareTo(b.priority.index));
        break;
      case SortOption.alphabetical:
        sorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }

    final incomplete = sorted.where((t) => !t.isDone).toList();
    final complete = sorted.where((t) => t.isDone).toList();

    return [...incomplete, ...complete];
  }

  bool _todosEqual(List<Todo> a, List<Todo> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].archivedAt != b[i].archivedAt) return false;
    }
    return true;
  }
}
