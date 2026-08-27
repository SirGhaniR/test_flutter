import 'package:flutter/material.dart';
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

  void addTodo() {
    if (controller.text.isNotEmpty) {
      setState(() {
        todos.add(Todo(title: controller.text));
        controller.clear();
      });
    }
  }

  void editTask(int index) {
    TextEditingController editController = TextEditingController(
      text: todos[index].title,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: editController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter new task name...',
              border: OutlineInputBorder(),
            ),
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
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void deleteTodo(int index) {
    setState(() {
      lastDeleted = todos[index];
      lastDeletedIndex = index;
      todos.removeAt(index);
    });

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
            }
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void toggleDone(int index) {
    setState(() {
      todos[index] = Todo(
        title: todos[index].title,
        isDone: !todos[index].isDone,
      );
    });
  }

  void clearCompleted() {
    setState(() {
      todos.removeWhere((todo) => todo.isDone);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List For The Great SirGhani'),
        actions: [
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
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: addTodo,
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
}
