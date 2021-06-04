import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plugin/plugin.dart';
import 'package:todo/views/menu.dart';
import 'package:todo/views/todos.dart';

const Color FILTER_SELECTED_COLOR = Colors.blue;
const Color FILTER_UNSELECTED_COLOR = Colors.black;

void configRid() {
  RID_DEBUG_REPLY = (reply) => debugPrint('$reply');
}

void main() async {
  final store = createStore();
  configRid();
  await store.msgSetAutoExpireCompletedTodos(false);
  runApp(TodoApp(store));
}

class TodoApp extends StatelessWidget with StatelessLock {
  final Pointer<RawStore> _store;

  const TodoApp(this._store, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('  build: TodoApp');
    return MaterialApp(
      title: 'Rust/Flutter Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodosPage(this._store, title: 'Todo App'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodosPage extends StatefulWidget with StatefulLock {
  final String title;
  final Pointer<RawStore> _store;

  TodosPage(this._store, {Key? key, required this.title}) : super(key: key);

  @override
  _TodosPageState createState() => _TodosPageState(this._store);
}

class _TodosPageState extends State<TodosPage> with StateAsync<TodosPage> {
  late final StreamSubscription<PostedReply> sub;
  final _textFieldController = TextEditingController();
  String? addTodoTitle;

  final Pointer<RawStore> _store;

  _TodosPageState(this._store);

  @override
  void initState() {
    // Completed todos are expired on a separate thread from Rust, i.e. not in
    // direct response to a user message.
    // We subscribe to this event here to update the list of filtered todos
    // when that happens.
    sub = replyChannel.stream
        .where((reply) => reply.type == Reply.CompletedTodoExpired)
        .listen((_) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('  build: TodosPage');
    final RidFilter filter = _store.filter;
    final filteredTodos = _store.filtered_todos().toDart();
    debugPrint("filtered: \n  ${filteredTodos.join('\n  ')}");

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title),
              Row(
                children: [
                  Image.asset(
                    "assets/dash.png",
                    height: 40.0,
                    width: 40.0,
                  ),
                  Icon(Icons.favorite, color: Colors.red),
                  Image.asset(
                    "assets/ferris.png",
                    height: 50.0,
                    width: 50.0,
                  ),
                ],
              )
            ],
          ),
        ),
        drawer: Drawer(
          child: Menu(
            restartAll: () => setStateAsync(_store.msgRestartAll),
            completeAll: () => setStateAsync(_store.msgCompleteAll),
            removeCompleted: () => setStateAsync(_store.msgRemoveCompleted),
            autoExpireCompleted: () => _store.auto_expire_completed_todos,
            setAutoExpireCompleted: (val) =>
                _store.msgSetAutoExpireCompletedTodos(val),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.calendar_today_rounded,
                  color: filter == RidFilter.Pending
                      ? FILTER_SELECTED_COLOR
                      : FILTER_UNSELECTED_COLOR,
                ),
                onPressed: () =>
                    setStateAsync(() => _store.msgSetFilter(Filter.Pending)),
              ),
              Spacer(),
              IconButton(
                icon: Icon(
                  Icons.check,
                  color: filter == RidFilter.Completed
                      ? FILTER_SELECTED_COLOR
                      : FILTER_UNSELECTED_COLOR,
                ),
                onPressed: () =>
                    setStateAsync(() => _store.msgSetFilter(Filter.Completed)),
              ),
              IconButton(
                icon: Icon(
                  Icons.all_inclusive,
                  color: filter == RidFilter.All
                      ? FILTER_SELECTED_COLOR
                      : FILTER_UNSELECTED_COLOR,
                ),
                onPressed: () =>
                    setStateAsync(() => _store.msgSetFilter(Filter.All)),
              ),
            ],
          ),
        ),
        body: TodosView(
          filteredTodos,
          getTodoById: (id) => (_store.todo_by_id(id))?.toDart(),
          onToggleTodo: (id) async {
            await _store.msgToggleTodo(id);
            setState(() {});
          },
          onRemoveTodo: (id) async {
            await _store.msgRemoveTodo(id);
            setState(() {});
          },
          getAutoExpireCompleted: () => _store.auto_expire_completed_todos,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _textFieldController.clear();
            await _addTodoDialog(context);
            if (addTodoTitle != null && addTodoTitle!.trim().isNotEmpty) {
              await _store.msgAddTodo(addTodoTitle!);
              setState(() {});
              debugPrint("${_store.debug(true)}");
            }
          },
          tooltip: 'Add Todo',
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _addTodoDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter Todo Title'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Todo title"),
              autofocus: true,
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Done'),
                onPressed: () {
                  addTodoTitle = _textFieldController.value.text;
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
