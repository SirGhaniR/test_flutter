import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/logic/todo_exporter.dart';
import 'package:test_flutter/logic/todo_importer.dart';
import 'package:test_flutter/models/todo.dart';

void main() {
  group('TodoImporter JSON', () {
    test('parses a JSON array', () {
      const input = '''
[
  {
    "title": "Buy groceries",
    "description": "Milk, eggs",
    "isDone": false,
    "priority": "high"
  },
  {
    "title": "Call mom",
    "description": "",
    "isDone": true,
    "priority": "low"
  }
]
''';

      final result = TodoImporter.parse(input);

      expect(result.isSuccess, isTrue);
      expect(result.format, 'JSON');
      expect(result.todos.length, 2);
      expect(result.todos[0].title, 'Buy groceries');
      expect(result.todos[0].priority, Priority.high);
      expect(result.todos[1].isDone, isTrue);
      expect(result.todos[1].priority, Priority.low);
    });

    test('parses a single JSON object', () {
      const input = '''
{
  "title": "Buy groceries",
  "description": "Milk, eggs",
  "priority": "medium"
}
''';

      final result = TodoImporter.parse(input);

      expect(result.isSuccess, isTrue);
      expect(result.todos.length, 1);
      expect(result.todos[0].title, 'Buy groceries');
    });

    test('parses subtasks from JSON', () {
      const input = '''
[
  {
    "title": "Buy groceries",
    "description": "",
    "priority": "high",
    "subtasks": [
      { "title": "Milk", "isDone": false },
      { "title": "Eggs", "isDone": true }
    ]
  }
]
''';

      final result = TodoImporter.parse(input);

      expect(result.isSuccess, isTrue);
      expect(result.todos[0].subtasks.length, 2);
      expect(result.todos[0].subtasks[0].title, 'Milk');
      expect(result.todos[0].subtasks[0].isDone, isFalse);
      expect(result.todos[0].subtasks[1].isDone, isTrue);
    });

    test('skips items without a title', () {
      const input = '''
[
  { "title": "", "description": "no title" },
  { "title": "Valid task", "description": "" }
]
''';

      final result = TodoImporter.parse(input);

      expect(result.isSuccess, isTrue);
      expect(result.todos.length, 1);
      expect(result.todos[0].title, 'Valid task');
    });

    test('returns error for empty input', () {
      final result = TodoImporter.parse('   ');

      expect(result.isSuccess, isFalse);
      expect(result.error, isNotNull);
    });

    test('returns error for garbage input', () {
      final result = TodoImporter.parse('@@@ not valid @@@');

      expect(result.isSuccess, isFalse);
    });

    test('returns error for malformed JSON', () {
      final result = TodoImporter.parse('[ { "title": "Broken" }');

      expect(result.isSuccess, isFalse);
      expect(result.error, contains('Failed to parse JSON'));
    });

    test('returns error when JSON contains no valid tasks', () {
      final result = TodoImporter.parse('[ { "description": "no title" } ]');

      expect(result.isSuccess, isFalse);
      expect(result.error, contains('No valid tasks'));
    });
  });

  group('TodoImporter Markdown', () {
    test('parses a basic task list', () {
      const input = '''
- [ ] **Buy groceries** 🔴
- [x] **Call mom** 🟢
''';

      final result = TodoImporter.parse(input);

      expect(result.isSuccess, isTrue);
      expect(result.format, 'Markdown');
      expect(result.todos.length, 2);
      expect(result.todos[0].title, 'Buy groceries');
      expect(result.todos[0].priority, Priority.high);
      expect(result.todos[0].isDone, isFalse);
      expect(result.todos[1].title, 'Call mom');
      expect(result.todos[1].priority, Priority.low);
      expect(result.todos[1].isDone, isTrue);
    });

    test('parses description blockquotes', () {
      const input = '''
- [ ] **Buy groceries** 🟠
  > Milk, eggs, bread
''';

      final result = TodoImporter.parse(input);

      expect(result.isSuccess, isTrue);
      expect(result.todos[0].description, 'Milk, eggs, bread');
      expect(result.todos[0].priority, Priority.medium);
    });

    test('parses subtasks', () {
      const input = '''
- [ ] **Buy groceries** 🔴
  - [ ] Milk
  - [x] Eggs
''';

      final result = TodoImporter.parse(input);

      expect(result.isSuccess, isTrue);
      expect(result.todos[0].subtasks.length, 2);
      expect(result.todos[0].subtasks[0].title, 'Milk');
      expect(result.todos[0].subtasks[0].isDone, isFalse);
      expect(result.todos[0].subtasks[1].title, 'Eggs');
      expect(result.todos[0].subtasks[1].isDone, isTrue);
    });

    test('handles missing bold markers', () {
      const input = '''
- [ ] Buy groceries 🟢
''';

      final result = TodoImporter.parse(input);

      expect(result.isSuccess, isTrue);
      expect(result.todos[0].title, 'Buy groceries');
      expect(result.todos[0].priority, Priority.low);
    });

    test('returns error when no tasks found', () {
      final result = TodoImporter.parse('just some random text');

      expect(result.isSuccess, isFalse);
      expect(result.error, contains('No valid tasks'));
    });
  });

  group('Round-trip', () {
    test('export JSON then import preserves data', () {
      final original = [
        Todo(
          title: 'Buy groceries',
          description: 'Milk, eggs',
          priority: Priority.high,
          subtasks: [
            Subtask(title: 'Milk'),
            Subtask(title: 'Eggs', isDone: true),
          ],
        ),
        Todo(
          title: 'Call mom',
          description: '',
          priority: Priority.low,
          isDone: true,
        ),
      ];

      final json = TodoExporter.toJson(original);
      final result = TodoImporter.parse(json);

      expect(result.isSuccess, isTrue);
      expect(result.todos.length, 2);

      expect(result.todos[0].title, 'Buy groceries');
      expect(result.todos[0].description, 'Milk, eggs');
      expect(result.todos[0].priority, Priority.high);
      expect(result.todos[0].subtasks.length, 2);
      expect(result.todos[0].subtasks[1].isDone, isTrue);

      expect(result.todos[1].title, 'Call mom');
      expect(result.todos[1].isDone, isTrue);
      expect(result.todos[1].priority, Priority.low);
    });

    test('export Markdown then import preserves core data', () {
      final original = [
        Todo(
          title: 'Buy groceries',
          description: 'Milk, eggs',
          priority: Priority.high,
          subtasks: [Subtask(title: 'Milk')],
        ),
      ];

      final md = TodoExporter.toMarkdown(original);
      final result = TodoImporter.parse(md);

      expect(result.isSuccess, isTrue);
      expect(result.todos.length, 1);
      expect(result.todos[0].title, 'Buy groceries');
      expect(result.todos[0].description, 'Milk, eggs');
      expect(result.todos[0].priority, Priority.high);
      expect(result.todos[0].subtasks.length, 1);
      expect(result.todos[0].subtasks[0].title, 'Milk');
    });
  });
}
