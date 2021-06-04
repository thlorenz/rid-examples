import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plugin/plugin.dart';
import 'package:todo/views/todo.dart';

class TodosView extends StatelessWidget {
  final List<Todo> todos;
  final Todo? Function(int) getTodoById;
  final Future<void> Function(int) onToggleTodo;
  final Future<void> Function(int) onRemoveTodo;

  final bool Function() getAutoExpireCompleted;

  const TodosView(
    this.todos, {
    required this.getTodoById,
    required this.onToggleTodo,
    required this.onRemoveTodo,
    required this.getAutoExpireCompleted,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('  build: TodosView ($todos)');
    return Center(
      child: ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return TodoView(
              todo,
              getTodoById: getTodoById,
              onToggleTodo: onToggleTodo,
              onRemoveTodo: onRemoveTodo,
              getAutoExpireCompleted: getAutoExpireCompleted,
            );
          }),
    );
  }
}
