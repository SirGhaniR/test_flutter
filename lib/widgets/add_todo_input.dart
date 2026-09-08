import 'package:flutter/material.dart';

import '../models/todo.dart';

class AddTodoInput extends StatelessWidget {
  final TextEditingController controller;
  final Priority selectedPriority;
  final ValueChanged<Priority?> onPriorityChanged;
  final VoidCallback onAdd;

  const AddTodoInput({
    super.key,
    required this.controller,
    required this.selectedPriority,
    required this.onPriorityChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter a task...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => onAdd(),
            ),
          ),
          const SizedBox(width: 8),
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
              onChanged: onPriorityChanged,
            ),
          ),
          const SizedBox(width: 8),
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
    );
  }
}
