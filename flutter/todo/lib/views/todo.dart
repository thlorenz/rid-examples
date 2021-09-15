import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plugin/generated/rid_api.dart';
import 'package:todo/views/expiry.dart';

class TodoView extends StatefulWidget with StatefulLock {
  final Todo todo;
  final Settings settings;
  final Todo? Function(int) getTodoById;
  final Future<void> Function(int) onToggleTodo;
  final Future<void> Function(int) onRemoveTodo;

  TodoView(
    this.todo,
    this.settings, {
    required this.getTodoById,
    required this.onToggleTodo,
    required this.onRemoveTodo,
  }) : super(key: Key("Todo ${todo.hashCode}"));

  @override
  _TodoViewState createState() => _TodoViewState(todo, settings);
}

class _TodoViewState extends State<TodoView> with StateAsync<TodoView> {
  Todo todo;
  final Settings settings;
  late final StreamSubscription<PostedReply> expirySub;

  _TodoViewState(this.todo, this.settings) : super();

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
    expirySub = rid.replyChannel.stream
        .where(
            (reply) => reply.type == Reply.Tick && _replyIsForThisTodo(reply))
        .listen((_) {
      final update = widget.getTodoById(todo.id);
      if (update != null) {
        setState(() => {todo = update});
      }
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
              subtitle:
                  widget.settings.autoExpireCompletedTodos && todo.completed
                      ? ExpiryWidget(
                          completedExpiryMillis:
                              settings.completedExpiryMillis.toDouble(),
                          remainingMillis: todo.expiryMillis.toDouble(),
                        )
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
    super.dispose();
  }
}
