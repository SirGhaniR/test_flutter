import 'dart:convert';

import '../models/todo.dart';

class TodoExporter {
  static String toJson(List<Todo> todos) {
    final List<Map<String, dynamic>> jsonList = todos
        .map((todo) => todo.toJson())
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
          buffer.writeln('  > $line  ');
        }
      }

      for (final subtask in todo.subtasks) {
        final subCheckbox = subtask.isDone ? '[x]' : '[ ]';
        buffer.writeln('  - $subCheckbox ${subtask.title}');
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
}
