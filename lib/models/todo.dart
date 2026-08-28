import 'package:flutter/material.dart';

enum Priority { low, medium, high }

class Todo {
  final String title;
  bool isDone;
  Priority priority;

  Todo({
    required this.title,
    this.isDone = false,
    this.priority = Priority.medium,
  });

  Todo copyWith({String? title, bool? isDone, Priority? priority}) {
    return Todo(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
    );
  }

  static Color getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
    }
  }
}
