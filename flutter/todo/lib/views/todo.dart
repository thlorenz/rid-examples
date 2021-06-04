import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plugin/plugin.dart';
import 'package:todo/views/expiry.dart';

class TodoView extends StatefulWidget with StatefulLock {
  final Todo todo;
  final Todo? Function(int) getTodoById;
  final Future<void> Function(int) onToggleTodo;
  final Future<void> Function(int) onRemoveTodo;
  final bool Function() getAutoExpireCompleted;

  TodoView(
    this.todo, {
    required this.getTodoById,
    required this.onToggleTodo,
    required this.onRemoveTodo,
    required this.getAutoExpireCompleted,
  }) : super(key: Key("Todo ${todo.hashCode}"));

  @override
  _TodoViewState createState() => _TodoViewState(todo);
}

class _TodoViewState extends State<TodoView> with StateAsync<TodoView> {
  Todo todo;
  late bool autoExpireCompleted;
  late final StreamSubscription<PostedReply> expirySub;
  late final StreamSubscription<PostedReply> expiryConfigSub;

  _TodoViewState(this.todo) : super();

  bool _replyIsForThisTodo(PostedReply reply) {
    assert(
      reply.data != null,
      'Reply.Tick should include data containing the id of the ticked todo',
    );
    final id = int.tryParse(reply.data!);
    assert(id != null, 'Reply.Tick included invalid id ${reply.data}');
    return id == todo.id;
  }

  @override
  void initState() {
    // Todos are expired on a separate thread in Rust tick by tick. Those tick
    // events aren't directly related to a user message and therefore we
    // subscribe to them.
    expirySub = replyChannel.stream
        .where(
            (reply) => reply.type == Reply.Tick && _replyIsForThisTodo(reply))
        .listen((_) {
      final update = widget.getTodoById(todo.id);
      if (update != null) {
        setState(() => {todo = update});
      }
    });

    // Auto expire is set via the settings view, however we need to know about
    // this setting here as well.
    // A subscription will let us know even though we didn't initiate the
    // related message.
    autoExpireCompleted = widget.getAutoExpireCompleted();
    expiryConfigSub = replyChannel.stream
        .where((reply) => reply.type == Reply.SetAutoExpireCompletedTodos)
        .listen((_) {
      autoExpireCompleted = widget.getAutoExpireCompleted();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('  build: TodoView ${todo.title}');
    return Dismissible(
      key: Key("Todo Dismissible ${todo.id}"),
      child: Card(
        child: InkWell(
            onTap: () => setStateAsync(() => widget.onToggleTodo(todo.id)),
            child: ListTile(
              leading: todo.completed
                  ? Icon(Icons.check, color: Colors.green)
                  : Icon(Icons.calendar_today_rounded),
              title: Text('${todo.title}'),
              subtitle: autoExpireCompleted && todo.completed
                  ? ExpiryWidget(remainingMillis: todo.expiry_millis.toDouble())
                  : null,
            )),
      ),
      direction: DismissDirection.endToStart,
      // Make sure we removed the Todo and got the reply before updating the UI
      confirmDismiss: (_) => widget.onRemoveTodo(todo.id).then((_) => true),
      background: Padding(
        padding: EdgeInsets.all(5.0),
        child: Container(color: Colors.red),
      ),
    );
  }

  @override
  void dispose() {
    expirySub.cancel();
    expiryConfigSub.cancel();
    super.dispose();
  }
}
