import '../models/todo.dart';

class TodoFilter {
  static List<Todo> filterArchived(List<Todo> todos, String query) {
    final archived = todos.where((t) => t.isArchived);

    if (query.isEmpty) {
      return List.from(archived);
    }

    final lowerQuery = query.toLowerCase();

    return archived.where((todo) {
      final titleMatch = todo.title.toLowerCase().contains(lowerQuery);
      final descriptionMatch = todo.description.toLowerCase().contains(
        lowerQuery,
      );
      return titleMatch || descriptionMatch;
    }).toList();
  }

  static List<Todo> filterTodos(List<Todo> todos, String query) {
    final active = todos.where((t) => !t.isArchived);

    if (query.isEmpty) {
      return List.from(active);
    }

    final lowerQuery = query.toLowerCase();

    return active.where((todo) {
      final titleMatch = todo.title.toLowerCase().contains(lowerQuery);
      final descriptionMatch = todo.description.toLowerCase().contains(
        lowerQuery,
      );
      final subtaskMatch = todo.subtasks.any(
        (s) => s.title.toLowerCase().contains(lowerQuery),
      );
      return titleMatch || descriptionMatch || subtaskMatch;
    }).toList();
  }
}
