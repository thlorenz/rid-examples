import 'package:flutter/material.dart';
import 'package:plugin/plugin.dart';
import 'package:todo/views/menu.dart';
import 'package:todo/views/todos.dart';

const Color FILTER_SELECTED_COLOR = Colors.blue;
const Color FILTER_UNSELECTED_COLOR = Colors.black;

void main() {
  final model = rid_ffi.initModel();
  runApp(TodoApp(model));
}

class TodoApp extends StatelessWidget {
  final Pointer<Model> _model;
  const TodoApp(this._model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rust/Flutter Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodosPage(this._model, title: 'Todo App'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodosPage extends StatefulWidget {
  final String title;
  final Pointer<Model> _model;
  TodosPage(this._model, {Key? key, required this.title}) : super(key: key);

  @override
  _TodosPageState createState() => _TodosPageState(this._model);
}

class _TodosPageState extends State<TodosPage> {
  final _textFieldController = TextEditingController();
  String? addTodoTitle;

  final Pointer<Model> _model;
  RidVec_Pointer_Todo? _todos;

  _TodosPageState(this._model);

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
    todos = _model.filtered_todos();
    final RidFilter filter = _model.filter;

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
          restartAll: () => setState(_model.msgRestartAll),
          completeAll: () => setState(_model.msgCompleteAll),
          removeCompleted: () => setState(_model.msgRemoveCompleted),
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
                onPressed: () => setState(
                    () => _model.msgSetFilter(RidFilter.Pending.index)),
              ),
              Spacer(),
              IconButton(
                icon: Icon(
                  Icons.check,
                  color: filter == RidFilter.Completed
                      ? FILTER_SELECTED_COLOR
                      : FILTER_UNSELECTED_COLOR,
                ),
                onPressed: () => setState(
                    () => _model.msgSetFilter(RidFilter.Completed.index)),
              ),
              IconButton(
                icon: Icon(
                  Icons.all_inclusive,
                  color: filter == RidFilter.All
                      ? FILTER_SELECTED_COLOR
                      : FILTER_UNSELECTED_COLOR,
                ),
                onPressed: () =>
                    setState(() => _model.msgSetFilter(RidFilter.All.index)),
              ),
            ],
          ),
        ),
        body: TodosView(
          todos,
          onToggleTodo: (id) {
            _model.msgToggleTodo(id);
            if (_model.filter != RidFilter.All) {
              setState(() {});
            }
          },
          onRemoveTodo: (id) => setState(() => _model.msgRemoveTodo(id)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _textFieldController.clear();
            await _addTodoDialog(context);
            if (addTodoTitle != null && addTodoTitle!.trim().isNotEmpty) {
              setState(() {
                _model.msgAddTodo(addTodoTitle!);
              });
              debugPrint("${_model.debug(true)}");
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
