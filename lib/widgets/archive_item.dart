import 'package:flutter/material.dart';

import '../models/todo.dart';

class ArchiveItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const ArchiveItem({
    super.key,
    required this.todo,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = Todo.getPriorityColor(todo.priority);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      elevation: isDark ? 0 : 1,
      color: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            spacing: 6,
            children: [
              Icon(Icons.check_circle, size: 14, color: Colors.green.shade400),
              Expanded(
                child: Text(
                  todo.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              spacing: 8,
              children: [
                Text(
                  'Archived ${todo.archivedDate}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    todo.priority.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
                if (todo.subtasks.isNotEmpty)
                  Text(
                    '${todo.completedSubtasks}/${todo.subtasks.length}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
          trailing: Row(
            spacing: 4,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.unarchive_outlined, size: 20),
                color: Theme.of(context).colorScheme.primary,
                onPressed: onRestore,
                tooltip: 'Restore',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.red,
                ),
                onPressed: onDelete,
                tooltip: 'Delete forever',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
              child: Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (todo.description.isNotEmpty)
                    Row(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 16,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        Expanded(
                          child: Text(
                            todo.description,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 2),

                  if (todo.subtasks.isNotEmpty) ...[
                    Row(
                      spacing: 8,
                      children: [
                        Icon(
                          Icons.checklist,
                          size: 16,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        Text(
                          'Subtasks',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${todo.completedSubtasks}/${todo.subtasks.length}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),

                    ...todo.subtasks.map(
                      (subtask) => Padding(
                        padding: EdgeInsetsGeometry.only(left: 16),
                        child: Row(
                          spacing: 8,
                          children: [
                            Icon(
                              subtask.isDone
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 18,
                              color: subtask.isDone
                                  ? Colors.green
                                  : (isDark
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade400),
                            ),
                            Expanded(
                              child: Text(
                                subtask.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  decoration: subtask.isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: subtask.isDone
                                      ? (isDark
                                            ? Colors.grey.shade600
                                            : Colors.grey.shade500)
                                      : (isDark
                                            ? Colors.grey.shade300
                                            : Colors.grey.shade800),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
