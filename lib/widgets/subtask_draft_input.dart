import 'package:flutter/material.dart';

import '../models/todo.dart';

class SubtaskDraftInput extends StatefulWidget {
  final List<Subtask> subtasks;
  final ValueChanged<List<Subtask>> onChanged;
  final bool isDark;

  const SubtaskDraftInput({
    super.key,
    required this.subtasks,
    required this.onChanged,
    required this.isDark,
  });

  @override
  State<SubtaskDraftInput> createState() => _SubtaskDraftInputState();
}

class _SubtaskDraftInputState extends State<SubtaskDraftInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final accent = Theme.of(context).colorScheme.primary;

    return Column(
      spacing: 6,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(
              Icons.checklist,
              size: 16,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            Text(
              'Subtasks',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            if (widget.subtasks.isNotEmpty)
              Text(
                '${widget.subtasks.length}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                ),
              ),
          ],
        ),

        ...widget.subtasks.map(
          (subtask) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.radio_button_unchecked,
                  size: 18,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
                Expanded(
                  child: Text(
                    subtask.title,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.grey.shade200
                          : Colors.grey.shade800,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 16,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  onPressed: () {
                    final updated = widget.subtasks
                        .where((s) => s.id != subtask.id)
                        .toList();
                    widget.onChanged(updated);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            spacing: 8,
            children: [
              Icon(
                Icons.radio_button_unchecked,
                size: 18,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Add subtask...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade500,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _commit(),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, size: 18, color: accent),
                onPressed: _commit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _commit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onChanged([...widget.subtasks, Subtask(title: text)]);
    _controller.clear();
    _focusNode.requestFocus();
  }
}
