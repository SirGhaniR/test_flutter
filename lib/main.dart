import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TodoScreen());
  }
}

class TodoScreen extends StatefulWidget {
  const new({super.key});

  @override
  TodoScreenState createState() => TodoScreenState();
}

class TodoScreenState extends State<TodoScreen> {
  List<String> todos = [];
  List<bool> isDone = [];
  String? lastDeleted;
  int? lastDeletedIndex;
  final TextEditingController controller = TextEditingController();

  void addTodo() {
    if (controller.text.isNotEmpty) {
      setState(() {
        todos.add(controller.text);
        isDone.add(false);
        controller.clear();
      });
    }
  }

  void editTask(int index) {
    TextEditingController editController = TextEditingController(
      text: todos[index],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: TextField(
            controller: editController,
            autofocus: true,
            decoration: InputDecoration(hintText: 'Enter new task name...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  setState(() {
                    todos[index] = editController.text;
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
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
      isDone.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            if (lastDeleted != null && lastDeletedIndex != null) {
              setState(() {
                todos.insert(lastDeletedIndex!, lastDeleted!);
                isDone.insert(lastDeletedIndex!, false);
              });
            }
          },
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void toggleDone(int index) {
    setState(() {
      isDone[index] = !isDone[index];
    });
  }

  void clearCompleted() {
    setState(() {
      List<String> newTodos = [];
      List<bool> newIsDone = [];

      for (int i = 0; i < todos.length; i++) {
        if (!isDone[i]) {
          newTodos.add(todos[i]);
          newIsDone.add(isDone[i]);
        }
      }

      todos = newTodos;
      isDone = newIsDone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List For The Great SirGhani'),
        actions: [
          IconButton(
            icon: Icon(Icons.cleaning_services),
            onPressed: clearCompleted,
            tooltip: 'Clear completed tasks',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(18.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Enter a task...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(onPressed: addTodo, child: Text('Add')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    todos[index],
                    style: TextStyle(
                      decoration: isDone[index]
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isDone[index] ? Colors.grey : Colors.black,
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(
                      isDone[index]
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isDone[index] ? Colors.green : Colors.grey,
                    ),
                    onPressed: () => toggleDone(index),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteTodo(index),
                  ),
                  onLongPress: () => editTask(index),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${todos.length} tasks',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Left: ${todos.where((done) => !isDone[todos.indexOf(done)]).length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
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
