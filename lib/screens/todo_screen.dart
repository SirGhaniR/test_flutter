import 'package:flutter/material.dart';

import '../dialogs/edit_todo_dialog.dart';
import '../logic/todo_filter.dart';
import '../logic/todo_grouping.dart';
import '../models/todo.dart';
import '../services/todo_storage.dart';
import '../widgets/add_todo_input.dart';
import '../widgets/search_input.dart';
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
  final TextEditingController controller = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  Priority selectedPriority = Priority.low;
  String searchQuery = '';

  void addTodo() {
    if (controller.text.isNotEmpty) {
      setState(() {
        todos.add(Todo(title: controller.text, priority: selectedPriority));
        controller.clear();
      });
      _saveTodos();
      _filterTodos();
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
      body: Column(
        children: [
          SearchInput(
            controller: searchController,
            query: searchQuery,
            onClear: () {
              searchController.clear();
            },
          ),
          AddTodoInput(
            controller: controller,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty
                              ? 'No tasks yet! Add one above.'
                              : 'No tasks match your search.',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
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
    );
  }

  void clearCompleted() {
    setState(() {
      todos.removeWhere((todo) => todo.isDone);
    });
    _saveTodos();
    _filterTodos();
  }

  void deleteTodo(Todo todo) {
    final index = todos.indexOf(todo);
    setState(() {
      lastDeleted = todos[index];
      lastDeletedIndex = index;
      todos.removeAt(index);
    });
    _saveTodos();
    _filterTodos();

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
              _filterTodos();
            }
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void editTodo(Todo todo) {
    final index = todos.indexOf(todo);
    showDialog(
      context: context,
      builder: (context) => EditTodoDialog(
        todo: todo,
        onSave: (newTitle, newPriority) {
          setState(() {
            todos[index] = Todo(
              title: newTitle,
              isDone: todos[index].isDone,
              priority: newPriority,
              createdAt: todos[index].createdAt,
            );
          });
          _saveTodos();
          _filterTodos();
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
        _filterTodos();
      });
    });
  }

  void toggleDone(Todo todo) {
    final index = todos.indexOf(todo);
    setState(() {
      todos[index] = Todo(
        title: todos[index].title,
        isDone: !todos[index].isDone,
        priority: todos[index].priority,
        createdAt: todos[index].createdAt,
      );
    });
    _saveTodos();
    _filterTodos();
  }

  void toggleSelectAll() {
    setState(() {
      bool allDone = todos.every((todo) => todo.isDone);
      for (var todo in todos) {
        todo.isDone = !allDone;
      }
    });
    _saveTodos();
    _filterTodos();
  }

  void _filterTodos() {
    setState(() {
      filteredTodos = TodoFilter.filterTodos(todos, searchQuery);
    });
  }

  void _loadTodos() async {
    final loadedTodos = await TodoStorage.loadTodos();
    setState(() {
      todos = loadedTodos;
      _filterTodos();
    });
  }

  void _saveTodos() {
    TodoStorage.saveTodos(todos);
  }
}
