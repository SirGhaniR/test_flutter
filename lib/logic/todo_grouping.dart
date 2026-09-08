import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../models/todo.dart';

class TodoGrouper {
  static Color getGroupColor(DateGroup group) {
    switch (group) {
      case DateGroup.today:
        return Colors.blue;
      case DateGroup.yesterday:
        return Colors.purple;
      case DateGroup.thisWeek:
        return Colors.orange;
      case DateGroup.older:
        return Colors.grey;
    }
  }

  static Map<DateGroup, List<Todo>> groupTodos(List<Todo> todos) {
    return groupBy(todos, (todo) => Todo.getDateGroup(todo.createdAt));
  }
}
