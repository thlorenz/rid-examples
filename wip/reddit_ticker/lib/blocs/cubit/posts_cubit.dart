import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:plugin/generated/rid_api.dart';

part 'posts_state.dart';

class PostsCubit extends Cubit<PostsState> {
  final _store = Store.instance;
  late final StreamSubscription<PostedReply> removedPostsSub;

  PostsCubit() : super(PostsState([])) {
    _subscribe();
    refresh();
  }

  void _subscribe() {
    removedPostsSub = replyChannel.stream
        .where((x) => x.type == Reply.StoppedWatching)
        .listen((_) => refresh());
  }

  void refresh() {
    final posts = _store.posts.values.toList();
    // Show posts added last on top
    posts.sort((a, b) => a.scores.length.compareTo(b.scores.length));
    emit(PostsState(posts));
  }
}
