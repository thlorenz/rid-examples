import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:plugin/generated/rid_api.dart';

part 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final Store _store = Store.instance;
  late final StreamSubscription<PostedReply> tickSub;
  TodoCubit(Todo todo) : super(ExistingTodo(todo)) {
    _subscribe();
  }

  // Reply.Tick is a reply that includes data, in this case the id
  // of the completed todo whose life is ticking away
  bool _tickIsForThisTodo(PostedReply reply) {
    // We make sure that the data is a parseable int id
    assert(
      reply.data != null,
      'Reply.Tick should include data containing the id of the ticked todo',
    );
    final id = int.tryParse(reply.data!);
    assert(id != null, 'Reply.Tick included invalid id ${reply.data}');
    return id == state.id;
  }

  void _subscribe() {
    tickSub = rid.replyChannel.stream
        .where((x) => x.type == Reply.Tick && _tickIsForThisTodo(x))
        .listen(_refreshState);
  }

  @override
  Future<void> close() {
    tickSub.cancel();
    return super.close();
  }

  void _refreshState(PostedReply _reply) async {
    final todo = _store.todoById(state.id);
    if (todo == null) {
      emit(MissingTodo(state.id));
    } else {
      emit(ExistingTodo(todo));
    }
  }

  Future<void> toggleCompleted() =>
      _store.msgToggleTodo(state.id).then(_refreshState);

  Future<void> removeTodo(int id) =>
      _store.msgRemoveTodo(id).then(_refreshState);
}
