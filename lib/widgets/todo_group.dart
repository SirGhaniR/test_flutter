import 'package:flutter/material.dart';

import '../logic/todo_grouping.dart';
import '../models/todo.dart';
import 'todo_item.dart';

class TodoGroup extends StatelessWidget {
  final DateGroup group;
  final List<Todo> tasks;
  final bool isDark;
  final Function(Todo) onToggle;
  final Function(Todo) onDelete;
  final Function(Todo) onEdit;
  final Function(Todo) onLongPress;
  final Set<Todo> selectedTodos;
  final bool isSelectionMode;
  final Function(Todo) onSelectionToggle;

  const TodoGroup({
    super.key,
    required this.group,
    required this.tasks,
    required this.isDark,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onLongPress,
    required this.selectedTodos,
    required this.isSelectionMode,
    required this.onSelectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
      elevation: isDark ? 0 : 1,
      color: isDark ? Colors.grey[850] : Colors.white,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 4,
            height: 30,
            decoration: BoxDecoration(
              color: TodoGrouper.getGroupColor(group),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          title: Text(
            Todo.getDateGroupLabel(group),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            '${tasks.length} task${tasks.length > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          trailing: Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${tasks.where((t) => t.isDone).length}/${tasks.length} done',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ],
          ),
          initiallyExpanded: group == DateGroup.today,
          children: tasks.map((todo) {
            return TodoItem(
              todo: todo,
              index: 0,
              onToggle: () => onToggle(todo),
              onDelete: () => onDelete(todo),
              onEdit: () => onEdit(todo),
              onLongPress: () => onLongPress(todo),
              isSelectionMode: isSelectionMode,
              isSelected: selectedTodos.contains(todo),
              onSelectionToggle: () => onSelectionToggle(todo),
            );
          }).toList(),
        ),
      ),
    );
  }
}
