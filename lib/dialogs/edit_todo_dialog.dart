import 'package:flutter/material.dart';

import '../models/todo.dart';

class EditTodoDialog extends StatefulWidget {
  final Todo todo;
  final Function(String, Priority) onSave;

  const EditTodoDialog({super.key, required this.todo, required this.onSave});

  @override
  State<EditTodoDialog> createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends State<EditTodoDialog> {
  late TextEditingController editController;
  late Priority currentPriority;

  @override
  Widget build(BuildContext context) {
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
                widget.onSave(editController.text, currentPriority);
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            spacing: 8,
            children: [
              _buildPriorityButton(Priority.low),
              _buildPriorityButton(Priority.medium),
              _buildPriorityButton(Priority.high),
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
              widget.onSave(editController.text, currentPriority);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    editController = TextEditingController(text: widget.todo.title);
    currentPriority = widget.todo.priority;
  }

  Widget _buildPriorityButton(Priority priority) {
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
      onTap: () {
        setState(() {
          currentPriority = priority;
        });
      },
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
