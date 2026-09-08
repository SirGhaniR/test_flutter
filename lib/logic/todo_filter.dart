import '../models/todo.dart';

class TodoFilter {
  static List<Todo> filterTodos(List<Todo> todos, String query) {
    if (query.isEmpty) {
      return List.from(todos);
    }
    return todos
        .where((todo) => todo.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
