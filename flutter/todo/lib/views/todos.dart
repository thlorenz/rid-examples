import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todo/views/todo.dart';
import 'package:plugin/generated/rid_api.dart';

class TodosView extends StatelessWidget {
  final List<Todo> todos;
  final Settings settings;
  final Todo? Function(int) getTodoById;
  final Future<void> Function(int) onToggleTodo;
  final Future<void> Function(int) onRemoveTodo;

  const TodosView(
    this.todos,
    this.settings, {
    required this.getTodoById,
    required this.onToggleTodo,
    required this.onRemoveTodo,
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
              settings,
              getTodoById: getTodoById,
              onToggleTodo: onToggleTodo,
              onRemoveTodo: onRemoveTodo,
            );
          }),
    );
  }
}
