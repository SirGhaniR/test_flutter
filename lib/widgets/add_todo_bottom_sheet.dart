import 'package:flutter/material.dart';

import '../models/todo.dart';
import 'bottom_sheet_shell.dart';
import 'priority_selector.dart';
import 'subtask_draft_input.dart';

class AddTodoBottomSheet extends StatefulWidget {
  const AddTodoBottomSheet({super.key});

  @override
  State<AddTodoBottomSheet> createState() => _AddTodoBottomSheetState();
}

class _AddTodoBottomSheetState extends State<AddTodoBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Priority _priority = Priority.low;
  List<Subtask> _subtasks = [];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return BottomSheetShell(
      icon: Icons.add_task,
      title: 'New Task',
      child: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Task title...',
              border: OutlineInputBorder(),
              labelText: 'Title',
            ),
            onSubmitted: (_) => _submit(),
          ),

          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              hintText: 'Description (optional)...',
              border: OutlineInputBorder(),
              labelText: 'Description',
            ),
            maxLines: 3,
            minLines: 2,
          ),

          PrioritySelector(
            selected: _priority,
            onChanged: (p) {
              setState(() {
                _priority = p;
              });
            },
          ),

          SubtaskDraftInput(
            subtasks: _subtasks,
            isDark: isDark,
            onChanged: (updated) {
              setState(() {
                _subtasks = updated;
              });
            },
          ),

          Row(
            spacing: 12,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Add Task'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final todo = Todo(
      title: title,
      description: _descriptionController.text.trim(),
      priority: _priority,
      subtasks: _subtasks,
    );

    Navigator.pop(context, todo);
  }
}
