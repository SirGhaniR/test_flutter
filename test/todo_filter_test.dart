import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/logic/todo_filter.dart';
import 'package:test_flutter/models/todo.dart';

void main() {
  group('TodoFilter', () {
    final activeTodo1 = Todo(
      id: '1',
      title: 'Buy groceries',
      description: 'Milk and eggs',
      subtasks: [
        Subtask(title: 'Milk'),
        Subtask(title: 'Eggs'),
      ],
    );

    final activeTodo2 = Todo(
      id: '2',
      title: 'Walk the dog',
      description: 'In the park',
      subtasks: [],
    );

    final archivedTodo1 = Todo(
      id: '3',
      title: 'Old project',
      description: 'Completed last year',
      archivedAt: DateTime.now().subtract(const Duration(days: 10)),
      subtasks: [Subtask(title: 'Archive docs')],
    );

    final archivedTodo2 = Todo(
      id: '4',
      title: 'Another old task',
      description: 'Nothing special',
      archivedAt: DateTime.now().subtract(const Duration(days: 5)),
      subtasks: [],
    );

    final allTodos = [activeTodo1, activeTodo2, archivedTodo1, archivedTodo2];

    group('filterTodos', () {
      test('returns all active todos when query is empty', () {
        final result = TodoFilter.filterTodos(allTodos, '');
        expect(result.length, 2);
        expect(result, contains(activeTodo1));
        expect(result, contains(activeTodo2));
        expect(result, isNot(contains(archivedTodo1)));
      });

      test('filters active todos by title (case-insensitive)', () {
        final result = TodoFilter.filterTodos(allTodos, 'GROCERIES');
        expect(result.length, 1);
        expect(result[0].title, 'Buy groceries');
      });

      test('filters active todos by description', () {
        final result = TodoFilter.filterTodos(allTodos, 'park');
        expect(result.length, 1);
        expect(result[0].title, 'Walk the dog');
      });

      test('filters active todos by subtask title', () {
        final result = TodoFilter.filterTodos(allTodos, 'eggs');
        expect(result.length, 1);
        expect(result[0].title, 'Buy groceries');
      });

      test('returns empty list when no active todo matches', () {
        final result = TodoFilter.filterTodos(allTodos, 'nonexistent');
        expect(result, isEmpty);
      });
    });

    group('filterArchived', () {
      test('returns all archived todos when query is empty', () {
        final result = TodoFilter.filterArchived(allTodos, '');
        expect(result.length, 2);
        expect(result, contains(archivedTodo1));
        expect(result, contains(archivedTodo2));
        expect(result, isNot(contains(activeTodo1)));
      });

      test('filters archived todos by title', () {
        final result = TodoFilter.filterArchived(allTodos, 'Old project');
        expect(result.length, 1);
        expect(result[0].title, 'Old project');
      });

      test('filters archived todos by description', () {
        final result = TodoFilter.filterArchived(allTodos, 'nothing special');
        expect(result.length, 1);
        expect(result[0].title, 'Another old task');
      });

      test('filters archived todos by subtask title', () {
        final result = TodoFilter.filterArchived(allTodos, 'archive docs');
        expect(result.length, 1);
        expect(result[0].title, 'Old project');
      });

      test('returns empty list when no archived todo matches', () {
        final result = TodoFilter.filterArchived(allTodos, 'nonexistent');
        expect(result, isEmpty);
      });
    });
  });
}
