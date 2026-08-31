import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';
import '../widgets/todo_item.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  TodoScreenState createState() => TodoScreenState();
}

class TodoScreenState extends State<TodoScreen> {
  List<Todo> todos = [];
  Todo? lastDeleted;
  int? lastDeletedIndex;
  final TextEditingController controller = TextEditingController();
  Priority selectedPriority = Priority.low;

  void addTodo() {
    if (controller.text.isNotEmpty) {
      setState(() {
        todos.add(Todo(title: controller.text, priority: selectedPriority));
        controller.clear();
      });
      saveTodos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int doneCount = todos.where((todo) => todo.isDone).length;
    bool allDone = todos.isNotEmpty && doneCount == todos.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List For The Great SirGhani'),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: todos.isEmpty ? null : toggleSelectAll,
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
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter a task...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade700),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButton<Priority>(
                    value: selectedPriority,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(
                        value: Priority.low,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('Low'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: Priority.medium,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('Medium'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: Priority.high,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('High'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (Priority? newPriority) {
                      if (newPriority != null) {
                        setState(() {
                          selectedPriority = newPriority;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: addTodo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[850],
                    foregroundColor: Colors.indigoAccent,
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return TodoItem(
                  todo: todos[index],
                  index: index,
                  onToggle: () => toggleDone(index),
                  onDelete: () => deleteTodo(index),
                  onEdit: () => editTask(index),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? Colors.grey[850] : Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${todos.length} tasks',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : null,
                    ),
                  ),
                  Text(
                    'Left: ${todos.where((todo) => !todo.isDone).length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.indigoAccent : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void clearCompleted() {
    setState(() {
      todos.removeWhere((todo) => todo.isDone);
    });
    saveTodos();
  }

  void deleteTodo(int index) {
    setState(() {
      lastDeleted = todos[index];
      lastDeletedIndex = index;
      todos.removeAt(index);
    });
    saveTodos();

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
              saveTodos();
            }
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void editTask(int index) {
    TextEditingController editController = TextEditingController(
      text: todos[index].title,
    );
    Priority currentPriority = todos[index].priority;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: editController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Enter new task name...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) {
                      if (editController.text.isNotEmpty) {
                        setState(() {
                          todos[index] = Todo(
                            title: editController.text,
                            isDone: todos[index].isDone,
                            priority: currentPriority,
                            createdAt: todos[index].createdAt,
                          );
                        });
                        saveTodos();
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    spacing: 8,
                    children: [
                      _buildPriorityButton(
                        context,
                        Priority.low,
                        currentPriority,
                        (priority) {
                          setStateDialog(() {
                            currentPriority = priority;
                          });
                        },
                      ),
                      _buildPriorityButton(
                        context,
                        Priority.medium,
                        currentPriority,
                        (priority) {
                          setStateDialog(() {
                            currentPriority = priority;
                          });
                        },
                      ),
                      _buildPriorityButton(
                        context,
                        Priority.high,
                        currentPriority,
                        (priority) {
                          setStateDialog(() {
                            currentPriority = priority;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (editController.text.isNotEmpty) {
                      setState(() {
                        todos[index] = Todo(
                          title: editController.text,
                          isDone: todos[index].isDone,
                          priority: currentPriority,
                          createdAt: todos[index].createdAt,
                        );
                      });
                      saveTodos();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  void loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? titles = prefs.getStringList('titles');
    List<String>? done = prefs.getStringList('done');
    List<String>? priorities = prefs.getStringList('priorities');
    List<String>? createdAt = prefs.getStringList('createdAt');
    List<String>? updatedAt = prefs.getStringList('updatedAt');

    if (titles != null && done != null) {
      setState(() {
        todos = List.generate(
          titles.length,
          (index) => Todo(
            title: titles[index],
            isDone: done[index] == 'true',
            priority: priorities != null && priorities.length > index
                ? Priority.values.firstWhere(
                    (p) => p.name == priorities[index],
                    orElse: () => Priority.medium,
                  )
                : Priority.medium,
            createdAt: createdAt != null && createdAt.length > index
                ? DateTime.parse(createdAt[index])
                : null,
            updatedAt: updatedAt != null && updatedAt.length > index
                ? DateTime.parse(updatedAt[index])
                : null,
          ),
        );
      });
    }
  }

  void saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> titles = todos.map((todo) => todo.title).toList();
    List<String> done = todos.map((todo) => todo.isDone.toString()).toList();
    List<String> priorities = todos.map((todo) => todo.priority.name).toList();
    List<String> createdAt = todos
        .map((todo) => todo.createdAt.toIso8601String())
        .toList();
    List<String> updatedAt = todos
        .map((todo) => todo.updatedAt.toIso8601String())
        .toList();

    await prefs.setStringList('titles', titles);
    await prefs.setStringList('done', done);
    await prefs.setStringList('priorities', priorities);
    await prefs.setStringList('createdAt', createdAt);
    await prefs.setStringList('updatedAt', updatedAt);
  }

  void toggleDone(int index) {
    setState(() {
      todos[index] = Todo(
        title: todos[index].title,
        isDone: !todos[index].isDone,
        priority: todos[index].priority,
        createdAt: todos[index].createdAt,
      );
    });
    saveTodos();
  }

  void toggleSelectAll() {
    setState(() {
      bool allDone = todos.every((todo) => todo.isDone);
      for (var todo in todos) {
        todo.isDone = !allDone;
      }
    });
    saveTodos();
  }

  Widget _buildPriorityButton(
    BuildContext context,
    Priority priority,
    Priority currentPriority,
    Function(Priority) onSelected,
  ) {
    bool isSelected = currentPriority == priority;
    Color color = Todo.getPriorityColor(priority);
    String label;

    switch (priority) {
      case Priority.low:
        label = 'Low';
        break;
      case Priority.medium:
        label = 'Medium';
        break;
      case Priority.high:
        label = 'High';
        break;
    }

    return GestureDetector(
      onTap: () => onSelected(priority),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
