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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        spacing: 8,
        children: [
          IntrinsicHeight(
            child: Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
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
                ElevatedButton.icon(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[850],
                    foregroundColor: Colors.indigoAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  label: const Text('Add'),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
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
      ),
    );
  }
}
