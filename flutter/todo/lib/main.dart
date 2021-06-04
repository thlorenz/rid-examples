import 'package:flutter/material.dart';
import 'package:plugin/plugin.dart';
import 'package:todo/views/menu.dart';
import 'package:todo/views/todos.dart';

const Color FILTER_SELECTED_COLOR = Colors.blue;
const Color FILTER_UNSELECTED_COLOR = Colors.black;

/// Locks down the store while building widgets in order to prevent the
/// application from modifying its state while we are reading it in order to
/// render the widget.
/// For this app this wouldn't be necessary since no background tasks that
/// write to the store are running. However it is good practice to do this anyways.
/// Note that when using StateManagement solutions like riverpod, rid will
/// ensure the above by other means.
void syncStoreAccess() {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  binding.addPersistentFrameCallback((_) {
    rid_ffi.rid_store_lock();
    binding.addPostFrameCallback((_) {
      rid_ffi.rid_store_unlock();
    });
  });
}

void main() {
  final store = rid_ffi.createStore();
  syncStoreAccess();
  runApp(TodoApp(store));
}

class TodoApp extends StatelessWidget {
  final Pointer<Store> _store;

  const TodoApp(this._store, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

class TodosPage extends StatefulWidget {
  final String title;
  final Pointer<Store> _store;

  TodosPage(this._store, {Key? key, required this.title}) : super(key: key);

  @override
  _TodosPageState createState() => _TodosPageState(this._store);
}

class _TodosPageState extends State<TodosPage> {
  final _textFieldController = TextEditingController();
  String? addTodoTitle;

  final Pointer<Store> _store;
  RidVec_Pointer_Todo? _todos;

  _TodosPageState(this._store);

  RidVec_Pointer_Todo get todos {
    assert(_todos != null);
    return _todos!;
  }

  set todos(RidVec_Pointer_Todo val) {
    _todos?.dispose();
    _todos = val;
  }

  @override
  Widget build(BuildContext context) {
    todos = _store.filtered_todos();
    final RidFilter filter = _store.filter;

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
          restartAll: () async {
            final res = await _store.msgRestartAll();
            debugPrint('$res');
            setState(() {});
          },
          completeAll: () async {
            final res = await _store.msgCompleteAll();
            debugPrint('$res');
            setState(() {});
          },
          removeCompleted: () async {
            final res = await _store.msgRemoveCompleted();
            debugPrint('$res');
            setState(() {});
          },
        )),
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
                onPressed: () async {
                  final res = await _store.msgSetFilter(Filter.Pending);
                  debugPrint('$res');
                  setState(() {});
                },
              ),
              Spacer(),
              IconButton(
                icon: Icon(
                  Icons.check,
                  color: filter == RidFilter.Completed
                      ? FILTER_SELECTED_COLOR
                      : FILTER_UNSELECTED_COLOR,
                ),
                onPressed: () async {
                  final res = await _store.msgSetFilter(Filter.Completed);
                  debugPrint('$res');
                  setState(() {});
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.all_inclusive,
                  color: filter == RidFilter.All
                      ? FILTER_SELECTED_COLOR
                      : FILTER_UNSELECTED_COLOR,
                ),
                onPressed: () async {
                  final res = await _store.msgSetFilter(Filter.All);
                  debugPrint('$res');
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        body: TodosView(
          todos,
          onToggleTodo: (id) async {
            final res = await _store.msgToggleTodo(id);
            debugPrint('$res');
            if (_store.filter != RidFilter.All) {
              setState(() {});
            }
          },
          onRemoveTodo: (id) async {
            final res = await _store.msgRemoveTodo(id);
            debugPrint('$res');
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _textFieldController.clear();
            await _addTodoDialog(context);
            if (addTodoTitle != null && addTodoTitle!.trim().isNotEmpty) {
              final res = await _store.msgAddTodo(addTodoTitle!);
              debugPrint('$res');
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
