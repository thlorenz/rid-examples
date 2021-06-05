import 'package:flutter/material.dart';
import 'package:plugin/plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_riverpod/providers.dart';
import 'package:todo_riverpod/views/menu.dart';
import 'package:todo_riverpod/views/todos.dart';

const Color FILTER_SELECTED_COLOR = Colors.blue;
const Color FILTER_UNSELECTED_COLOR = Colors.black;

void configRid() {
  RID_DEBUG_REPLY = (reply) => debugPrint('$reply');
}

void main() {
  configRid();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rust/Flutter Counter App Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoApp(),
    );
  }
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

class _TodosPageState extends State<TodosPage> {
  final _textFieldController = TextEditingController();
  String? addTodoTitle;

  @override
  Widget build(BuildContext context) {
    debugPrint('  build: TodosPage');
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
        drawer: Drawer(child: const Menu()),
        bottomNavigationBar: BottomAppBar(
          child: Consumer(builder: (context, watch, child) {
            final filter = watch(filterProvider);
            return Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.calendar_today_rounded,
                    color: filter == RidFilter.Pending
                        ? FILTER_SELECTED_COLOR
                        : FILTER_UNSELECTED_COLOR,
                  ),
                  onPressed: () => context
                      .read(filterProvider.notifier)
                      .setFilter(RidFilter.Pending),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.check,
                    color: filter == RidFilter.Completed
                        ? FILTER_SELECTED_COLOR
                        : FILTER_UNSELECTED_COLOR,
                  ),
                  onPressed: () => context
                      .read(filterProvider.notifier)
                      .setFilter(RidFilter.Completed),
                ),
                IconButton(
                  icon: Icon(
                    Icons.all_inclusive,
                    color: filter == RidFilter.All
                        ? FILTER_SELECTED_COLOR
                        : FILTER_UNSELECTED_COLOR,
                  ),
                  onPressed: () => context
                      .read(filterProvider.notifier)
                      .setFilter(RidFilter.All),
                ),
              ],
            );
          }),
        ),
        body: const TodosView(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _textFieldController.clear();
            await _addTodoDialog(context);
            if (addTodoTitle != null && addTodoTitle!.trim().isNotEmpty) {
              context.read(todosProvider.notifier).addTodo(addTodoTitle!);
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
