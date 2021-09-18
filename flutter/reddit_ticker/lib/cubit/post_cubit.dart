import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:plugin/generated/rid_api.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final Store _store = Store.instance;
  PostCubit(Post post) : super(PostActive(post));

  Future<void> _refreshState() async {
    assert(state is PostActive, 'Should only refresh post when it is ticking');
    final postActive = state as PostActive;
    final post = _store.posts[postActive.postId];

    if (post == null) {
      emit(postActive.intoRemoved());
    } else {
      emit(PostActive(post));
    }
  }

  Future<bool> stopWatching() async {
    assert(state is PostActive, 'Can only remove active post');
    final post = (state as PostActive).post;
    await _store.msgStopWatching(post.id).then((_) => _refreshState());
    return true;
  }
}
