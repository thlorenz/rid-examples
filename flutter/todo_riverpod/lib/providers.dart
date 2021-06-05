import 'package:flutter/foundation.dart';
import 'package:plugin/plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storeProvider = Provider((ref) => createStore());

// -----------------
// Filter
// -----------------
class FilterNotifier extends StateNotifier<RidFilter> {
  final Pointer<Store> _store;
  FilterNotifier(this._store) : super(RidFilter.All);

  setFilter(RidFilter val) async {
    await _store.msgSetFilter(val.index);
    _store.runLocked((store) {
      state = store.filter;
    });
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, RidFilter>(
    (ref) => FilterNotifier(ref.read(storeProvider)));

// -----------------
// All Todos
// -----------------
class TodosNotifier extends StateNotifier<Pointer<Vec_Todo>> {
  final Pointer<Store> _store;
  TodosNotifier(this._store) : super(_store.todos) {
    replyChannel.stream
        .where((reply) =>
            reply.type == Reply.AddedTodo ||
            reply.type == Reply.RemovedTodo ||
            reply.type == Reply.RemovedCompleted)
        .listen((_) => _store.runLocked(
              (store) {
                debugPrint('  provider: todos listener');
                state = store.todos;
              },
            ));
  }

  // For the below three we don't need to refresh the state since this is
  // taken care of by the stream subscription above
  addTodo(String title) => _store.msgAddTodo(title);
  removeTodo(int id) => _store.msgRemoveTodo(id);
  removeCompleted() => _store.msgRemoveCompleted();

  // We could include these cases in the stream subscription as well, but
  // refresh state manually here to show this alternative
  toggleTodo(int id) async {
    await _store.msgToggleTodo(id);
    _refreshState();
  }

  restartAll() async {
    await _store.msgRestartAll();
    _refreshState();
  }

  completeAll() async {
    await _store.msgCompleteAll();
    _refreshState();
  }

  _refreshState() {
    _store.runLocked((store) {
      debugPrint('  provider: todos refresh');
      state = store.todos;
    });
  }
}

final todosProvider = StateNotifierProvider<TodosNotifier, Pointer<Vec_Todo>>(
    (ref) => TodosNotifier(ref.read(storeProvider)));

// -----------------
// Filtered Todos
// -----------------
class FilteredTodosNotifier extends StateNotifier<List<Pointer<Todo>>> {
  Pointer<Store> _store;
  FilteredTodosNotifier(this._store) : super([]) {
    refresh();
    // Any todo action affects how todos are filtered
    replyChannel.stream.listen((reply) => refresh());
  }

  refresh() {
    state = _store.runLocked((store) {
      debugPrint('  provider: filtered todos');
      final todoVec = store.filtered_todos();
      try {
        return todoVec.iter().toList();
      } finally {
        todoVec.dispose();
      }
    });
  }
}

final filteredTodosProvider =
    StateNotifierProvider<FilteredTodosNotifier, List<Pointer<Todo>>>((ref) {
  // As an alternative to listening to replies in the [FilteredTodosNotifier], we could also
  // watch the related providers like so:
  // ref.watch(filterProvider);
  // ref.watch(todosProvider);

  return FilteredTodosNotifier(ref.read(storeProvider));
});

final todoByIdProvider = Provider.family<Pointer<Todo>, int>((ref, id) {
  // NOTE: this line is very important as otherwise the `watch` inside the
  // ./views/todo.dart `build` method won't get triggered which may lead to an
  // outdated todo pointer to be used and possible crash as a result
  // This is due to riverpod keeping the pointer in its state which is reused on
  // rebuild triggered for instance when a todo is added. That state is only
  // updated if `watch` in the TodoView fires.
  ref.watch(todosProvider);
  return ref.read(storeProvider).runLocked((store) {
    debugPrint('  provider: todo by id $id');
    final todo = store.todo_by_id(id);
    if (todo == null) {
      debugPrint('Todo with id $id does not exist');
      throw ArgumentError.notNull("todo");
    } else {
      return todo;
    }
  });
});
