import 'package:flutter/material.dart';

import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onLongPress;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onSelectionToggle;

  const TodoItem({
    super.key,
    required this.todo,
    required this.index,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onLongPress,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onSelectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = Todo.getPriorityColor(todo.priority);
    final accent = Theme.of(context).colorScheme.primary;

    if (isSelectionMode) {
      return GestureDetector(
        onTap: onSelectionToggle,
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: _buildCard(
          context: context,
          isDark: isDark,
          priorityColor: priorityColor,
          accent: accent,
          forceCollapsed: true,
        ),
      );
    }

    return GestureDetector(
      onLongPress: onLongPress,
      child: _buildCard(
        context: context,
        isDark: isDark,
        priorityColor: priorityColor,
        accent: accent,
        forceCollapsed: false,
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required bool isDark,
    required Color priorityColor,
    required Color accent,
    required bool forceCollapsed,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: isSelected ? 4 : (isDark ? 0 : 2),
      color: isSelected
          ? accent.withValues(alpha: isDark ? 0.25 : 0.12)
          : (isDark ? Colors.grey[850] : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: isSelected
              ? accent
              : (todo.isDone
                    ? (isDark ? Colors.grey.shade700 : Colors.grey.shade300)
                    : priorityColor.withValues(alpha: 0.3)),
          width: isSelected ? 2 : 1.5,
        ),
      ),
      child: forceCollapsed
          ? _buildCollapsedTile(
              isDark: isDark,
              priorityColor: priorityColor,
              accent: accent,
            )
          : _buildExpansionTile(isDark: isDark, priorityColor: priorityColor),
    );
  }

  Widget _buildCollapsedTile({
    required bool isDark,
    required Color priorityColor,
    required Color accent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isSelected
                ? accent
                : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
            size: 24,
          ),
          const SizedBox(width: 12),

          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: todo.isDone ? Colors.grey : priorityColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: todo.isDone
                    ? (isDark ? Colors.grey.shade600 : Colors.grey.shade500)
                    : (isDark ? Colors.white : Colors.black87),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: todo.isDone
                  ? (isDark
                        ? Colors.grey.shade600.withValues(alpha: 0.15)
                        : Colors.grey.shade500.withValues(alpha: 0.15))
                  : priorityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              todo.priority.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: todo.isDone
                    ? (isDark ? Colors.grey.shade600 : Colors.grey.shade500)
                    : priorityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile({
    required bool isDark,
    required Color priorityColor,
  }) {
    return ExpansionTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: todo.isDone ? Colors.grey : priorityColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(
              todo.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: todo.isDone
                  ? Colors.green
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              size: 28,
            ),
            onPressed: onToggle,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.isDone
              ? TextDecoration.lineThrough
              : TextDecoration.none,
          color: todo.isDone
              ? (isDark ? Colors.grey.shade600 : Colors.grey.shade500)
              : (isDark ? Colors.white : Colors.black87),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: todo.isDone
                  ? (isDark
                        ? Colors.grey.shade600.withValues(alpha: 0.15)
                        : Colors.grey.shade500.withValues(alpha: 0.15))
                  : priorityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              todo.priority.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: todo.isDone
                    ? (isDark ? Colors.grey.shade600 : Colors.grey.shade500)
                    : priorityColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.description.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        todo.description,
                        style: TextStyle(
                          color: todo.isDone
                              ? (isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade400)
                              : (isDark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Updated ${todo.timeAgo}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Created ${todo.createdDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
