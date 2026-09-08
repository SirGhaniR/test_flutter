import 'package:flutter/material.dart';

enum DateGroup { today, yesterday, thisWeek, older }

enum Priority { low, medium, high }

class Todo {
  final String title;
  final String description;
  bool isDone;
  Priority priority;
  final DateTime createdAt;
  DateTime updatedAt;

  Todo({
    required this.title,
    required this.description,
    this.isDone = false,
    this.priority = Priority.medium,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get createdDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Todo copyWith({
    String? title,
    String? description,
    bool? isDone,
    Priority? priority,
    DateTime? updatedAt,
  }) {
    return Todo(
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  static DateGroup getDateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly.isAtSameMomentAs(today)) {
      return DateGroup.today;
    } else if (dateOnly.isAtSameMomentAs(yesterday)) {
      return DateGroup.yesterday;
    } else if (dateOnly.isAfter(weekAgo)) {
      return DateGroup.thisWeek;
    } else {
      return DateGroup.older;
    }
  }

  static String getDateGroupLabel(DateGroup group) {
    switch (group) {
      case DateGroup.today:
        return 'Today';
      case DateGroup.yesterday:
        return 'Yesterday';
      case DateGroup.thisWeek:
        return 'This Week';
      case DateGroup.older:
        return 'Older';
    }
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
