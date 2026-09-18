import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dialogs/confirm_dialog.dart';
import '../dialogs/edit_todo_dialog.dart';
import '../logic/todo_filter.dart';
import '../logic/todo_grouping.dart';
import '../models/todo.dart';
import '../services/todo_storage.dart';
import '../widgets/add_todo_input.dart';
import '../widgets/export_bottom_sheet.dart';
import '../widgets/import_bottom_sheet.dart';
import '../widgets/search_input.dart';
import '../widgets/selection_action_bar.dart';
import '../widgets/sort_dropdown.dart';
import '../widgets/todo_group.dart';
import '../widgets/todo_stats.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  TodoScreenState createState() => TodoScreenState();
}

class TodoScreenState extends State<TodoScreen> {
  List<Todo> todos = [];
  List<Todo> filteredTodos = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  Priority selectedPriority = Priority.low;
  String searchQuery = '';
  SortOption currentSort = SortOption.newest;

  final Set<Todo> selectedTodos = {};
  bool isSelectionMode = false;

  void addTodo() {
    if (titleController.text.isNotEmpty) {
      HapticFeedback.selectionClick();
      setState(() {
        todos.add(
          Todo(
            title: titleController.text,
            description: descriptionController.text,
            priority: selectedPriority,
          ),
        );
        titleController.clear();
        descriptionController.clear();
      });
      _saveTodos();
      _filterAndSortTodos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupedTodos = TodoGrouper.groupTodos(filteredTodos);

    int doneCount = filteredTodos.where((todo) => todo.isDone).length;
    bool allDone =
        filteredTodos.isNotEmpty && doneCount == filteredTodos.length;

    return Scaffold(
      appBar: isSelectionMode
          ? _buildSelectionAppBar()
          : _buildNormalAppBar(allDone),
      body: Container(
        margin: const EdgeInsetsGeometry.only(top: 20),
        child: Column(
          spacing: 8,
          children: [
            if (!isSelectionMode) ...[
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
              AddTodoInput(
                titleController: titleController,
                descriptionController: descriptionController,
                selectedPriority: selectedPriority,
                onPriorityChanged: (newPriority) {
                  if (newPriority != null) {
                    setState(() {
                      selectedPriority = newPriority;
                    });
                  }
                },
                onAdd: addTodo,
              ),
            ],

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
                                ? 'No tasks yet! Add one above.'
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
                onDelete: bulkDelete,
                onCancel: exitSelectionMode,
              )
            else
              TodoStats(
                total: todos.length,
                left: todos.where((todo) => !todo.isDone).length,
                isDark: isDark,
              ),
          ],
        ),
      ),
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
          todos[index] = Todo(
            title: todos[index].title,
            description: todos[index].description,
            isDone: !allDone,
            priority: todos[index].priority,
            createdAt: todos[index].createdAt,
          );
        }
      }
    });
    _saveTodos();
    _filterAndSortTodos();
    exitSelectionMode();
  }

  Future<void> clearCompleted() async {
    final completed = todos.where((t) => t.isDone).toList();
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
      todos.removeWhere((todo) => todo.isDone);
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
    titleController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void editTodo(Todo todo) {
    final index = todos.indexOf(todo);
    showDialog(
      context: context,
      builder: (context) => EditTodoDialog(
        todo: todo,
        onSave: (String newTitle, String newDescription, Priority newPriority) {
          HapticFeedback.selectionClick();
          setState(() {
            todos[index] = Todo(
              title: newTitle,
              description: newDescription,
              isDone: todos[index].isDone,
              priority: newPriority,
              createdAt: todos[index].createdAt,
            );
          });
          _saveTodos();
          _filterAndSortTodos();
        },
      ),
    );
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
        existingTitles: todos.map((t) => t.title).toSet(),
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
      todos[index] = Todo(
        title: todos[index].title,
        description: todos[index].description,
        isDone: !todos[index].isDone,
        priority: todos[index].priority,
        createdAt: todos[index].createdAt,
      );
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
    setState(() {
      bool allDone = todos.every((todo) => todo.isDone);
      for (var todo in todos) {
        todo.isDone = !allDone;
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
    final loadedTodos = await TodoStorage.loadTodos();
    setState(() {
      todos = loadedTodos;
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
}
