import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:plugin/generated/rid_api.dart';

part 'add_post_state.dart';

// Requests to reddit can be slow especially on not so great internet
final REQ_TIMEOUT = const Duration(seconds: 10);

class AddPostCubit extends Cubit<AddPostState> {
  final Store _store = Store.instance;
  AddPostCubit() : super(AddPostInactive());

  Future<void> addPost(String url) async {
    emit(AddPostPending(url));

    final res = await _store.msgStartWatching(url, timeout: REQ_TIMEOUT);

    switch (res.type) {
      case Reply.StartedWatching:
        assert(res.data != null, 'Successful reply should include post id');
        final post = _store.posts[res.data];
        assert(post != null, 'Watched post should be in the map');
        emit(AddPostSucceeded(post!));
        break;
      case Reply.FailedRequest:
        assert(res.data != null, 'Failed reply should include error message');
        assert(state is AddPostPending,
            'Adding post should only fail if it was pending');
        emit(AddPostFailed((state as AddPostPending).url, res.data!));
        break;
      default:
        throw ArgumentError.value(
            res.type, 'StartWatching Reply', 'Invalid reply!');
    }
  }
}
