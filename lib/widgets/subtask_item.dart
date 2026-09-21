import 'package:flutter/material.dart';

import '../models/todo.dart';

class SubtaskItem extends StatelessWidget {
  final Subtask subtask;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const SubtaskItem({
    super.key,
    required this.subtask,
    required this.isDark,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        spacing: 8,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(4),
            child: Icon(
              subtask.isDone
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              size: 18,
              color: subtask.isDone
                  ? Colors.green
                  : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  subtask.title,
                  style: TextStyle(
                    fontSize: 13,
                    decoration: subtask.isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: subtask.isDone
                        ? (isDark ? Colors.grey.shade600 : Colors.grey.shade500)
                        : (isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade800),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
