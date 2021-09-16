import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:plugin/generated/rid_api.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final Store _store = Store.instance;
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
    assert(state is PostActive, 'Should only refresh post when it is ticking');
    final postActive = state as PostActive;
    final post = _store.posts[postActive.post.id];

    if (post == null) {
      await _unsubscribe();
      emit(PostRemoved.fromPostActive(postActive));
    } else {
      emit(PostActive(post));
    }
  }

  @override
  Future<void> close() async {
    await _unsubscribe();
    return super.close();
  }

  Future<bool> stopWatching() async {
    assert(state is PostActive, 'Can only remove active post');
    final post = (state as PostActive).post;
    await _store.msgStopWatching(post.id).then((_) => _refreshState());
    emit(PostRemoved(post.id, post.url));
    return true;
  }
}
