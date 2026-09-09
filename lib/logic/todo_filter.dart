import '../models/todo.dart';

class TodoFilter {
  static List<Todo> filterTodos(List<Todo> todos, String query) {
    if (query.isEmpty) {
      return List.from(todos);
    }

    final lowerQuery = query.toLowerCase();

    return todos.where((todo) {
      final titleMatch = todo.title.toLowerCase().contains(lowerQuery);
      final descriptionMatch = todo.description.toLowerCase().contains(
        lowerQuery,
      );
      return titleMatch || descriptionMatch;
    }).toList();
  }
}
