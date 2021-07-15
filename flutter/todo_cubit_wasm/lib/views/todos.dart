import 'package:flutter/material.dart';
import 'package:todo_cubit/blocs/cubit/todo_cubit.dart';
import 'package:todo_cubit/blocs/cubit/todos_cubit.dart';
import 'package:todo_cubit/views/todo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodosView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<TodosCubit, TodosState>(builder: (context, state) {
        final todos = state.todos;
        return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return BlocProvider(
                create: (_) => TodoCubit(todo),
                child: TodoView(),
                key: Key(todo.hashCode.toString()),
              );
            });
      }),
    );
  }
}
