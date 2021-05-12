import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Menu extends StatelessWidget {
  final void Function() restartAll;
  final void Function() completeAll;
  final void Function() removeCompleted;

  const Menu({
    required this.restartAll,
    required this.completeAll,
    required this.removeCompleted,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        ListTile(title: Text('Todo Actions')),
        Divider(),
        ListTile(
          title: Text('Restart All'),
          onTap: restartAll,
        ),
        ListTile(
          title: Text('Complete All'),
          onTap: completeAll,
        ),
        ListTile(
          title: Text('Remove Completed'),
          onTap: removeCompleted,
        ),
      ],
    );
  }
}
