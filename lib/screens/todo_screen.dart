import 'package:flutter/material.dart';

import '../dialogs/edit_todo_dialog.dart';
import '../logic/todo_filter.dart';
import '../logic/todo_grouping.dart';
import '../models/todo.dart';
import '../services/todo_storage.dart';
import '../widgets/add_todo_input.dart';
import '../widgets/search_input.dart';
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
  Todo? lastDeleted;
  int? lastDeletedIndex;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  Priority selectedPriority = Priority.low;
  String searchQuery = '';
  SortOption currentSort = SortOption.newest;

  void addTodo() {
    if (titleController.text.isNotEmpty) {
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
      appBar: AppBar(
        title: const Text('Todo List For The Great SirGhani'),
        actions: [
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
      ),
      body: Container(
        margin: EdgeInsetsGeometry.symmetric(horizontal: 14, vertical: 20),
        child: Column(
          spacing: 8,
          children: [
            Row(
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
                  : ListView.builder(
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
                        );
                      },
                    ),
            ),
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

  void clearCompleted() {
    setState(() {
      todos.removeWhere((todo) => todo.isDone);
    });
    _saveTodos();
    _filterAndSortTodos();
  }

  void deleteTodo(Todo todo) {
    final index = todos.indexOf(todo);
    setState(() {
      lastDeleted = todos[index];
      lastDeletedIndex = index;
      todos.removeAt(index);
    });
    _saveTodos();
    _filterAndSortTodos();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            if (lastDeleted != null && lastDeletedIndex != null) {
              setState(() {
                todos.insert(lastDeletedIndex!, lastDeleted!);
              });
              _saveTodos();
              _filterAndSortTodos();
            }
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
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

  void toggleDone(Todo todo) {
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

  void toggleSelectAll() {
    setState(() {
      bool allDone = todos.every((todo) => todo.isDone);
      for (var todo in todos) {
        todo.isDone = !allDone;
      }
    });
    _saveTodos();
    _filterAndSortTodos();
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

  void _saveTodos() {
    TodoStorage.saveTodos(todos);
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

    return sorted;
  }
}
