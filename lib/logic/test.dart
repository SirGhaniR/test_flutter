import 'dart:convert';

import '../models/todo.dart';

class ImportResult {
  final List<Todo> todos;
  final String format; // 'JSON' or 'Markdown'
  final String? error;

  ImportResult({this.todos = const [], this.format = '', this.error});

  bool get isSuccess => error == null && todos.isNotEmpty;
}

class TodoImporter {
  /// Auto-detect format and parse.
  static ImportResult parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return ImportResult(error: 'Nothing to import — input is empty.');
    }

    // JSON detection: starts with '[' (array) or '{' (single object)
    if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
      return _parseJson(trimmed);
    }

    // Otherwise treat as Markdown
    return _parseMarkdown(trimmed);
  }

  // ---------- JSON ----------
  static ImportResult _parseJson(String input) {
    try {
      final decoded = jsonDecode(input);

      final List<dynamic> jsonList;
      if (decoded is List) {
        jsonList = decoded;
      } else if (decoded is Map<String, dynamic>) {
        // Single object — wrap in list
        jsonList = [decoded];
      } else {
        return ImportResult(error: 'Invalid JSON structure.');
      }

      final todos = <Todo>[];
      for (final item in jsonList) {
        if (item is! Map<String, dynamic>) continue;

        final title = (item['title'] as String?)?.trim() ?? '';
        if (title.isEmpty) continue; // skip tasks without a title

        final description = (item['description'] as String?) ?? '';
        final isDone = item['isDone'] == true;
        final priorityName = item['priority'] as String? ?? 'medium';

        final priority = Priority.values.firstWhere(
          (p) => p.name == priorityName,
          orElse: () => Priority.medium,
        );

        DateTime? createdAt;
        DateTime? updatedAt;
        try {
          if (item['createdAt'] != null) {
            createdAt = DateTime.parse(item['createdAt']);
          }
          if (item['updatedAt'] != null) {
            updatedAt = DateTime.parse(item['updatedAt']);
          }
        } catch (_) {
          // If date parsing fails, use defaults
        }

        todos.add(
          Todo(
            title: title,
            description: description,
            isDone: isDone,
            priority: priority,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
        );
      }

      if (todos.isEmpty) {
        return ImportResult(error: 'No valid tasks found in JSON.');
      }

      return ImportResult(todos: todos, format: 'JSON');
    } catch (e) {
      return ImportResult(error: 'Failed to parse JSON: $e');
    }
  }

  // ---------- Markdown ----------
  static ImportResult _parseMarkdown(String input) {
    try {
      final lines = input.split('\n');
      final todos = <Todo>[];

      String? currentTitle;
      Priority currentPriority = Priority.medium;
      bool currentDone = false;
      final descriptionLines = <String>[];

      void flush() {
        if (currentTitle != null && currentTitle!.isNotEmpty) {
          todos.add(
            Todo(
              title: currentTitle!,
              description: descriptionLines.join('\n').trim(),
              isDone: currentDone,
              priority: currentPriority,
            ),
          );
        }
        currentTitle = null;
        currentPriority = Priority.medium;
        currentDone = false;
        descriptionLines.clear();
      }

      // Regex for task line:
      // - [ ] **Title** 🔴
      // - [x] **Title** 🟢
      // Also supports without bold: - [ ] Title 🔴
      final taskRegex = RegExp(r'^-\s*\[( |x|X)\]\s*(.+)$');

      for (final rawLine in lines) {
        final line = rawLine.trimRight();
        final taskMatch = taskRegex.firstMatch(line.trim());

        if (taskMatch != null) {
          // New task — flush previous
          flush();

          currentDone = taskMatch.group(1)!.toLowerCase() == 'x';
          var titlePart = taskMatch.group(2)!.trim();

          // Extract priority emoji if present
          if (titlePart.contains('🔴')) {
            currentPriority = Priority.high;
          } else if (titlePart.contains('🟠')) {
            currentPriority = Priority.medium;
          } else if (titlePart.contains('🟢')) {
            currentPriority = Priority.low;
          }

          // Remove emojis
          titlePart = titlePart
              .replaceAll('🔴', '')
              .replaceAll('🟠', '')
              .replaceAll('🟢', '')
              .trim();

          // Remove bold markers **...**
          if (titlePart.startsWith('**') && titlePart.endsWith('**')) {
            titlePart = titlePart.substring(2, titlePart.length - 2).trim();
          }

          currentTitle = titlePart;
        } else if (line.trim().startsWith('>') && currentTitle != null) {
          // Description line (blockquote)
          final descLine = line.trim().substring(1).trim();
          descriptionLines.add(descLine);
        }
      }

      // Flush last task
      flush();

      if (todos.isEmpty) {
        return ImportResult(
          error:
              'No valid tasks found. Make sure lines look like:\n'
              '- [ ] **Task title** 🔴\n'
              '  > description',
        );
      }

      return ImportResult(todos: todos, format: 'Markdown');
    } catch (e) {
      return ImportResult(error: 'Failed to parse Markdown: $e');
    }
  }
}
