import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plugin/generated/rid_api.dart';
import 'package:todo_cubit/blocs/cubit/settings_cubit.dart';
import 'package:todo_cubit/blocs/cubit/todo_cubit.dart';
import 'package:todo_cubit/views/expiry.dart';

class TodoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(builder: (context, state) {
      if (state is MissingTodo) {
        return Text('Todo ${state.id} missing, most likely removed');
      }
      if (state is ExistingTodo) {
        final todo = state.todo;
        return Dismissible(
          key: Key("Todo Dismissible ${todo.id}"),
          child: Card(
            child: InkWell(
              onTap: () => context.read<TodoCubit>().toggleCompleted(),
              child: ListTile(
                leading: todo.completed
                    ? Icon(Icons.check, color: Colors.green)
                    : Icon(Icons.calendar_today_rounded),
                title: Text('${todo.title}'),
                subtitle: BlocBuilder<SettingsCubit, Settings>(
                  builder: (context, settings) {
                    return settings.autoExpireCompletedTodos && todo.completed
                        ? ExpiryWidget(
                            completedExpiryMillis:
                                settings.completedExpiryMillis.toDouble(),
                            remainingMillis: todo.expiryMillis.toDouble(),
                          )
                        : Container();
                  },
                ),
              ),
            ),
          ),
          direction: DismissDirection.endToStart,
          // Make sure we removed the Todo and got the reply before updating the UI
          confirmDismiss: (_) =>
              context.read<TodoCubit>().removeTodo(todo.id).then((_) => true),
          background: Padding(
            padding: EdgeInsets.all(5.0),
            child: Container(color: Colors.red),
          ),
        );
      } else {
        return Text('Unkown TodoState type $state');
      }
    });
  }
}
