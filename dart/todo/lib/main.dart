import 'generated/rid_generated.dart';
import 'dart:io';

printStatus(Pointer<Model> model) {
  final todos = model.todos;
  final total = todos.length;

  final filter = model.filter;
  final matchingTodos = model.filtered_todos();

  final Pointer<Todo> todo = todos[0];

  final status = todo.completed ? 'done' : 'pending';
  print('${todo.title}with id ${todo.id} is $status');

  print("Total Todos:     $total");
  print("Filter:          ${filter.display()}");
  print("\nMatching Todos:");
  for (final todo in matchingTodos.iter()) {
    print("    ${todo.display()}");
  }
  matchingTodos.dispose();
}

bool handleCommand(Pointer<Model> model, String line) {
  String cmd;
  String payload;

  if (line.length > 2) {
    cmd = line.substring(0, 3);
    payload = line.substring(3).trim();
  } else {
    cmd = line.substring(0, 2);
    payload = "";
  }

  switch (cmd) {
    case "add":
      model.msgAddTodo(payload);
      break;
    case "del":
      model.msgRemoveTodo(int.parse(payload));
      break;
    case "cmp":
      model.msgCompleteTodo(int.parse(payload));
      break;
    case "tog":
      model.msgToggleTodo(int.parse(payload));
      break;
    case "rst":
      model.msgRestartTodo(int.parse(payload));
      break;
    case "fil":
      final filter = payload == "cmp"
          ? RidFilter.Completed
          : payload == "pen"
              ? RidFilter.Pending
              : RidFilter.All;
      model.msgSetFilter(filter.index);
      break;
    case "ca":
      model.msgCompleteAll();
      break;
    case "dc":
      model.msgRemoveCompleted();
      break;
    case "ra":
      model.msgRestartAll();
      break;

    default:
      print("\nUnknown command '$cmd'\n");
      return false;
  }
  return true;
}

printCommands() {
  print("\nPlease select one of the below:\n");
  print("  add <todo title>  -- to add a todo");
  print("  del <todo id>     -- to delete a todo by id");
  print("  cmp <todo id>     -- to complete a todo by id");
  print("  rst <todo id>     -- to restart a todo by id");
  print("  tog <todo id>     -- to toggle a todo by id");
  print("  fil all|cmp|pen   -- to set filter to");
  print("  ca                -- to completed all todos");
  print("  dc                -- to delete completed todos");
  print("  ra                -- to restart all todos");
  print("  q                 -- to quit");
}

void main(List<String> args) {
  final model = rid_ffi.initModel();
  {
    model.msgAddTodo("Complete this Todo via:     cmp 1");
    model.msgAddTodo("Delete this Todo via:       del 2");
    model.msgAddTodo("Toggle this Todo via:       tog 3");
    model.msgAddTodo("Restart the first Todo via: rst 1");

    String? input;
    bool ok = true;

    while (true) {
      if (ok) {
        print("\x1B[2J\x1B[0;0H");
      }
      printStatus(model);
      printCommands();
      stdout.write("\n> ");
      input = stdin.readLineSync();
      if (input == "q") {
        break;
      }
      if (input != null && input.length > 1) {
        ok = handleCommand(model, input.trim());
      }
    }
  }
  model.dispose();
}
