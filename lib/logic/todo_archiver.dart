import '../models/todo.dart';

class TodoArchiver {
  static const Duration archiveAfter = Duration(days: 7);

  static List<Todo> activeOnly(List<Todo> todos) {
    return todos.where((t) => !t.isArchived).toList();
  }

  static List<Todo> archivedOnly(List<Todo> todos) {
    return todos.where((t) => t.isArchived).toList();
  }

  static List<Todo> autoArchive(List<Todo> todos) {
    final now = DateTime.now();
    final updated = <Todo>[];

    for (final todo in todos) {
      if (shouldAutoArchive(todo)) {
        updated.add(todo.copyWith(archivedAt: now));
      } else {
        updated.add(todo);
      }
    }

    return updated;
  }

  static bool shouldAutoArchive(Todo todo) {
    if (todo.isArchived) return false;
    if (!todo.isDone) return false;

    final now = DateTime.now();
    return now.difference(todo.updatedAt) >= archiveAfter;
  }
}
