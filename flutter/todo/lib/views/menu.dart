import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:plugin/generated/rid_api.dart';

class Menu extends StatelessWidget {
  final Settings settings;

  final void Function() restartAll;
  final void Function() completeAll;
  final void Function() removeCompleted;

  final void Function(bool) setAutoExpireCompleted;

  const Menu(
    this.settings, {
    required this.restartAll,
    required this.completeAll,
    required this.removeCompleted,
    required this.setAutoExpireCompleted,
    Key? key,
  }) : super(key: key);
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
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Expire Completed'),
              AutoRemoveCompletedWidget(
                autoExpireCompleted: settings.autoExpireCompletedTodos,
                setAutoExpireCompleted: setAutoExpireCompleted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AutoRemoveCompletedWidget extends StatefulWidget with StatefulLock {
  final bool autoExpireCompleted;
  final void Function(bool) setAutoExpireCompleted;

  const AutoRemoveCompletedWidget({
    Key? key,
    required this.autoExpireCompleted,
    required this.setAutoExpireCompleted,
  }) : super(key: key);

  @override
  State<AutoRemoveCompletedWidget> createState() =>
      _AutoRemoveCompletedWidgetState();
}

class _AutoRemoveCompletedWidgetState extends State<AutoRemoveCompletedWidget>
    with StateAsync {
  @override
  Widget build(BuildContext context) {
    debugPrint('  build: AutoRemoveCompleted');
    return Checkbox(
      value: widget.autoExpireCompleted,
      onChanged: (val) {
        if (val != null) widget.setAutoExpireCompleted(val);
      },
    );
  }
}
