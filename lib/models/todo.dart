import 'package:flutter/material.dart';

enum DateGroup { today, yesterday, thisWeek, older }

enum Priority { low, medium, high }

class Subtask {
  final String id;
  final String title;
  bool isDone;

  Subtask({String? id, required this.title, this.isDone = false})
    : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      isDone: json['isDone'] == true,
    );
  }

  Subtask copyWith({String? id, String? title, bool? isDone}) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'isDone': isDone};
  }
}

class Todo {
  final String id;
  final String title;
  final String description;
  bool isDone;
  Priority priority;
  final DateTime createdAt;
  DateTime updatedAt;
  List<Subtask> subtasks;
  DateTime? archivedAt;

  Todo({
    String? id,
    required this.title,
    required this.description,
    this.isDone = false,
    this.priority = Priority.medium,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Subtask>? subtasks,
    this.archivedAt,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       subtasks = subtasks ?? [];

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isDone: json['isDone'] == true,
      priority: Priority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => Priority.medium,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      subtasks:
          (json['subtasks'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((s) => Subtask.fromJson(s))
              .toList() ??
          [],
      archivedAt: json['archivedAt'] != null
          ? DateTime.tryParse(json['archivedAt'])
          : null,
    );
  }

  String get archivedDate {
    if (archivedAt == null) return '';
    return '${archivedAt!.day}/${archivedAt!.month}/${archivedAt!.year}';
  }

  int get completedSubtasks => subtasks.where((s) => s.isDone).length;

  String get createdDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  bool get isArchived => archivedAt != null;

  double get progress {
    if (subtasks.isEmpty) return 0;
    return completedSubtasks / subtasks.length;
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
    String? id,
    String? title,
    String? description,
    bool? isDone,
    Priority? priority,
    DateTime? updatedAt,
    List<Subtask>? subtasks,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      subtasks: subtasks ?? this.subtasks,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
      'archivedAt': archivedAt?.toIso8601String(),
    };
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
