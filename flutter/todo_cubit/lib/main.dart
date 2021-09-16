import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plugin/generated/rid_api.dart';
import 'package:todo_cubit/blocs/cubit/filter_cubit.dart';
import 'package:todo_cubit/blocs/cubit/settings_cubit.dart';
import 'package:todo_cubit/blocs/cubit/todos_cubit.dart';
import 'package:todo_cubit/views/menu.dart';
import 'package:todo_cubit/views/todos.dart';

const Color FILTER_SELECTED_COLOR = Colors.blue;
const Color FILTER_UNSELECTED_COLOR = Colors.black;

void configRid() {
  rid.debugReply = (reply) => debugPrint('$reply');
}

void main() {
  configRid();
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rust/Flutter Cubit Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>(create: (_) => SettingsCubit()),
          BlocProvider<TodosCubit>(create: (_) => TodosCubit()),
          BlocProvider<FilterCubit>(create: (_) => FilterCubit())
        ],
        child: TodosPage(title: 'Cubit Todo App'),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodosPage extends StatefulWidget {
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
    final filter = context.watch<FilterCubit>().state;

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
        drawer: Drawer(child: Menu()),
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
                      context.read<FilterCubit>().setFilter(Filter.Pending)),
              Spacer(),
              IconButton(
                  icon: Icon(
                    Icons.check,
                    color: filter == Filter.Completed
                        ? FILTER_SELECTED_COLOR
                        : FILTER_UNSELECTED_COLOR,
                  ),
                  onPressed: () =>
                      context.read<FilterCubit>().setFilter(Filter.Completed)),
              IconButton(
                  icon: Icon(
                    Icons.all_inclusive,
                    color: filter == Filter.All
                        ? FILTER_SELECTED_COLOR
                        : FILTER_UNSELECTED_COLOR,
                  ),
                  onPressed: () =>
                      context.read<FilterCubit>().setFilter(Filter.All)),
            ],
          ),
        ),
        body: TodosView(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _textFieldController.clear();
            await _addTodoDialog(context);
            final title = addTodoTitle;
            if (title != null && title.trim().isNotEmpty) {
              context.read<TodosCubit>().addTodo(title);
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
