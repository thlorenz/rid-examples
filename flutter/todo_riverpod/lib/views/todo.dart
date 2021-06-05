import 'package:flutter/material.dart';
import 'package:plugin/plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_riverpod/providers.dart';
import 'package:todo_riverpod/ridpod.dart';

class TodoView extends RidConsumerWidget {
  const TodoView({Key? key}) : super(key: key);

  @override
  Widget buildLocked(BuildContext context, ScopedReader watch) {
    final todo = watch(scopedTodoProvider);
    debugPrint('build: ${todo.title}');
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
