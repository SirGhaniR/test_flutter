import 'package:flutter/material.dart';

import '../models/todo.dart';
import 'subtask_item.dart';

class TodoItem extends StatefulWidget {
  final Todo todo;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onLongPress;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onSelectionToggle;
  final String searchQuery;
  final Function(Todo) onUpdate;

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
    required this.searchQuery,
    required this.onUpdate,
  });

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  final TextEditingController _subtaskController = TextEditingController();
  final FocusNode _subtaskFocusNode = FocusNode();
  bool _addingSubtask = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = Todo.getPriorityColor(widget.todo.priority);
    final accent = Theme.of(context).colorScheme.primary;

    if (widget.isSelectionMode) {
      return GestureDetector(
        onTap: widget.onSelectionToggle,
        onLongPress: widget.onLongPress,
        behavior: HitTestBehavior.opaque,
        child: _buildCard(
          isDark: isDark,
          priorityColor: priorityColor,
          accent: accent,
          forceCollapsed: true,
        ),
      );
    }

    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: _buildCard(
        isDark: isDark,
        priorityColor: priorityColor,
        accent: accent,
        forceCollapsed: false,
      ),
    );
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    _subtaskFocusNode.dispose();
    super.dispose();
  }

  Widget _buildCard({
    required bool isDark,
    required Color priorityColor,
    required Color accent,
    required bool forceCollapsed,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: widget.isSelected ? 4 : (isDark ? 0 : 2),
      color: widget.isSelected
          ? accent.withValues(alpha: isDark ? 0.15 : 0.12)
          : (isDark ? Colors.grey[850] : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: widget.isSelected
              ? accent
              : (widget.todo.isDone
                    ? (isDark ? Colors.grey.shade700 : Colors.grey.shade300)
                    : priorityColor.withValues(alpha: 0.3)),
          width: widget.isSelected ? 2 : 1.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        spacing: 8,
        children: [
          Icon(
            widget.isSelected
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: widget.isSelected
                ? accent
                : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
            size: 24,
          ),

          Expanded(
            child: _buildHighlightedText(
              text: widget.todo.title,
              style: TextStyle(
                decoration: widget.todo.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: widget.todo.isDone
                    ? (isDark ? Colors.grey.shade600 : Colors.grey.shade500)
                    : (isDark ? Colors.white : Colors.black87),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          if (widget.todo.subtasks.isNotEmpty)
            _buildProgressBadge(isDark, accent),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.todo.isDone
                  ? (isDark
                        ? Colors.grey.shade600.withValues(alpha: 0.15)
                        : Colors.grey.shade500.withValues(alpha: 0.15))
                  : priorityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              widget.todo.priority.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: widget.todo.isDone
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
          IconButton(
            icon: Icon(
              widget.todo.isDone
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: widget.todo.isDone
                  ? Colors.green
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              size: 28,
            ),
            onPressed: widget.onToggle,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      title: _buildHighlightedText(
        text: widget.todo.title,
        style: TextStyle(
          decoration: widget.todo.isDone
              ? TextDecoration.lineThrough
              : TextDecoration.none,
          color: widget.todo.isDone
              ? (isDark ? Colors.grey.shade600 : Colors.grey.shade500)
              : (isDark ? Colors.white : Colors.black87),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          if (widget.todo.subtasks.isNotEmpty)
            _buildProgressBadge(isDark, Theme.of(context).colorScheme.primary),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.todo.isDone
                  ? (isDark
                        ? Colors.grey.shade600.withValues(alpha: 0.15)
                        : Colors.grey.shade500.withValues(alpha: 0.15))
                  : priorityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.todo.priority.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: widget.todo.isDone
                    ? (isDark ? Colors.grey.shade600 : Colors.grey.shade500)
                    : priorityColor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: widget.onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.todo.description.isNotEmpty) ...[
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
                      child: _buildHighlightedText(
                        text: widget.todo.description,
                        style: TextStyle(
                          color: widget.todo.isDone
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
              ],

              SizedBox(height: 16),

              if (widget.todo.subtasks.isNotEmpty) ...[
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
                      '${widget.todo.completedSubtasks}/${widget.todo.subtasks.length}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4),

                ...widget.todo.subtasks.map(
                  (subtask) => SubtaskItem(
                    subtask: subtask,
                    isDark: isDark,
                    onToggle: () => _toggleSubtask(subtask),
                    onEdit: () => _editSubtask(subtask),
                  ),
                ),
              ],

              if (_addingSubtask)
                _buildSubtaskInput(isDark)
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _addingSubtask = true;
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _subtaskFocusNode.requestFocus();
                      });
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add subtask'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),

              SizedBox(height: 8),

              Row(
                spacing: 4,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  ),
                  Text(
                    'Updated ${widget.todo.timeAgo}',
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
                  Text(
                    'Created ${widget.todo.createdDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: widget.onEdit,
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

  Widget _buildHighlightedText({
    required String text,
    required TextStyle style,
  }) {
    final query = widget.searchQuery.trim();
    if (query.isEmpty) return Text(text, style: style);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: style));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: style.copyWith(
            backgroundColor: Colors.orange.withValues(alpha: 0.5),
          ),
        ),
      );

      start = index + query.length;
    }

    return Text.rich(TextSpan(children: spans), maxLines: null);
  }

  Widget _buildProgressBadge(bool isDark, Color accent) {
    final done = widget.todo.completedSubtasks;
    final total = widget.todo.subtasks.length;
    final allDone = done == total;

    final color = allDone ? Colors.green : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            allDone ? Icons.checklist_rtl : Icons.checklist,
            size: 12,
            color: color,
          ),
          Text(
            '$done/$total',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtaskInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: TextField(
              controller: _subtaskController,
              focusNode: _subtaskFocusNode,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'New subtask...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
              ),
              onSubmitted: (_) => _confirmAddSubtask(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, size: 18, color: Colors.green),
            onPressed: _confirmAddSubtask,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            onPressed: () {
              setState(() {
                _subtaskController.clear();
                _addingSubtask = false;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _confirmAddSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;

    final newSubtask = Subtask(title: text);
    final updated = widget.todo.copyWith(
      subtasks: [...widget.todo.subtasks, newSubtask],
    );
    widget.onUpdate(updated);
    setState(() {
      _subtaskController.clear();
      _addingSubtask = false;
    });
  }

  void _deleteSubtask(Subtask subtask, BuildContext ctx) {
    final updatedList = widget.todo.subtasks
        .where((s) => s.id != subtask.id)
        .toList();
    widget.onUpdate(widget.todo.copyWith(subtasks: updatedList));
    Navigator.pop(ctx);
  }

  void _editSubtask(Subtask subtask) {
    final controller = TextEditingController(text: subtask.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit subtask'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Subtask title...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            _saveSubtaskEdit(subtask, controller.text, ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteSubtask(subtask, ctx),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          FilledButton(
            onPressed: () => _saveSubtaskEdit(subtask, controller.text, ctx),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveSubtaskEdit(Subtask subtask, String newTitle, BuildContext ctx) {
    final text = newTitle.trim();
    if (text.isEmpty) return;

    final index = widget.todo.subtasks.indexWhere((s) => s.id == subtask.id);
    if (index < 0) return;

    final updatedList = List<Subtask>.from(widget.todo.subtasks);
    updatedList[index] = subtask.copyWith(title: text);
    widget.onUpdate(widget.todo.copyWith(subtasks: updatedList));
    Navigator.pop(ctx);
  }

  void _toggleSubtask(Subtask subtask) {
    final index = widget.todo.subtasks.indexWhere((s) => s.id == subtask.id);
    if (index < 0) return;

    final updatedList = List<Subtask>.from(widget.todo.subtasks);
    updatedList[index] = subtask.copyWith(isDone: !subtask.isDone);
    widget.onUpdate(widget.todo.copyWith(subtasks: updatedList));
  }
}
