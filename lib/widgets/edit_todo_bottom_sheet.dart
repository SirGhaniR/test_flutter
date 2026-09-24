import 'package:flutter/material.dart';

import '../models/todo.dart';
import 'priority_selector.dart';
import 'subtask_draft_input.dart';

class EditTodoBottomSheet extends StatefulWidget {
  final Todo todo;

  const EditTodoBottomSheet({super.key, required this.todo});

  @override
  State<EditTodoBottomSheet> createState() => _EditTodoBottomSheetState();
}

class _EditTodoBottomSheetState extends State<EditTodoBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late Priority _priority;
  late List<Subtask> _subtasks;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              spacing: 12,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.edit, color: accent),
                    Text(
                      'Edit Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),

                TextField(
                  controller: _titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Task title...',
                    border: OutlineInputBorder(),
                    labelText: 'Title',
                  ),
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
                        label: const Text('Save'),
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
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(
      text: widget.todo.description,
    );
    _priority = widget.todo.priority;
    _subtasks = List<Subtask>.from(widget.todo.subtasks);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final updated = widget.todo.copyWith(
      title: title,
      description: _descriptionController.text.trim(),
      priority: _priority,
      subtasks: _subtasks,
    );

    Navigator.pop(context, updated);
  }
}
