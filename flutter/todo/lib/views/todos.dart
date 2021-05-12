import 'package:flutter/material.dart';
import 'package:plugin/generated/rid_generated.dart';
import 'package:todo/views/todo.dart';

class TodosView extends StatelessWidget {
  final RidVec_Pointer_Todo todos;

  final void Function(int) onToggleTodo;
  final void Function(int) onRemoveTodo;

  const TodosView(this.todos,
      {required this.onToggleTodo, required this.onRemoveTodo, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return TodoView(todo,
                onToggle: () => onToggleTodo(todo.id),
                onRemove: () => onRemoveTodo(todo.id));
          }),
    );
  }
}
