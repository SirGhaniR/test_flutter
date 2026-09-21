import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

class TodoStorage {
  static const String _todosKey = 'todos_data';

  static Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString(_todosKey);

    if (todosJson != null) {
      try {
        final List<dynamic> list = jsonDecode(todosJson);
        return list
            .whereType<Map<String, dynamic>>()
            .map((j) => Todo.fromJson(j))
            .toList();
      } catch (_) {}
    }

    final legacy = _loadLegacy(prefs);
    if (legacy.isNotEmpty) {
      await saveTodos(legacy);
      await _clearLegacy(prefs);
    }
    return legacy;
  }

  static Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(todos.map((t) => t.toJson()).toList());
    await prefs.setString(_todosKey, jsonString);
  }

  static Future<void> _clearLegacy(SharedPreferences prefs) async {
    await prefs.remove('titles');
    await prefs.remove('descriptions');
    await prefs.remove('done');
    await prefs.remove('priorities');
    await prefs.remove('createdAt');
    await prefs.remove('updatedAt');
  }

  static List<Todo> _loadLegacy(SharedPreferences prefs) {
    final titles = prefs.getStringList('titles');
    final descriptions = prefs.getStringList('descriptions');
    final done = prefs.getStringList('done');
    final priorities = prefs.getStringList('priorities');
    final createdAt = prefs.getStringList('createdAt');
    final updatedAt = prefs.getStringList('updatedAt');

    if (titles == null || descriptions == null || done == null) return [];

    return List.generate(titles.length, (index) {
      return Todo(
        title: titles[index],
        description: descriptions[index],
        isDone: done[index] == 'true',
        priority: priorities != null && priorities.length > index
            ? Priority.values.firstWhere(
                (p) => p.name == priorities[index],
                orElse: () => Priority.medium,
              )
            : Priority.medium,
        createdAt: createdAt != null && createdAt.length > index
            ? DateTime.tryParse(createdAt[index])
            : null,
        updatedAt: updatedAt != null && updatedAt.length > index
            ? DateTime.tryParse(updatedAt[index])
            : null,
      );
    });
  }
}
