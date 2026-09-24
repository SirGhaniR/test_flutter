import 'package:flutter/material.dart';

import '../models/todo.dart';

class PrioritySelector extends StatelessWidget {
  final Priority selected;
  final ValueChanged<Priority> onChanged;

  const PrioritySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      spacing: 8,
      children: [
        _buildButton(context, Priority.low, isDark),
        _buildButton(context, Priority.medium, isDark),
        _buildButton(context, Priority.high, isDark),
      ],
    );
  }

  Widget _buildButton(BuildContext context, Priority priority, bool isDark) {
    final isSelected = selected == priority;
    final color = Todo.getPriorityColor(priority);

    String label;
    switch (priority) {
      case Priority.low:
        label = 'Low';
        break;
      case Priority.medium:
        label = 'Medium';
        break;
      case Priority.high:
        label = 'High';
        break;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(priority),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 6,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? color
                      : (isDark ? Colors.grey.shade400 : Colors.grey),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
