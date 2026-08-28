import 'package:flutter/material.dart';

import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TodoItem({
    super.key,
    required this.todo,
    required this.index,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      elevation: isDark ? 0 : 1,
      color: isDark ? Colors.grey[850] : null,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: Todo.getPriorityColor(todo.priority),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                todo.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: todo.isDone
                    ? Colors.green
                    : (isDark ? Colors.grey[500] : Colors.grey),
              ),
              onPressed: onToggle,
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: todo.isDone
                      ? (isDark ? Colors.grey[600] : Colors.grey)
                      : (isDark ? Colors.white : Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Todo.getPriorityColor(todo.priority)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                todo.priority.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Todo.getPriorityColor(todo.priority),
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        onLongPress: onEdit,
      ),
    );
  }
}
