import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plugin/generated/rid_api.dart';
import 'package:todo/views/menu.dart';
import 'package:todo/views/todos.dart';

const Color FILTER_SELECTED_COLOR = Colors.blue;
const Color FILTER_UNSELECTED_COLOR = Colors.black;

void configRid() {
  rid.debugReply = (reply) => debugPrint('$reply');
}

void main() async {
  configRid();
  await Store.instance.msgSetAutoExpireCompletedTodos(false);
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget with StatelessLock {
  @override
  Widget build(BuildContext context) {
    debugPrint('  build: TodoApp');
    return MaterialApp(
      title: 'Rust/Flutter Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodosPage(title: 'Todo App'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodosPage extends StatefulWidget with StatefulLock {
  final String title;

  TodosPage({Key? key, required this.title}) : super(key: key);

  @override
  _TodosPageState createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> with StateAsync<TodosPage> {
  late final StreamSubscription<PostedReply> sub;
  final _textFieldController = TextEditingController();
  String? addTodoTitle;
  final Store _store = Store.instance;

  @override
  void initState() {
    // Completed todos are expired on a separate thread from Rust, i.e. not in
    // direct response to a user message.
    // We subscribe to this event here to update the list of filtered todos
    // when that happens.
    sub = rid.replyChannel.stream
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
    final Filter filter = _store.filter;
    final filteredTodos = _store.filteredTodos();
    final settings = _store.settings;
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
            settings,
            restartAll: () => setStateAsync(_store.msgRestartAll),
            completeAll: () => setStateAsync(_store.msgCompleteAll),
            removeCompleted: () => setStateAsync(_store.msgRemoveCompleted),
            setAutoExpireCompleted: (val) =>
                setStateAsync(() => _store.msgSetAutoExpireCompletedTodos(val)),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.calendar_today_rounded,
                  color: filter == Filter.Pending
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
                  color: filter == Filter.Completed
                      ? FILTER_SELECTED_COLOR
                      : FILTER_UNSELECTED_COLOR,
                ),
                onPressed: () =>
                    setStateAsync(() => _store.msgSetFilter(Filter.Completed)),
              ),
              IconButton(
                icon: Icon(
                  Icons.all_inclusive,
                  color: filter == Filter.All
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
          settings,
          getTodoById: (id) => _store.todoById(id),
          onToggleTodo: (id) async {
            await _store.msgToggleTodo(id);
            setState(() {});
          },
          onRemoveTodo: (id) async {
            await _store.msgRemoveTodo(id);
            setState(() {});
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _textFieldController.clear();
            await _addTodoDialog(context);
            if (addTodoTitle != null && addTodoTitle!.trim().isNotEmpty) {
              await _store.msgAddTodo(addTodoTitle!);
              setState(() {});
              debugPrint("${_store.raw.debug(true)}");
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
