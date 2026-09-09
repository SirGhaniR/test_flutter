import 'package:flutter/material.dart';

import '../models/todo.dart';

class AddTodoInput extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final Priority selectedPriority;
  final ValueChanged<Priority?> onPriorityChanged;
  final VoidCallback onAdd;

  const AddTodoInput({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedPriority,
    required this.onPriorityChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter a task title...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButton<Priority>(
                value: selectedPriority,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(
                    value: Priority.low,
                    child: Row(
                      spacing: 6,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Text('Low'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: Priority.medium,
                    child: Row(
                      spacing: 6,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Text('Medium'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: Priority.high,
                    child: Row(
                      spacing: 6,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Text('High'),
                      ],
                    ),
                  ),
                ],
                onChanged: onPriorityChanged,
              ),
            ),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[850],
                foregroundColor: Colors.indigoAccent,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Enter a description...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                maxLines: 6,
                minLines: 1,
                onSubmitted: (_) => onAdd(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
