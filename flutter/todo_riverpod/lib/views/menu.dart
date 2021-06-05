import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_riverpod/providers.dart';

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('  build: Menu');
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        ListTile(title: Text('Todo Actions')),
        Divider(),
        ListTile(
          title: Text('Restart All'),
          onTap: context.read(todosProvider.notifier).restartAll,
        ),
        ListTile(
          title: Text('Complete All'),
          onTap: context.read(todosProvider.notifier).completeAll,
        ),
        ListTile(
          title: Text('Remove Completed'),
          onTap: context.read(todosProvider.notifier).removeCompleted,
        ),
      ],
    );
  }
}
