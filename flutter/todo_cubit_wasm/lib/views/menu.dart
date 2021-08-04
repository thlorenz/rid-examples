import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_cubit/blocs/cubit/settings_cubit.dart';
import 'package:todo_cubit/blocs/cubit/todos_cubit.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        ListTile(title: Text('Todo Actions')),
        Divider(),
        ListTile(
          title: Text('Restart All'),
          onTap: () => context.read<TodosCubit>().restartAll(),
        ),
        ListTile(
          title: Text('Complete All'),
          onTap: () => context.read<TodosCubit>().completeAll(),
        ),
        ListTile(
          title: Text('Remove Completed'),
          onTap: () => context.read<TodosCubit>().removeCompleted(),
        ),
      ],
    );
  }
}

class AutoRemoveCompletedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: context.select<SettingsCubit, bool>(
        (x) => x.state.autoExpireCompletedTodos,
      ),
      onChanged: (val) {
        if (val != null)
          context.read<SettingsCubit>().setAutoExpireCompleted(val);
      },
    );
  }
}
