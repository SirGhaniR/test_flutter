import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

class TodoStorage {
  static Future<List<Todo>> loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? titles = prefs.getStringList('titles');
    List<String>? done = prefs.getStringList('done');
    List<String>? priorities = prefs.getStringList('priorities');
    List<String>? createdAt = prefs.getStringList('createdAt');
    List<String>? updatedAt = prefs.getStringList('updatedAt');

    if (titles != null && done != null) {
      return List.generate(
        titles.length,
        (index) => Todo(
          title: titles[index],
          isDone: done[index] == 'true',
          priority: priorities != null && priorities.length > index
              ? Priority.values.firstWhere(
                  (p) => p.name == priorities[index],
                  orElse: () => Priority.medium,
                )
              : Priority.medium,
          createdAt: createdAt != null && createdAt.length > index
              ? DateTime.parse(createdAt[index])
              : null,
          updatedAt: updatedAt != null && updatedAt.length > index
              ? DateTime.parse(updatedAt[index])
              : null,
        ),
      );
    }
    return [];
  }

  static Future<void> saveTodos(List<Todo> todos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> titles = todos.map((todo) => todo.title).toList();
    List<String> done = todos.map((todo) => todo.isDone.toString()).toList();
    List<String> priorities = todos.map((todo) => todo.priority.name).toList();
    List<String> createdAt = todos
        .map((todo) => todo.createdAt.toIso8601String())
        .toList();
    List<String> updatedAt = todos
        .map((todo) => todo.updatedAt.toIso8601String())
        .toList();

    await prefs.setStringList('titles', titles);
    await prefs.setStringList('done', done);
    await prefs.setStringList('priorities', priorities);
    await prefs.setStringList('createdAt', createdAt);
    await prefs.setStringList('updatedAt', updatedAt);
  }
}
