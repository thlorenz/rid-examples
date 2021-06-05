import 'package:flutter/foundation.dart';
import 'package:plugin/plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final store = rid_ffi.createStore();

// -----------------
// Filter
// -----------------
class FilterNotifier extends StateNotifier<RidFilter> {
  final Pointer<Store> _store;

  FilterNotifier(this._store) : super(RidFilter.All);

  setFilter(RidFilter val) async {
    await _store.msgSetFilter(val.index);
    _store.runLocked((store) => state = store.filter);
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, RidFilter>(
    (ref) => FilterNotifier(store));

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
        .listen((_) => _store.runLocked((store) => state = store.todos));
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
    _store.runLocked((store) => state = store.todos);
  }
}

final todosProvider = StateNotifierProvider<TodosNotifier, Pointer<Vec_Todo>>(
    (ref) => TodosNotifier(store));

// -----------------
// Filtered Todos
// -----------------
final filteredTodosProvider = Provider<List<Pointer<Todo>>>((ref) {
  ref.watch(filterProvider);
  ref.watch(todosProvider);

  // This approach allows us to combine providers and we don't need a separate
  // state notifier.
  // However in order to properly dispose the vector passed to us from Rust we
  // need to convert the vec into a Dart list which could cause performance
  // issues if we had thousands of todo items. This is not likely for this
  // application, but something to consider for other scenarios.
  late final List<Pointer<Todo>> todos;
  // We make sure to lock the store while we're reading from it in order to prevent
  // todos being added/removed/modified while we are obtaining them.
  store.runLocked((store) {
    final todoVec = store.filtered_todos();
    todos = todoVec.iter().toList();
    todoVec.dispose();
  });
  // TODO(thlorenz): we still don't know if the store will get locked again while rendering.
  return todos;
});

final todoByIdProvider = Provider.family<Pointer<Todo>, int>((ref, id) {
  final todoVec = ref.watch(todosProvider);
  for (final todo in todoVec.iter()) {
    if (todo.id == id) return todo;
  }

  debugPrint('Todo with $id does not exist');
  throw ArgumentError.notNull("todo");
});

final scopedTodoProvider = ScopedProvider<Pointer<Todo>>(null);
