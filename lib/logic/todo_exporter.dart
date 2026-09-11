import 'dart:convert';

import '../models/todo.dart';

class TodoExporter {
  static String toJson(List<Todo> todos) {
    final List<Map<String, dynamic>> jsonList = todos
        .map((todo) => _todoToMap(todo))
        .toList();

    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonList);
  }

  static String toMarkdown(List<Todo> todos) {
    final buffer = StringBuffer();

    for (final todo in todos) {
      final checkbox = todo.isDone ? '[x]' : '[ ]';
      final priorityEmoji = _priorityEmoji(todo.priority);

      buffer.writeln('- $checkbox **${todo.title}** $priorityEmoji');

      if (todo.description.isNotEmpty) {
        final lines = todo.description.split('\n');
        for (final line in lines) {
          buffer.writeln('  > $line');
        }
      }
    }

    return buffer.toString().trimRight();
  }

  static String _priorityEmoji(Priority priority) {
    switch (priority) {
      case Priority.low:
        return '🟢';
      case Priority.medium:
        return '🟠';
      case Priority.high:
        return '🔴';
    }
  }

  static Map<String, dynamic> _todoToMap(Todo todo) {
    return {
      'title': todo.title,
      'description': todo.description,
      'isDone': todo.isDone,
      'priority': todo.priority.name,
      'createdAt': todo.createdAt.toIso8601String(),
      'updatedAt': todo.updatedAt.toIso8601String(),
    };
  }
}
