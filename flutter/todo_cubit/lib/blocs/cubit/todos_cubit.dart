import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:plugin/generated/rid_api.dart';

part 'todos_state.dart';

class TodosCubit extends Cubit<TodosState> {
  late final StreamSubscription<PostedReply> removedTodosSub;
  final Store _store = Store.instance;

  TodosCubit() : super(TodosState(Store.instance.filteredTodos())) {
    _subscribe();
  }

  void _subscribe() {
    removedTodosSub = rid.replyChannel.stream
        .where((x) =>
            x.type == Reply.RemovedTodo ||
            x.type == Reply.RemovedCompleted ||
            x.type == Reply.CompletedTodoExpired ||
            x.type == Reply.SetFilter)
        .listen(_refreshList);
  }

  @override
  Future<void> close() async {
    await removedTodosSub.cancel();
    return super.close();
  }

  void _refreshList(PostedReply _reply) async {
    final todos = _store.filteredTodos();
    emit(TodosState(todos));
    debugPrint('${_store.raw.debug(true)}');
  }

  Future<void> addTodo(String title) =>
      _store.msgAddTodo(title).then(_refreshList);

  Future<void> restartAll() => _store.msgRestartAll().then(_refreshList);
  Future<void> completeAll() => _store.msgCompleteAll().then(_refreshList);
  Future<void> removeCompleted() =>
      _store.msgRemoveCompleted().then(_refreshList);
}
