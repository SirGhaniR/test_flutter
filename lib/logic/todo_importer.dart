import 'dart:convert';

import '../models/todo.dart';

class ImportResult {
  final List<Todo> todos;
  final String format;
  final String? error;

  ImportResult({this.todos = const [], this.format = '', this.error});

  bool get isSuccess => error == null && todos.isNotEmpty;
}

class TodoImporter {
  static ImportResult parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return ImportResult(error: "Nothing to import! Input is empty");
    }

    if (trimmed.startsWith("[") || trimmed.startsWith("{")) {
      return _parseJson(trimmed);
    }

    return _parseMarkdown(trimmed);
  }

  static ImportResult _parseJson(String input) {
    try {
      final decoded = jsonDecode(input);

      final List<dynamic> jsonList;
      if (decoded is List) {
        jsonList = decoded;
      } else if (decoded is Map<String, dynamic>) {
        jsonList = [decoded];
      } else {
        return ImportResult(error: "Invalid JSON structure");
      }

      final todos = <Todo>[];

      for (final item in jsonList) {
        if (item is! Map<String, dynamic>) continue;

        final title = (item['title'] as String?)?.trim() ?? "";
        if (title.isEmpty) continue;

        todos.add(Todo.fromJson(item));
      }

      if (todos.isEmpty) {
        return ImportResult(error: "No valid tasks found in JSON pasted");
      }

      return ImportResult(todos: todos, format: "JSON");
    } catch (e) {
      return ImportResult(error: "Failed to parse JSON: $e");
    }
  }

  static ImportResult _parseMarkdown(String input) {
    try {
      final lines = input.split("\n");
      final todos = <Todo>[];

      String? currentTitle;
      Priority currentPriority = Priority.medium;
      bool currentDone = false;
      final descriptionLines = <String>[];
      final subtasks = <Subtask>[];

      void flush() {
        if (currentTitle != null && currentTitle!.isNotEmpty) {
          todos.add(
            Todo(
              title: currentTitle!,
              description: descriptionLines.join("\n").trim(),
              isDone: currentDone,
              priority: currentPriority,
              subtasks: List<Subtask>.from(subtasks),
            ),
          );
        }

        currentTitle = null;
        currentPriority = Priority.medium;
        currentDone = false;
        descriptionLines.clear();
        subtasks.clear();
      }

      final taskRegex = RegExp(r'^-\s*\[( |x|X)\]\s*(.+)$');
      final subtaskRegex = RegExp(r'^\s+-\s*\[( |x|X)\]\s*(.+)$');

      for (final rawLine in lines) {
        final line = rawLine.trimRight();

        final subtaskMatch = subtaskRegex.firstMatch(line);
        if (subtaskMatch != null && currentTitle != null) {
          final isDone = subtaskMatch.group(1)!.toLowerCase() == 'x';
          final subTitle = subtaskMatch.group(2)!.trim();
          if (subTitle.isNotEmpty) {
            subtasks.add(Subtask(title: subTitle, isDone: isDone));
          }
          continue;
        }

        final taskMatch = taskRegex.firstMatch(line.trim());

        if (taskMatch != null) {
          flush();

          currentDone = taskMatch.group(1)!.toLowerCase() == 'x';
          var titlePart = taskMatch.group(2)!.trim();

          if (titlePart.contains("🔴")) {
            currentPriority = Priority.high;
          } else if (titlePart.contains("🟠")) {
            currentPriority = Priority.medium;
          } else if (titlePart.contains("🟢")) {
            currentPriority = Priority.low;
          }

          titlePart = titlePart
              .replaceAll("🔴", "")
              .replaceAll("🟠", "")
              .replaceAll("🟢", "")
              .trim();

          if (titlePart.startsWith("**") && titlePart.endsWith("**")) {
            titlePart = titlePart.substring(2, titlePart.length - 2).trim();
          }

          currentTitle = titlePart;
        } else if (line.trim().startsWith(">") && currentTitle != null) {
          final descLine = line.trim().substring(1).trim();
          descriptionLines.add(descLine);
        }
      }
      flush();

      if (todos.isEmpty) {
        return ImportResult(
          error:
              "No valid tasks found. Make sure lines look like:\n"
              "- [ ] **Task Title** 🔴\n"
              "  > description\n"
              "  - [ ] subtask",
        );
      }

      return ImportResult(todos: todos, format: "Markdown");
    } catch (e) {
      return ImportResult(error: "Failed to parse Markdown");
    }
  }
}
