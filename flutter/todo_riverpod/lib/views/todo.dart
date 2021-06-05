import 'package:flutter/material.dart';
import 'package:plugin/plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_riverpod/providers.dart';
import 'package:todo_riverpod/rid_pod.dart';

class TodoView extends ConsumerWidget with ConsumerLock {
  final int todoId;
  const TodoView(this.todoId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final todo = watch(todoByIdProvider(todoId));
    debugPrint('  build: ${todo.title}');
    return Dismissible(
      key: Key("Todo ${todo.id}"),
      child: Card(
        child: InkWell(
          onTap: () => context.read(todosProvider.notifier).toggleTodo(todo.id),
          child: ListTile(
            leading: todo.completed
                ? Icon(Icons.check, color: Colors.green)
                : Icon(Icons.calendar_today_rounded),
            title: Text('${todo.title}'),
          ),
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) =>
          context.read(todosProvider.notifier).removeTodo(todo.id),
      background: Padding(
        padding: EdgeInsets.all(5.0),
        child: Container(
          color: Colors.red,
        ),
      ),
    );
  }
}
