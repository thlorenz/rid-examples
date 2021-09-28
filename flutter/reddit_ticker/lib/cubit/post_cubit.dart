import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:plugin/generated/rid_api.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final _store = Store.instance;
  StreamSubscription<PostedReply>? scoreTickSub;
  PostCubit(Post post) : super(PostActive(post)) {
    _subscribe();
  }

  void _subscribe() {
    assert(scoreTickSub == null, 'Should only subscribe to post ticks once');
    scoreTickSub = rid.replyChannel.stream
        .where((x) => x.type == Reply.UpdatedScores)
        .listen((_) => _refreshState());
  }

  Future<void> _unsubscribe() async {
    await scoreTickSub?.cancel();
    scoreTickSub = null;
  }

  Future<void> _refreshState() async {
    assert(state is PostActive, 'Can only refresh active posts');
    final postActive = state as PostActive;
    final post =
        _store.raw.runLocked((raw) => raw.posts.get(postActive.postId));

    if (post == null) {
      emit(postActive.intoRemoved());
    } else {
      emit(PostActive(post));
    }
  }

  Future<bool> stopWatching() async {
    assert(state is PostActive, 'Can only remove active posts');
    final post = (state as PostActive).post;
    await _store.msgStopWatching(post.id).then((_) => _refreshState());
    emit(PostRemoved(post.id, post.url));
    return true;
  }

  @override
  Future<void> close() async {
    await _unsubscribe();
    return super.close();
  }
}
