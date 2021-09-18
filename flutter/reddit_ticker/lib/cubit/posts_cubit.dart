import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:plugin/generated/rid_api.dart';

part 'posts_state.dart';

class PostsCubit extends Cubit<PostsState> {
  final _store = Store.instance;
  late final StreamSubscription<PostedReply>? removedPostsSub;

  PostsCubit() : super(PostsState([])) {
    _subscribe();
    _refresh();
  }

  void _subscribe() {
    removedPostsSub = rid.replyChannel.stream
        .where((x) =>
            x.type == Reply.StartedWatching || x.type == Reply.StoppedWatching)
        .listen((_) => _refresh());
  }

  Future<void> _unsubscribe() async {
    await removedPostsSub?.cancel();
    removedPostsSub = null;
  }

  void _refresh() {
    final posts = _store.posts.values.toList();
    // Show most recently added posts first
    posts.sort((a, b) => a.scores.length.compareTo(b.scores.length));
    emit(PostsState(posts));
  }

  @override
  Future<void> close() async {
    await _unsubscribe();
    return super.close();
  }
}
