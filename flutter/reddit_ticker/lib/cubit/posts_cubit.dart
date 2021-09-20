import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:plugin/generated/rid_api.dart';

part 'posts_state.dart';

class PostsCubit extends Cubit<PostsState> {
  final _store = Store.instance;
  PostsCubit() : super(PostsState([])) {
    _refresh();
  }

  void _refresh() {
    final posts = _store.posts.values.toList();
    // Show most recently added post first
    posts.sort((a, b) => a.scores.length.compareTo(b.scores.length));
    emit(PostsState(posts));
  }
}
