import 'package:flutter/material.dart';
import 'package:plugin/plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_riverpod/providers.dart';
import 'package:todo_riverpod/ridpod.dart';
import 'package:todo_riverpod/views/todo.dart';

class TodosView extends RidConsumerWidget {
  const TodosView({Key? key}) : super(key: key);

  @override
  Widget buildLocked(BuildContext context, ScopedReader watch) {
    debugPrint('build: Todos');
    final todos = watch(filteredTodosProvider);
    return Center(
      child: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return ProviderScope(
            overrides: [
              scopedTodoProvider.overrideAs((ref) {
                return watch(filteredTodosProvider).elementAt(index);
              })
            ],
            child: const TodoView(),
          );
        },
      ),
    );
  }
}
